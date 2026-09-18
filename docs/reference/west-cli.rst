.. _ref-west-cli:

West (CLI)
==========


The **west** command-line tool exposes the following commands, each with its own
set of options and flags.

This page is split into two groups of commands. The first group is built into
west itself. The second group consists of *extension commands*, provided by the
``zephyr`` repository in the workspace.

.. This doctest asserts that the installed west matches the minimum
   version documented for this release (DOC_WEST_MIN_VERSION comes from
   versions.env via conf.py).

.. testcode::
   :hide:

   assert sh("west --version").startswith(
       f"West version: v{DOC_WEST_MIN_VERSION}"
   )


Global Flags
------------

These options precede the command name, for example
``west -v build -b reel_board``.

-h, --help

   Print the help message. Also works after a command name, as in
   ``west build -h``.

-v, --verbose

   Increase output verbosity. Can be given multiple times.

-q, --quiet

   Decrease output verbosity. Can be given multiple times.

-V, --version

   Print the west version and exit.

-z <path>, --zephyr-base <path>

   Set the path to the zephyr repository for this invocation,
   overriding configuration and the ``ZEPHYR_BASE`` environment
   variable.


Workspace commands
------------------

west init
~~~~~~~~~

Create a west workspace provided a west manifest repository or manifest file.
Run `west update`_ to fetch the remaining projects.


**Usage**

.. code-block:: text

   west init [-m URL] [--mr REVISION] [--mf FILE] [DIRECTORY]
   west init -l [--mf FILE] DIRECTORY

**Description**

Creates a west workspace in ``DIRECTORY`` (the current directory if omitted).

**Examples**

Clone a manifest repository from ``URL`` and check out ``REVISION``. This example clones
the |zephyr-lts| release into the current directory:

.. code-block:: console
   :substitutions:

   $ west init -m |zephyr-lts-url|/zephyr-manifest --mr |doc-version|

Create a workspace around a local manifest repository that's already present
without cloning anything:

.. code-block:: console

   $ west init -l /path/to/my-manifest-repo

**Flags**

-m <url>, --manifest-url <url>

   Manifest repository URL. Defaults to the upstream Zephyr :upstream-zephyr:`repository <zephyr>`.

--mr <rev>, --manifest-rev <rev>

   Initial manifest repository revision to check out. Defaults to
   the repository's default branch.

--mf <file>, --manifest-file <file>

   Name of the manifest file in the repository. Defaults to
   ``west.yml``.

-l, --local

   Use an existing local manifest repository instead of cloning one.

**Notes**

* The workspace records the manifest repository location in the
  ``manifest.path`` and ``manifest.file`` entries of ``.west/config``;
  both can be changed later with `west config`_.


**See also**

* :zephyr-docs:`upstream west init documentation <develop/west/built-in.html>`

west update
~~~~~~~~~~~

Update the projects in the workspace to match the manifest.

**Usage**

.. code-block:: text

   west update [-f {always,smart}] [-k] [-r] [-n]
               [--group-filter FILTER] [--stats] [PROJECT ...]

**Description**

Parses the manifest file and synchronizes each active project to the
revision the manifest declares.

Giving ``PROJECT`` arguments (names from the manifest, or paths in the
workspace) restricts the update to those projects.

**Examples**

Update all projects:

.. code-block:: console

   $ west update

Update only the ``hal_stm32`` project:

.. code-block:: console

   $ west update hal_stm32

**Flags**

-f MODE, --fetch MODE

   ``MODE`` is ``smart`` (default), which skips fetching locally available
   revisions, or ``always``, which fetches from every project remote.

-k, --keep-descendants

   Keep a locally checked out branch if it points to a descendant of the new
   ``manifest-rev``.

-r, --rebase

   Rebase a locally checked out branch onto the new ``manifest-rev``. Fails on a
   Git conflict.

-n, --narrow

   Shallowly fetch only the project's manifest revision.

--group-filter=<filter>

   Override the manifest's group filter for this update only. Use
   ``--group-filter=<value>`` syntax (with ``=``) when disabling a group, e.g.
   ``--group-filter=-optional``.

--stats

   Print performance statistics.

**Notes**

* With a clean working tree, ``west update`` never fails. Local branches are
  left untouched.

**See also**

* :zephyr-docs:`upstream west update documentation <develop/west/built-in.html>`


Project commands
----------------

west list
~~~~~~~~~

Print information about the projects in the manifest file.

**Usage**

.. code-block:: text

   west list [-f FORMAT] [PROJECT ...]

**Description**

Prints one line per project. ``--format`` is a Python format string with access
to project attributes such as ``name``, ``path``, ``revision``, ``url``, and
``clone_depth``.

**Examples**

List all projects with their revisions:

.. code-block:: console

   $ west list -f "{name}: {revision}"

