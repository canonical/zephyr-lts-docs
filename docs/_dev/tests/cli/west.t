West CLI transcript tests
=========================

Cram format: lines indented two spaces starting with `$` are executed;
following indented lines are the expected output. Matching is
line-for-line, so the idiom for "only some output is relevant" is to
filter at the command (grep/head) and then exact-match the filtered
output. `(glob)` suffixes allow `*` wildcards within a line.

The installed west matches the documented minimum version. The expected
value comes from versions.env ($DOC_WEST_MIN_VERSION is in the
environment, sourced by the cram make target), so bumping the documented
version re-points this assertion automatically:

  $ west --version | grep -q "^West version: v$DOC_WEST_MIN_VERSION\b"

The built-in workspace commands documented in this chapter are present
in the top-level help:

  $ west help | grep -E '^  (init|update|config):'
    init:                 create a west workspace
    update:               update projects described in west manifest
    config:               get or set config file values

`west init` synopsis lines match the real help output:

  $ west init -h | grep -E '^\s+west init'
    west init [-m URL] [--mr REVISION] [--mf FILE] [-o=GIT_CLONE_OPTION] [directory]
    west init -l [--mf FILE] directory
