Documented versions
===================

These tests pin the values declared in docs/versions.env (sourced into
the environment by the cram make target) against the external resources
the documentation links to. They require network access; on a machine
without it, skip them by running cram on the cli/ subdirectory only.

Each assertion below is silent on success. On failure it prints a
diagnostic explaining what was actually found (HTTP status, available
branches, or available channels) instead of a bare mismatched number, so
you don't have to re-run the underlying curl/git command by hand to see
why.

The documented upstream Zephyr version has a live documentation page —
this is the base URL of the zephyr-docs extlink used throughout the
pages:

  $ assert_http_ok() {
  >   url="$1"
  >   code=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  >   [ "$code" = "200" ] && return 0
  >   echo "$url: HTTP $code"
  >   return 1
  > }

  $ assert_http_ok "https://docs.zephyrproject.org/$DOC_UPSTREAM_VERSION/"

The documented release exists as a branch of the manifest repository on
Launchpad — the same tree the canonical-zephyr extlink points at,
browsable at
https://code.launchpad.net/~arctic-tern/zephyr-rtos/+git/zephyr-manifest/+ref/24.04
for DOC_VERSION=24.04. The branch is what `west init -m
"$DOC_LP_ZEPHYR_URL/zephyr-manifest" --mr "$DOC_VERSION"` fetches, so
this test failing means the init example in the reference documentation
would fail for a reader:

  $ assert_branch() {
  >   repo="$1"; branch="$2"
  >   if git ls-remote --heads "$repo" "refs/heads/$branch" \
  >       | grep -q "refs/heads/$branch"; then
  >     return 0
  >   fi
  >   available=$(git ls-remote --heads "$repo" \
  >     | sed 's#.*refs/heads/##' | sort -u | paste -sd, -)
  >   echo "$repo: branch '$branch' not found (available: ${available:-none})"
  >   return 1
  > }

  $ assert_branch "$DOC_LP_ZEPHYR_URL/zephyr-manifest" "$DOC_VERSION"

Each SDK channel in the Workshop definition has a released revision on
the Snap Store. The store API is queried unauthenticated, so this test
only sees public snaps; a failing test means the snap is missing, or
the channel is empty (or still private). The channel map lists a
channel only when it has a released revision for the requested
architecture, which is exactly the condition under which `workshop
launch` fails with "Revision not found":

  $ assert_channel() {
  >   snap="$1"; channel="$2"
  >   json=$(curl -s -H "Snap-Device-Series: 16" \
  >     -H "Snap-Device-Architecture: amd64" \
  >     "https://api.snapcraft.io/v2/snaps/info/$snap?fields=channel-map")
  >   if echo "$json" | jq -e 'has("error-list")' >/dev/null 2>&1; then
  >     echo "$snap: not found in the Snap Store"
  >     return 1
  >   fi
  >   if echo "$json" | jq -e --arg c "$channel" \
  >       '.["channel-map"] | any(.channel.name == $c)' >/dev/null 2>&1; then
  >     return 0
  >   fi
  >   available=$(echo "$json" | jq -r '.["channel-map"][].channel.name' \
  >     | sort -u | paste -sd, -)
  >   echo "$snap: channel '$channel' not published (available: ${available:-none})"
  >   return 1
  > }

The `latest` track is reported by name only (e.g. `"name":"edge"`), so
match the full channel name for tracks like $DOC_VERSION:

  $ assert_channel zephyr "$DOC_VERSION/stable"
  $ assert_channel zephyr-sdk-ng "$SDK_NG_CHANNEL"
  $ assert_channel zephyr-amd64 "$SDK_NG_CHANNEL"