**Flags**

-f <fmt>, --format <fmt>

   Format string for each line of output. Run ``west list -h`` for
   the full set of available fields.

-a, --all

   Include projects that are inactive per the group filter.


west manifest
~~~~~~~~~~~~~

Manage the manifest file.

**Usage**

.. code-block:: text

   west manifest {--validate | --resolve | --freeze | --path} ...

**Description**

One of the following actions is required:

--validate

   Load the manifest and report an error if it is invalid. Exits
   silently on success.

--resolve

   Print the manifest with all imports resolved, as west sees it.

--freeze

   Like ``--resolve``, but with every project revision replaced by
   its currently fetched SHA. Use this to pin a workspace.

--path

   Print the path to the top-level manifest file.

**Examples**

Pin all project revisions to exact SHAs:

.. code-block:: console

   $ west manifest --freeze > pinned-west.yml

**See also**

* :zephyr-docs:`upstream manifest command documentation <develop/west/manifest.html>`


west compare
~~~~~~~~~~~~

Compare the state of the workspace against the manifest.

**Usage**

.. code-block:: text

   west compare [PROJECT ...]

**Description**

Prints one line per project that differs from the manifest: projects
with no checked-out ``manifest-rev``, projects checked out at a
different revision, and so on. A clean workspace matching the manifest
prints nothing.


west diff
~~~~~~~~~

Run ``git diff`` in each project repository.

**Usage**

.. code-block:: text

   west diff [PROJECT ...] [-- DIFF_ARGS ...]

**Description**

Runs ``git diff`` in the local clone of each given project (or all
projects). Arguments after ``--`` are passed to ``git diff`` verbatim.


west status
~~~~~~~~~~~

Run ``git status`` in each project repository.

**Usage**

.. code-block:: text

   west status [PROJECT ...]

**Description**

Prints the working tree status of each project relative to its
``manifest-rev``.


west forall
~~~~~~~~~~~

Run a shell command in each project repository.

**Usage**

.. code-block:: text

   west forall -c COMMAND [PROJECT ...]

**Examples**

Print the current branch of every project:

.. code-block:: console

   $ west forall -c "git branch --show-current"


west grep
~~~~~~~~~

Run ``git grep`` in each project repository.

**Usage**

.. code-block:: text

   west grep [PROJECT ...] [-- GREP_ARGS ...] PATTERN

**Examples**

Search all project sources for a Kconfig symbol:

.. code-block:: console

   $ west grep -- CONFIG_SERIAL


Configuration commands
----------------------

west config
~~~~~~~~~~~

Get or set west configuration options.

**Usage**

.. code-block:: text

   west config [--local | --global | --system] [-l | NAME [VALUE]]
   west config -d NAME
   west config -a NAME VALUE

**Description**

Reads and writes options in the local (workspace), global (per-user),
and system configuration files. Run with a ``NAME`` to print a value,
with ``NAME VALUE`` to set one, and with no arguments to list all
settings and where they are defined.

Notable options include ``manifest.path``, ``manifest.file``,
``manifest.group-filter``, ``update.fetch``, ``build.board``,
``build.pristine``, ``build.cmake-args``, and ``build.dir-fmt``.

**Examples**

Build for ``reel_board`` by default:

.. code-block:: console

   $ west config build.board reel_board

Always pass ``-DCMAKE_EXPORT_COMPILE_COMMANDS=ON`` to CMake:

.. code-block:: console

   $ west config build.cmake-args -- "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"

Use a different manifest file for the workspace:

.. code-block:: console

   $ west config manifest.file my-manifest.yml

Point the workspace at a different manifest repository (the path is
relative to the top-level directory of the workspace):

.. code-block:: console

   $ west config manifest.path ../my-manifest-repo

**Flags**

--local, --global, --system

   Restrict the operation to one configuration file. Without one of
   these, ``west config`` reads the merged view and writes to the
   local file.

-l, --list

   List all options and their values.

-d <name>, --delete <name>

   Delete an option.

-D <name>, --delete-all <name>

   Delete an option from all configuration files where it is set.

-a, --append

   Append ``<value>`` to ``<name>``'s value instead of replacing it, as
   in ``west config -a <name> <value>``.

**See also**

* :zephyr-docs:`upstream configuration documentation <develop/west/config.html>`


west topdir
~~~~~~~~~~~

Print the top-level directory of the current west workspace. Fails
outside a workspace.


west help
~~~~~~~~~

Print help for a command, or list all commands available in the current
workspace, including extension commands. ``west help <cmd>`` is
equivalent to ``west <cmd> -h``.


Build, flash, and debug commands
--------------------------------

The following commands are Zephyr :zephyr-docs:`extension commands
<develop/west/zephyr-cmds.html>`. They are defined in the Zephyr repository's
:upstream-zephyr:`scripts/west_commands <zephyr/tree/main/scripts/west_commands>`
directory.

