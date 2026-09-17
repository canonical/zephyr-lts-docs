.. _ref-west-yml:

West manifest
=============

The west manifest file defines your Zephyr workspace. The manifest file
specifies the Git remotes, Git repositories (called *projects*), and project
attributes that Zephyr's meta-tool :zephyr-docs:`west <develop/west/index.html>`,
uses to build, manage and update the workspace.

This page documents the fields accepted in a west manifest file. For an
introduction to the concepts behind manifests, projects, and imports, see the
upstream documentation on :zephyr-docs:`West Manifests
<develop/west/manifest.html>`.

Filename and location
----------------------

A west workspace has exactly one active manifest file, tracked by the
``manifest.path`` and ``manifest.file`` entries in the workspace
``.west/config`` file. By convention this file is named ``west.yml`` and lives
at the root of the *manifest repository*, the Git repository that ``west init``
clones first when setting up a workspace. Zephyr's own ``west.yml``, at the root
of the `zephyr <https://github.com/zephyrproject-rtos/zephyr/tree/v3.7.3-rc1>`_
repository is the manifest that assembles the mainline Zephyr workspace.

Any repository can act as a manifest repository; the manifest file itself
has no fixed name requirement, but tooling and documentation across the
Zephyr project assume ``west.yml``. Additional manifest files can be
imported from other locations; see `projects`_ and `self`_ below.

Top-level fields
-----------------

A manifest file contains a single top-level ``manifest`` mapping. Any other
top-level keys are ignored.

.. list-table::
   :header-rows: 1
   :widths: 20 15 65

   * - Key
     - Value
     - Description
   * - ``version``
     - string
     - The minimum west manifest schema version required to load this
       file. See `version`_.
   * - ``remotes``
     - array
     - Short names for project fetch URL prefixes. See `remotes`_.
   * - ``defaults``
     - object
     - Default values applied to project attributes that are not set on
       individual projects. See `defaults`_.
   * - ``group-filter``
     - array
     - Enables or disables project groups declared with a project's
       ``groups`` key. See `group-filter`_.
   * - ``projects`` (required)
     - array
     - The list of Git repositories managed by west. See `projects`_.
   * - ``self``
     - object
     - Configuration for the manifest repository itself. See `self`_.

.. code-block:: yaml

   manifest:
     version: "1.2"
     remotes:      # short names for project fetch URLs
       - ...
     defaults:     # default project attributes
       ...
     group-filter: # a list of project groups to enable or disable
       - ...
     projects:     # the list of projects managed by west
       - ...
     self:         # configuration for the manifest repository itself
       ...

Sub-fields
----------

version
~~~~~~~

The minimum west manifest schema version required to load this file.
Declares that the manifest uses features introduced in a given version of
the west manifest file format. Loading the manifest with an older version
of west fails with an error naming the minimum required west version.

The value must be quoted, since an unquoted value such as ``0.10`` is
parsed by YAML as the floating-point number ``0.1``.

.. code-block:: yaml

   manifest:
     version: "1.2"

If omitted, west assumes the manifest uses whatever features are available
in the currently installed west version.

remotes
~~~~~~~

The ``remotes`` field is a sequence of named fetch URL prefixes. Combining
a remote's ``url-base`` with a project's name (or ``repo-path``) forms the
complete Git fetch URL for that project.

.. list-table::
   :header-rows: 1
   :widths: 20 15 65

   * - Key
     - Value
     - Description
   * - ``name`` (required)
     - string
     - A unique name for the remote, referenced from a project's
       ``remote`` key.
   * - ``url-base`` (required)
     - string
     - The URL prefix used to build each project's fetch URL:
       ``<url-base>/<repo-path or name>``. Any URL scheme accepted by Git
       is valid, including SSH forms such as ``git@example.com:base``.

.. code-block:: yaml

   manifest:
     remotes:
       - name: upstream
         url-base: https://github.com/zephyrproject-rtos
       - name: lts
         url-base: https://launchpad.net/arctic-tern/zephyr-rtos

defaults
~~~~~~~~

The ``defaults`` field supplies fallback values for project attributes
that are not set on individual projects.

.. list-table::
   :header-rows: 1
   :widths: 20 15 65

   * - Key
     - Value
     - Description
   * - ``remote``
     - string
     - The remote used for a project that has no ``remote`` or ``url``
       key.
   * - ``revision``
     - string
     - The revision used for a project that has no ``revision`` key.
       Defaults to ``master`` if not given here either.

.. code-block:: yaml

   manifest:
     defaults:
       remote: upstream
       revision: main

group-filter
~~~~~~~~~~~~

The ``group-filter`` field is a list of strings that enable or disable
project groups declared with a project's ``groups`` key (see `projects`_).
Each entry is a group name prefixed with ``+`` (enable) or ``-`` (disable).
All groups are enabled by default, so ``+`` is useful only to re-enable a
group that an imported manifest disabled.

.. code-block:: yaml

   manifest:
     group-filter: [-babblesim, -optional, -testing]

A project whose ``groups`` are *all* disabled becomes inactive: ``west
update`` skips it, and ``west list`` hides it by default. Group names may not contain commas, colons, or whitespace, and they may not begin with "-" or "+".

The workspace-level ``manifest.group-filter`` configuration option (set
with ``west config manifest.group-filter``) is applied on top of this
list, with the configuration option's entries taking precedence.

projects
~~~~~~~~

The ``projects`` field is a sequence describing every project repository
in the workspace. Each item is an object with these fields:

.. list-table::
   :header-rows: 1
   :widths: 20 15 65

   * - Key
     - Value
     - Description
   * - ``name`` (required)
     - string
     - A unique name for the project. Cannot be ``west`` or ``manifest``.
   * - ``description``
     - string
     - An informational description of the project. Added in west
       v1.2.0; ignored by west itself.
   * - ``remote``, ``url``
     - string
     - Exactly one of the two is required. ``remote`` names an entry in
       `remotes`_ used to build the fetch URL. ``url`` gives the complete
       Git fetch URL directly. If neither is given, ``defaults.remote`` is
       used, and the manifest is invalid if that is also absent.
   * - ``repo-path``
     - string
     - A path appended to the remote's ``url-base`` instead of the
       project's name. Mutually exclusive with ``url``.
   * - ``revision``
     - string
     - The Git revision that ``west update`` checks out: a branch, tag,
       SHA, or even a GitHub pull request ref such as ``pull/69/head``.
       Checked out as a detached ``HEAD``. Using ``HEAD~0`` keeps the
       project's current state as-is during updates. Defaults to
       ``master``, or ``defaults.revision`` if set.
   * - ``path``
     - string
     - Where to clone the project locally, relative to the workspace
       topdir. Defaults to the project's ``name``.
   * - ``clone-depth``
     - integer
     - Creates a shallow clone limited to the given number of commits.
       Only valid when ``revision`` is a branch or tag.
   * - ``west-commands``
     - string
     - A relative path to a YAML file describing extension commands
       provided by the project. By convention this file is named
       ``west-commands.yml``. See `self`_ for an example.
   * - ``import``
     - boolean, string, object, or array
     - Imports the projects defined by another manifest file into this one.
       ``true`` imports ``west.yml`` from the project's root directory at the
       checked-out revision; a string is a relative path to a manifest file or
       directory; an object supports ``file``, ``name-allowlist``,
       ``path-allowlist``, ``name-blocklist``, ``path-blocklist``, and
       ``path-prefix``; an array combines any of the above. A project may not
       use both ``import`` and ``groups``. See the upstream documentation on
       :zephyr-docs:`manifest Imports
       <develop/west/manifest.html#manifest-imports>` for full details.
   * - ``groups``
     - array
     - A list of group names the project belongs to, used together with
       `group-filter`_ to make the project active or inactive.
   * - ``submodules``
     - boolean or array
     - Instructs ``west update`` to update the project's Git submodules.
       ``true`` updates every submodule recursively. An array of objects updates
       only the listed submodules. Each object must list a mandatory ``path``
       that is relative to the project's manifest file.
   * - ``userdata``
     - any YAML value
     - Arbitrary data attached to the project for use by external
       tooling. West parses this value but otherwise ignores it; it is
       exposed to Python code as the ``userdata`` attribute of the
       corresponding ``west.manifest.Project`` object. Added in west
       v0.12.

.. code-block:: yaml

   manifest:
     projects:
       - name: cmsis
         revision: 512cc7e895e8491696b61f7ba8066b4a182569b8
         path: modules/hal/cmsis
         groups:
           - hal
       - name: foo
         submodules:
           - path: path/to/foo-first-sub
           - name: foo-second-sub
             path: path/to/foo-second-sub

self
~~~~

The ``self`` field controls the repository that contains this west manifest
file.

.. list-table::
   :header-rows: 1
   :widths: 20 15 65

   * - Key
     - Value
     - Description
   * - ``path``
     - string
     - Where ``west init`` clones the manifest repository, relative to the
       workspace's top-level directory. Defaults to the basename of the manifest
       repository URL's path.
   * - ``west-commands``
     - string
     - A relative path to a YAML file describing extension commands
       provided by the manifest repository. Analogous to
       ``west-commands`` under `projects`_.
   * - ``import``
     - string, object, or array
     - Imports additional manifest files from the manifest repository's
       working tree. Accepts the same string, object, and array forms as
       a project's ``import`` key, except that a boolean value is not
       allowed here. Files imported under ``self`` are resolved from the
       local file system rather than a Git revision, and are always
       processed before the rest of the manifest file and any
       ``projects`` imports.
   * - ``userdata``
     - any YAML value
     - Arbitrary data attached to the manifest repository itself, exposed
       to Python code as the ``userdata`` attribute of the
       ``west.manifest.Manifest`` object.

.. code-block:: yaml

   manifest:
     self:
       path: zephyr
       west-commands: scripts/west-commands.yml

Where ``scripts/west-commands.yml`` might be:

.. code-block:: yaml

   west-commands:
     - file: scripts/west_commands/build.py
       commands:
         - name: build
           class: Build
           help: compile a Zephyr application
     - file: scripts/west_commands/twister_cmd.py
       commands:
         - name: twister
           class: Twister
           help: west twister wrapper
     - file: scripts/west_commands/sign.py
       commands:
         - name: sign
           class: Sign
           help: sign a Zephyr binary for bootloader chain-loading
     - file: scripts/west_commands/flash.py
       commands:
         - name: flash
           class: Flash
           help: flash and run a binary on a board
     - file: scripts/west_commands/debug.py

See also
--------

* :zephyr-docs:`West Manifests <develop/west/manifest.html>` — the upstream
  documentation on west manifest files.
* :zephyr-docs:`west.manifest API  <develop/west/west-apis.html#module-west.manifest>` —
  the Python API for parsing and resolving manifests.
* :zephyr-docs:`Built-in Configuration Options  <develop/west/config.html#west-config-index>` —
  the ``manifest.path``, ``manifest.group-filter``, and
  ``manifest.project-filter`` workspace configuration options that
  interact with this file.
