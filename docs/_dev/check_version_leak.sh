#!/usr/bin/env bash
# Fails if the built HTML mentions any Ubuntu-style YY.MM release
# version outside the current release family, unless the mention is
# listed in _dev/allowed-cross-version.txt.
#
# The current release family is `DOC_VERSION` (from versions.env) and any
# `DOC_VERSION.N` patch tag (26.04 accepts 26.04, 26.04.0, 26.04.1, ...). Every
# other YY.MM token in the built HTML is a failure. For example, interim
# releases (26.10), other LTS releases (24.04, 28.04), RC suffixes on the
# current release (26.04-rc1), and RC/patch-suffixed variants of any other
# release.
#
# This script scans the rendered artifact rather than the .rst sources, so
# text introduced via substitutions, extlinks, include:: directives, or
# copied transcripts is caught too. It runs after `make html`.
#
# Legitimate cross-version mentions -- for example, `snap info` output
# showing that the SDK snap still publishes an older LTS's tracks --
# belong in _dev/allowed-cross-version.txt. Each entry pins one
# whole-line occurrence to one HTML path, so if the underlying output
# changes shape the check re-fires and forces a review.
#
# Exit status:
#   0  no un-allowlisted hits
#   1  usage / setup error
#   2  hits found (details printed)

set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
docs_dir=$(cd -- "$script_dir/.." && pwd)
build_dir="${DOCS_BUILDDIR:-$docs_dir/_build}"
versions_env="$docs_dir/versions.env"
allowlist="$script_dir/allowed-cross-version.txt"

if [ ! -d "$build_dir" ]; then
    echo "check-version-leak: no build at $build_dir; run 'make html' first" >&2
    exit 1
fi
if [ ! -f "$versions_env" ]; then
    echo "check-version-leak: $versions_env not found" >&2
    exit 1
fi

# shellcheck disable=SC1090
set -a; . "$versions_env"; set +a
if [ -z "${DOC_VERSION:-}" ]; then
    echo "check-version-leak: DOC_VERSION not set by $versions_env" >&2
    exit 1
fi

# Definition of a leak or failure
#
# Any YY.MM release token in the built HTML that isn't part of the current
# release family is a candidate leak. The token allows an optional .PATCH and an
# optional -SUFFIX. For example `26.04.1` is accepted, but `26.04.1-rc1` are
# recognised as *distinct* from `26.04` and reported
#
# Decimals like `10.044`, sizes like `63.07MB`, and version fragments preceded
# by another number segment are rejected. This uses PCRE (`grep -oP`), which is
# available on the GNU coreutils grep shipped with every supported Ubuntu.
#
# Two further filters run:
#   * month must be 01-12, which rejects SVG/CSS coordinates like
#     "19.78" or "15.42" while accepting every real Ubuntu release
#     cadence (04, 10) as well as any future month;
#   * tokens sitting inside a double-quoted HTML attribute value
#     (e.g. `<line y1="14.05">`) are dropped in the reporting step
#     below, since real version references in prose/URLs never take
#     that shape.
#
#
version_regex='(?<![.0-9A-Za-z-])[0-9]{2}\.[0-9]{2}(?:\.[0-9]+)?(?:-[a-z0-9]+)?(?![.0-9A-Za-z-])'
current_family_regex="^${DOC_VERSION//./\\.}(\\.[0-9]+)?$"
mapfile -t other_versions < <(
    grep -rhoP "$version_regex" "$build_dir" \
        --include='*.html' \
        --exclude='search.html' \
        --exclude='searchindex.js' \
        --exclude='genindex.html' \
    | awk -F. '{ split($2, m, /[-]/); if (m[1] >= 1 && m[1] <= 12) print }' \
    | sort -u \
    | grep -vE "$current_family_regex" || true
)

if [ "${#other_versions[@]}" -eq 0 ]; then
    exit 0
fi

# Build a PCRE alternation like
# `(?<![.0-9A-Za-z-])(24\.04|26\.10|26\.04-rc1)(?![.0-9A-Za-z-])` for
# a single grep pass. The lookarounds mirror the detection step
# above so decimals like `10.044`, sizes like `63.07MB`, and
# prefixes like `26.04` inside `26.04.1` don't collide with these
# exact-token matches. Alternatives are sorted longest-first because
# PCRE alternation is ordered: `24.04` would otherwise shadow
# `24.04.1-rc2` when the trailing lookahead forces backtracking.
pattern_body=$(printf '%s\n' "${other_versions[@]}" \
    | sed 's/\./\\./g' \
    | awk '{ print length($0), $0 }' | sort -rn | cut -d' ' -f2- \
    | paste -sd'|' -)