west boards
~~~~~~~~~~~

List the boards supported by Zephyr |zephyr-lts|.

**Usage**

.. code-block:: text

   west boards [-f FORMAT] [-n NAME]

**Examples**

List architectures and board names:

.. code-block:: console

   $ west boards -f "{arch}:{name}"

**Flags**

-f <fmt>, --format <fmt>

   Format string for the output. Run ``west boards -h`` for the
   available fields.

-n <name>, --name <name>

   List only boards whose name contains the given string.


west build
~~~~~~~~~~

Build a Zephyr application.

**Usage**

.. code-block:: text

   west build [OPTIONS] [SOURCE_DIR] [-- CMAKE_ARGS ...]

**Description**

Configures (with CMake) and builds (with Ninja or Make) the application
in ``SOURCE_DIR``, which defaults to the current directory. The build
directory defaults to ``./build`` and can be set with ``--build-dir`` or
the ``build.dir-fmt`` configuration option.

``west build`` avoids re-running CMake if a build system is already present in
the build directory. Arguments after ``--`` are passed to CMake. Any arguments
after ``--`` forces a CMake re-run. To make CMake arguments permanent, use the
``build.cmake-args`` configuration option instead (see `west config`_).

**Examples**

Build the Hello World sample for ``qemu_x86``:

.. code-block:: console

   $ west build -b qemu_x86 samples/hello_world

Rebuild in a pristine build directory:

.. code-block:: console

   $ west build -p always -b reel_board samples/hello_world

Merge a Kconfig fragment into the build:

.. code-block:: console

   $ west build -- -DEXTRA_CONF_FILE=debug.conf

**Flags**

-b <board>, --board <board>

   Board to build for. Defaults to the ``build.board`` configuration option,
   then to the ``BOARD`` cached in an existing build directory.

-d <dir>, --build-dir <dir>

   Build directory to create or use.

-t <target>, --target <target>

   Build system target to run instead of the default (e.g.
   ``run``, ``menuconfig``, ``pristine``, ``help``).

-p, --pristine=MODE

   Make the build directory pristine (as if newly created) before building.
   ``MODE`` is optional: ``always`` (the default when the flag is given),
   ``auto``, or ``never``.

-c, --cmake

   Force a CMake re-run without making the directory pristine.

-o <opt>, --build-opt <opt>

   Pass an option to the underlying build tool. Use
   ``-o=<opt>`` syntax, e.g. ``-o=--keep-going``. Repeatable.

--sysbuild

   Use the multi-image :zephyr-docs:`sysbuild
   <build/sysbuild/index.html>` system.

--domain <name>

   In a ``--sysbuild`` build, build only the given domain.

-S <snippet>, --snippet <snippet>

   Apply a :zephyr-docs:`build system snippet <build/snippets/using.html>` to
   the build. Repeatable.

**Notes**

* ``--pristine=auto`` detects some situations that require a pristine
  build directory (such as switching boards) and handles them
  automatically.
* Use the verbosity option: ``west -v build`` to print the exact CMake and
  compiler commands.


**See also**

* :zephyr-docs:`upstream west build documentation <develop/west/build-flash-debug.html>`


west flash
~~~~~~~~~~

Flash a built Zephyr application to a board.

**Usage**

.. code-block:: text

   west flash [-d BUILD_DIR] [-r RUNNER] [--skip-rebuild]
              [--elf-file FILE | --hex-file FILE | --bin-file FILE]
              [--erase] [-- RUNNER_ARGS ...]

**Description**

Rebuilds (unless ``--skip-rebuild`` is given) and flashes the
application from the build directory using a board-specific *runner*.
Arguments after ``--`` are passed to the runner itself.

**Examples**

Flash with the board's default runner:

.. code-block:: console

   $ west flash

Flash with J-Link, erasing the device first:

.. code-block:: console

   $ west flash -r jlink --erase

**Flags**

-d <dir>, --build-dir <dir>

   Build directory to flash from.

-r <runner>, --runner <runner>

   Runner to use (one of: ``jlink``, ``openocd``, ``pyocd``, ``nrfjprog``). Run
   ``west flash --context`` for runner-specific options, or consult the board
   documentation for supported runners.

--skip-rebuild

   Do not rebuild before flashing.

-i <id>, --dev-id <id>

   Select the debug probe by serial number or ID when several are
   connected.

--elf-file <file>, --hex-file <file>, --bin-file <file>

   Override the file to flash.

--erase

   Mass-erase the flash before programming.

**See also**

* :zephyr-docs:`upstream west flash documentation <develop/west/build-flash-debug.html>`


west debug
~~~~~~~~~~

Attach a debugger to a connected board.

