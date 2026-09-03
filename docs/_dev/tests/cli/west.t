West CLI transcript tests
=========================

Cram format: lines indented two spaces starting with `$` are executed;
following indented lines are the expected output. Suffix a line with
`(glob)` to treat `*` as a wildcard, which is how irrelevant parts of
the output are excluded from the assertion.

The installed west meets the documented minimum version (v1.0+,
matching the Zephyr 3.7 LTS):

  $ west --version
  West version: v1.* (glob)

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