pattern="(?<![.0-9A-Za-z-])(?:${pattern_body})(?![.0-9A-Za-z-])"

# Extract candidate hits as "<relative-path>:<trimmed-line>". Matching
# and allowlisting on the trimmed line ignores incidental HTML indent
# changes between builds while still catching content changes.
tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

(
    cd "$build_dir"
    grep -rnP "$pattern" . \
        --include='*.html' \
        --exclude='search.html' \
        --exclude='searchindex.js' \
        --exclude='genindex.html' \
    || true
) | sed -E 's#^\./##' | while IFS=: read -r path _lineno rest; do
    # NOTE: assumes built HTML paths never contain ':' (true for Sphinx
    # dirhtml output); 'rest' reassembles everything after the line number,
    # so ':' in the *content* is safe.
    trimmed=$(printf '%s' "$rest" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')
    # Suppress tokens sitting inside a quoted HTML attribute value like
    # `y1="14.05"`, which are SVG/CSS coordinates rather than version
    # references. If a line contains at least one *unquoted* occurrence
    # of any candidate version, it's still reported.
    unquoted=$(printf '%s' "$trimmed" \
        | sed -E 's/="[^"]*"//g; s/='"'"'[^'"'"']*'"'"'//g' \
        | grep -oP "$pattern" || true)
    if [ -z "$unquoted" ]; then
        continue
    fi
    printf '%s\t%s\n' "$path" "$trimmed"
done > "$tmp"

# Load allowlist. Format: "<relative-path>:<trimmed-line>" per line,
# blanks and #-comments ignored. Only lines *starting* with '#' (after
# optional whitespace) are comments, so entry content may contain '#'
# freely.
allowed=$(mktemp)
trap 'rm -f "$tmp" "$allowed"' EXIT
if [ -f "$allowlist" ]; then
    sed -E 's/^[[:space:]]*#.*$//' "$allowlist" \
        | grep -vE '^[[:space:]]*$' \
        | awk -F: '{
            path=$1; sub(/^[[:space:]]+/,"",path); sub(/[[:space:]]+$/,"",path);
            $1=""; sub(/^:/,""); line=$0; sub(/^[[:space:]]+/,"",line);
            printf "%s\t%s\n", path, line
          }' > "$allowed"
fi

# A hit is un-allowlisted if the (path, trimmed-line) pair isn't in the
# allowlist. sort|uniq collapses duplicate lines within the same page.
unallowed=$(sort -u "$tmp" | grep -Fxv -f "$allowed" || true)

if [ -z "$unallowed" ]; then
    exit 0
fi

# Emphatic failure banner. Colors only when stderr is a terminal, so
# CI logs stay plain; the ASCII bars and the FAIL/FAILED words carry
# the signal in either case.
if [ -t 2 ]; then
    red=$'\033[1;31m'; bold=$'\033[1m'; reset=$'\033[0m'
else
    red=''; bold=''; reset=''
fi
bar='================================================================'
hit_count=$(printf '%s\n' "$unallowed" | wc -l | tr -d ' ')

# Summarize the YY.MM values that actually landed as un-allowlisted
# hits (rather than every candidate the initial scan produced), since
# candidates dropped by the attribute-quote filter shouldn't be
# advertised as "detected".
detected=$(printf '%s\n' "$unallowed" \
    | grep -oP "$version_regex" \
    | awk -F. '{ split($2, m, /[-]/); if (m[1] >= 1 && m[1] <= 12) print }' \
    | sort -u \
    | grep -vE "$current_family_regex" \
    | paste -sd' ' -)

{
    echo
    echo "${red}${bar}${reset}"
    echo "${red}${bold}  FAIL: check-version-leak found $hit_count cross-version reference(s)${reset}"
    echo "${red}${bar}${reset}"
    echo
    echo "  DOC_VERSION=$DOC_VERSION"
    echo "  other YY.MM versions detected: ${detected:-<none>}"
    echo
    echo "  Un-allowlisted hits (path <TAB> line):"
    printf '%s\n' "$unallowed" | sed 's/^/    /'
    echo
    echo "  Every YY.MM in the built HTML must be in the current release"
    echo "  family (DOC_VERSION or DOC_VERSION.N). If a hit is legitimate"
    echo "  (for example, real 'snap info' output showing older release"
    echo "  tracks that are still published, or release notes deliberately"
    echo "  referring to a prior release), add it to:"
    echo "    $allowlist"
    echo "  One entry per line, format: <relative-html-path>:<trimmed-line>"
    echo
    echo "${red}${bar}${reset}"
    echo "${red}${bold}  check-version-leak: FAILED${reset}"
    echo "${red}${bar}${reset}"
} >&2
exit 2