**Usage**

.. code-block:: text

   west debug [-d BUILD_DIR] [-r RUNNER] [--skip-rebuild]
              [--elf-file FILE] [-- RUNNER_ARGS ...]

**Description**

Flashes the application (unless ``--skip-rebuild`` is given) and starts
a GDB debugging session on the target via the board's runner. Flags
mirror `west flash`_.


west debugserver
~~~~~~~~~~~~~~~~

Start a debug server (a GDB server via OpenOCD or J-Link) without attaching a
debugger. Accepts the same runner and build-directory flags as `west debug`_.


west attach
~~~~~~~~~~~

Attach a debugger to a running target without flashing or restarting it.
Accepts the same runner and build-directory flags as `west debug`_.

west sign
~~~~~~~~~

Create a signed version of a built application binary.

**Usage**

.. code-block:: text

   west sign -t imgtool -d BUILD_DIR [--bin] [--hex] [-- ARGS ...]

**Description**

Runs a signing tool over the build output, producing signed binaries for use
with a bootloader such as MCUboot. Only MCUBoot's imgtool is supported in Zephyr
|zephyr-lts|; arguments after ``--`` are passed to it verbatim.

**Examples**

Produce a signed binary and hex file:

.. code-block:: console

   $ west sign -d build -t imgtool --bin --hex

**See also**

* :zephyr-docs:`upstream west sign documentation <develop/west/sign.html>`


Extension commands
------------------

west spdx
~~~~~~~~~

Generate SPDX 2.3 software bill-of-materials documents for a build.

**Usage**

.. code-block:: text

   west spdx --init -d BUILD_DIR     # once per build directory
   west build -d BUILD_DIR ...       # build into it
   west spdx -d BUILD_DIR            # generate the documents

**Description**

Writes ``app.spdx``, ``zephyr.spdx``, ``build.spdx``, and
``modules-deps.spdx`` into ``BUILD_DIR/spdx/``, recording file hashes
and ``SPDX-License-Identifier`` comments. Requires
``CONFIG_BUILD_OUTPUT_META=y``.

**Flags**

-d <dir>, --build-dir <dir>

   Build directory.

--init

   Pre-populate the build directory with the CMake metadata SPDX
   generation needs; build into it afterwards.

-n <prefix>, --namespace-prefix <prefix>

   Prefix for the SPDX document namespaces. A random UUID namespace
   is generated if omitted.

-s <dir>, --spdx-dir <dir>

   Write the documents to a directory other than
   ``BUILD_DIR/spdx/``.

--analyze-includes

   Also record the header files each source file includes (slower;
   performs a dry-run compile per file).

--include-sdk

   With ``--analyze-includes``, additionally produce ``sdk.spdx``
   for headers included from the Zephyr SDK.


west blobs
~~~~~~~~~~

List, fetch, or delete the binary blobs declared by modules.

**Usage**

.. code-block:: text

   west blobs {list|fetch|clean} [-f FORMAT] [MODULE ...]

**Description**

Some modules declare binary blobs (prebuilt libraries, firmware images)
in their ``module.yml``. Fetched blobs are stored in the module's
``zephyr/blobs/`` directory. Without ``MODULE`` arguments, all modules
are scanned.

**Examples**

List all declared blobs with their type and path:

.. code-block:: console

   $ west blobs list -f '{module}: {type} {path}'


west bindesc
~~~~~~~~~~~~

Read binary descriptors embedded in a built image.

**Usage**

.. code-block:: text

   west bindesc {search|custom_search|dump|list} FILE ...

**Description**

Reads :zephyr-docs:`binary descriptors
<services/binary_descriptors/index.html>` from ``.bin``, ``.hex``,
``.elf``, and ``.uf2`` files. ``search`` looks up a standard descriptor
by name, ``custom_search`` looks up a custom descriptor by type and ID,
``dump`` prints all descriptors, and ``list`` prints the known standard
descriptor names.

**Examples**

.. code-block:: console

   $ west bindesc search KERNEL_VERSION_STRING build/zephyr/zephyr.bin


west twister
~~~~~~~~~~~~

Run the :zephyr-docs:`Twister <develop/test/twister.html>` test runner
through west. Arguments are passed to Twister directly.

**Examples**

.. code-block:: console

   $ west twister -T tests/ztest/base


west zephyr-export
~~~~~~~~~~~~~~~~~~

Register the Zephyr repository as a package in the CMake user package registry.
After running this, applications outside the workspace can locate Zephyr with
``find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})``.


west completion
~~~~~~~~~~~~~~~

Print a shell completion script for west.

**Usage**

.. code-block:: text

   west completion {bash|zsh|fish}

**Examples**

Enable completion in the current Bash session:

.. code-block:: console

   $ source <(west completion bash)
