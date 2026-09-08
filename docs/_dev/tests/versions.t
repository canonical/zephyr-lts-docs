Documented versions
===================

These tests pin the values declared in docs/versions.env (sourced into
the environment by the cram make target) against the external resources
the documentation links to. They require network access; on a machine
without it, skip them by running cram on the cli/ subdirectory only.

The documented upstream Zephyr version has a live documentation page —
this is the base URL of the zephyr-docs extlink used throughout the
pages:

  $ curl -s -o /dev/null -w "%{http_code}\n" "https://docs.zephyrproject.org/$DOC_UPSTREAM_VERSION/"
  200

The documented release exists as a branch of the manifest repository on
Launchpad — the same tree the canonical-zephyr extlink points at,
browsable at
https://code.launchpad.net/~arctic-tern/zephyr-rtos/+git/zephyr-manifest/+ref/24.04
for DOC_VERSION=24.04:

  $ git ls-remote --heads "$DOC_LP_ZEPHYR_URL/zephyr-manifest" "refs/heads/$DOC_VERSION" | grep -c "refs/heads/$DOC_VERSION"
  1

The branch is what `west init -m "$DOC_LP_ZEPHYR_URL/zephyr-manifest"
--mr "$DOC_VERSION"` fetches, so this test failing means the init
example in the reference documentation would fail for a reader.

Each SDK channel in the Workshop definition has a released revision on
the Snap Store. The store API is queried unauthenticated, so this test
only sees public snaps; a failing test means the channel is empty (or
the snap is still private). The channel map lists a channel only when
it has a released revision for the requested architecture, which is
exactly the condition under which `workshop launch` fails with
"Revision not found":

  $ store_channels() {
  >   curl -s -H "Snap-Device-Series: 16" \
  >     -H "Snap-Device-Architecture: amd64" \
  >     "https://api.snapcraft.io/v2/snaps/info/$1?fields=channel-map"
  > }

The `latest` track is reported by name only (e.g. `"name":"edge"`), so
match the full channel name for tracks like $DOC_VERSION:

  $ store_channels zephyr | grep -c "\"name\":\"$DOC_VERSION/stable\""
  1
  $ store_channels zephyr-sdk-ng | grep -c "\"name\":\"$SDK_NG_CHANNEL\""
  1
  $ store_channels zephyr-amd64 | grep -c "\"name\":\"$SDK_NG_CHANNEL\""
  1
