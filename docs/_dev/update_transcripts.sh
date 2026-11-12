#!/usr/bin/env bash
# Regenerates the command-output examples in _dev/transcripts/ by running the
# real commands. Pages show them with literalinclude, so the docs build never
# runs these tools. Output is filtered to the versions in versions.env, so a
# transcript only shows channels for the release the docs describe and never
# needs cross-version allowlist entries. Run it with `make transcripts` after
# bumping versions.env, then run `make version-check-clean`.
#
# Requires the sdk CLI (from the workshop snap) and network access.
#
# Exit status:
#   0  transcripts updated
#   1  missing tool or version, or the store lacks an expected channel
#      (transcripts left unchanged)

set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
docs_dir=$(cd -- "$script_dir/.." && pwd)
versions_env="$docs_dir/versions.env"
out_dir="$script_dir/transcripts"

# shellcheck disable=SC1090
set -a; . "$versions_env"; set +a
for var in DOC_VERSION SDK_NG_CHANNEL; do
    if [ -z "${!var:-}" ]; then
        echo "update-transcripts: $var not set by $versions_env" >&2
        exit 1
    fi
done

if ! command -v sdk >/dev/null; then
    echo "update-transcripts: sdk not found; install the workshop snap" >&2
    exit 1
fi

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

# Channel tracks to keep besides DOC_VERSION and its DOC_VERSION.N patch
# tracks: latest (which names no version), the track of SDK_NG_CHANNEL, the
# source tag, and the SDK version.
keep_tracks="latest ${SDK_NG_CHANNEL%%/*} ${SOURCE_TAG:-} ${SDK_NG_VERSION:-}"

# sdk_info FILE SDK CHANNEL writes `sdk info SDK` to FILE as a terminal shows
# it, with only the channel rows for the tracks above. CHANNEL is the channel
# the page tells readers to use; if the store doesn't list it, FILE is left
# unchanged. When piped, sdk prints "^" for "same revision as the row above"
# where a terminal shows "↑", which the page text describes. The INSTALLED
# section lists the caller's own workshops, so it is dropped to keep the
# transcript the same on every machine. awk reads to the end rather than
# exiting early, so sdk never writes to a closed pipe.
sdk_info() {
    sdk info "$2" | awk -v release="$DOC_VERSION" -v keep="$keep_tracks" '
        BEGIN { split(keep, tracks, " "); for (i in tracks) wanted[tracks[i]] = 1 }
        /^INSTALLED/ { installed = 1 }
        installed { next }
        /^CHANNELS/ { table = 1 }
        /^$/ { table = 0 }
        table && $1 ~ /\// {
            track = $1; sub(/\/.*/, "", track)
            patch = substr(track, length(release) + 2)
            if (!(track in wanted) && track != release &&
                !(index(track, release ".") == 1 && patch ~ /^[0-9]+$/)) next
        }
        { sub(/[ \t]+$/, ""); sub(/ \^$/, " ↑"); lines[++n] = $0 }
        END {
            while (n > 0 && lines[n] == "") n--
            for (i = 1; i <= n; i++) print lines[i]
        }' > "$tmp"
    if ! awk -v ch="$3" '$1 == ch { found = 1 } END { exit !found }' "$tmp"; then
        echo "update-transcripts: 'sdk info $2' does not list $3; $1 left unchanged" >&2
        exit 1
    fi
    cat "$tmp" > "$out_dir/$1"
    echo "updated _dev/transcripts/$1"
}

mkdir -p "$out_dir"
sdk_info sdk-info.txt zephyr-xtensa-espressif-esp32s2 "$SDK_NG_CHANNEL"

echo "Run 'make version-check-clean' to check the refreshed transcripts."
