West CLI transcript tests
=========================

Cram format: lines indented two spaces starting with `$` are executed;
following indented lines are the expected output. Suffix a line with
`(glob)` to treat `*` as a wildcard, which is how irrelevant parts of
the output are excluded from the assertion.

The installed west matches the documented minimum version. The expected
value comes from versions.env ($DOC_WEST_MIN_VERSION is in the
environment, sourced by the cram make target), so bumping the documented
version re-points this assertion automatically:

  $ west --version | grep -q "^West version: v$DOC_WEST_MIN_VERSION\b"

The built-in workspace commands are present in the top-level help. Only
the command roster is relevant here; the surrounding help text is
wildcarded away:

  $ west help
  * (glob)
  built-in commands for managing git repositories:* (glob)
    init:* (glob)
    update:* (glob)
    * (glob)
  other built-in commands:* (glob)
    config:* (glob)
    * (glob)

`west init` usage lines match the documented synopsis:

  $ west init -h
  usage:* (glob)
    west init*-m URL*--mr REVISION*--mf FILE* (glob)
    west init -l*--mf FILE* (glob)
    * (glob)
