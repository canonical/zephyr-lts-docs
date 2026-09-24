# Zephyr 26.04 documentation

This repository contains the documentation for Zephyr 26.04.

Canonical maintains the Zephyr source and its modules in the [Zephyr RTOS
Launchpad project](https://code.launchpad.net/~arctic-tern/zephyr-rtos).

## Build the documentation

Install the Python virtual environment package on Ubuntu:

```shell
sudo apt install python3-venv
```

Build the HTML documentation:

```shell
make -C docs html
```

Run the local documentation server:

```shell
make -C docs run
```

## Testing the documentation

These systems check that the commands and output shown in the docs
match what the real tools do:

| System | Command | Tests live in | Best for |
| ------ | ------- | ------------- | -------- |
| `sphinx.ext.doctest` | `make doctest` | hidden blocks inside the `.rst` pages | single assertions about a tool's state (versions, config values) |
| Cram | `make cram` | `docs/_dev/tests/**/*.t` transcript files | command-plus-output transcripts, multi-command sessions |
| Cross-version leak check | `make version-check` | `docs/_dev/allowed-cross-version.txt` | catching stray references to other LTS releases in the built HTML |

All are ordinary `make` targets (run from `docs/`) and exit non-zero when
the docs and the tools disagree, so they slot straight into CI:

```shell
cd docs
make doctest
make cram
```

They also run as [pre-commit](https://pre-commit.com/) hooks: the
`.pre-commit-config.yaml` at the repository root runs the spelling,
linkcheck, woke, doctest, and cram checks on every commit. To activate the
hooks, run once after `make install` has created the venv:

```shell
docs/.venv/bin/pre-commit install
```

The commands under test must be real executables on the `$PATH`. A command that
needs a Zephyr workspace or network access will fail on a bare CI runner unless
the workflow prepares one first.

### Doctest: assertions inside the pages

[sphinx.ext.doctest](https://www.sphinx-doc.org/en/master/usage/extensions/doctest.html)
runs Python snippets embedded in the pages during the `doctest` build. A
small `sh()` helper (run a shell command, fail on non-zero exit) is defined
once in `doctest_global_setup` in `docs/conf.py` and is available in every
doctest on every page, so asserting against a shell command looks like
this:

```rst
.. testcode::
   :hide:

   print(sh("west --version"), end="")

.. testoutput::
   :hide:
   :options: +ELLIPSIS

   West version: v1...
```

How it works:

* `.. testcode::` — Python code to execute. `sh()` comes from
  `doctest_global_setup` in `docs/conf.py`; use `.. testsetup:: *` to
  define additional helpers local to one page.
* `.. testoutput::` — the expected stdout. `:hide:` keeps it out of the rendered
  page; `:options: +ELLIPSIS` makes `...` a wildcard match.
  uses the ellipsis to match all west versions according to the regex: `v1.*`.

Note that the visible `code-block:: console` examples and these
hidden assertions are separate artifacts: if you reword an example, update
the matching assertion too.

### Cram: golden transcripts

[Cram](https://github.com/brodie/cram) tests are golden tests that compare
 output to expected output transcripts in a `.t` file under `docs/_dev/tests/`.
 Lines indented by two spaces that start with `$` are executed; the indented
 lines that follow are the expected output. Anything not indented is prose, so
 the files read like documentation themselves. See `docs/_dev/tests/cli/west.t`
 for a working example:

```text
The installed west meets the documented minimum version (v1.0+):

  $ west --version
  West version: v1.* (glob)
```

Matching is line-for-line. You can filter output or match with regex:

* **Filter at the command** (preferred): pipe through `grep` or `head`, then
  state the filtered output exactly, for example
  `west help | grep -E '^  (init|update|config):'`.
* **`(glob)` wildcards**: suffix a line with `(glob)` to make `*` match
  anything within that line. A glob line still matches exactly one output
  line — you cannot skip a whole block with one `* (glob)`.

When output legitimately changes, run `cram --interactive _dev/tests` to review
each diff and accept it into the `.t` file, then commit the result. Failed runs
also leave a git-ignored `.t.err` file next to the test containing the actual
output; delete it once you have read the diff.

Because a `.t` file is a tested transcript, you can show it in a page via a
``literalinclude::`` instead of hand-writing an example. For example:

```rst
.. literalinclude:: /_dev/tests/cli/west.t
   :language: console
   :start-after: minimum version
   :end-before: built-in workspace commands
```

### Documented versions: one source of truth

The versions this documentation describes are defined once in
`docs/versions.env`.

* `docs/conf.py` parses it to generate the `rst_epilog` substitution
  macros and the `extlinks` URLs, and injects the values as `DOC_*`
  Python variables into every doctest.
* `make cram` sources it into the environment, so cram tests reference
  `$DOC_WEST_MIN_VERSION` etc. instead of hardcoding versions.
* `docs/_dev/tests/versions.t` pins the values against the live
  resources they name: the upstream docs page for
  `$DOC_UPSTREAM_VERSION` and the Launchpad manifest branch for
  `$DOC_VERSION`. These tests need network access.

To move the documentation to a new release, bump `docs/versions.env`.
Prose written with the macros updates automatically, and any test or
tool that no longer matches the documented version fails.

### Which one should I use?

* Use doctest when asserting a property of the environment; such as a version, a
  config value, that a command exists.
* Use a cram test when you want to document a command's output or a sequence of
  commands and check that the output matches the transcript exactly. You can write to a
  cram transcript and import the text with a `literalinclude` in the page.

### Cross-version leak check

`make version-check` scans the built HTML in `docs/_build/` and fails if any
`YY.MM` release token falls outside the current release family. The current
family is `DOC_VERSION` (from `docs/versions.env`) plus any `DOC_VERSION.N`
patch tag: for `DOC_VERSION=26.04`, the check accepts `26.04`, `26.04.0` (the
current `SOURCE_TAG`), and future `26.04.1`, `26.04.2`, etc. Everything else is
a failure: interim releases (`26.10`), other LTS releases (`24.04`, `28.04`), RC
suffixes on the current release (`26.04-rc1`), and any `-rc`/patch variant of
another release. The target only scans the existing build — run
`make version-check-clean` locally to rebuild from scratch first so the scan
reflects exactly what the current sources produce. CI calls plain
`make version-check` right after its `make html` step, which is already a
fresh build.

Detection tokenises `YY.MM(.PATCH)?(-SUFFIX)?` with lookaround boundaries that
reject decimals like `10.044`, sizes like `63.07MB`, and version fragments
preceded by other digits. Months are filtered to `01`-`12`, which discards SVG
coordinates like `19.78` or `15.42`, and tokens inside quoted HTML attributes
(`y1="14.05"`) are dropped as well.

Legitimate cross-family mentions — for example, `snap info` output that still
lists an older release's SDK tracks, or a release note that deliberately refers
to a prior version — belong in `docs/_dev/allowed-cross-version.txt`. Each entry
pins one whole trimmed line to one built HTML path, so if the underlying content
changes shape the check re-fires and forces the entry to be re-reviewed. The
failure message tells you the exact line to add.


## Contribute

Read [CONTRIBUTING.md](CONTRIBUTING.md) before you propose a change.

Report security problems as described in [SECURITY.md](SECURITY.md).
