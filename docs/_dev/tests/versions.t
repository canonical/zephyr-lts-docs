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
