#!/usr/bin/env bash
# Regenerates the command-output examples in _dev/transcripts/ by running the
# real commands. Pages show them with literalinclude, so the docs build never
# runs these tools. Run it with `make transcripts`, then `make
# version-check-clean`: a refresh can change lines pinned in
# _dev/allowed-cross-version.txt.
#
# Requires the sdk CLI (from the workshop snap) and network access.
#
# Exit status:
#   0  transcripts updated
#   1  missing tool or unexpected output (transcripts left unchanged)

set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
out_dir="$script_dir/transcripts"

if ! command -v sdk >/dev/null; then
    echo "update-transcripts: sdk not found; install the workshop snap" >&2
    exit 1
fi

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

# sdk_info FILE SDK writes `sdk info SDK` to FILE as a terminal shows it. When
# piped, sdk prints "^" for "same revision as the row above" where a terminal
# shows "↑", which the page text describes. The INSTALLED section lists the
# caller's own workshops, so it is dropped to keep the transcript the same on
# every machine. awk reads to the end rather than exiting early, so sdk never
# writes to a closed pipe.
sdk_info() {
    sdk info "$2" | awk '
        /^INSTALLED/ { installed = 1 }
        installed { next }
        { sub(/[ \t]+$/, ""); sub(/ \^$/, " ↑"); lines[++n] = $0 }
        END {
            while (n > 0 && lines[n] == "") n--
            for (i = 1; i <= n; i++) print lines[i]
        }' > "$tmp"
    if ! grep -q '^CHANNELS' "$tmp"; then
        echo "update-transcripts: 'sdk info $2' printed no CHANNELS table; $1 left unchanged" >&2
        exit 1
    fi
    cat "$tmp" > "$out_dir/$1"
    echo "updated _dev/transcripts/$1"
}

mkdir -p "$out_dir"
sdk_info sdk-info.txt zephyr-xtensa-espressif-esp32s2

echo "Run 'make version-check-clean' to check the refreshed transcripts."
