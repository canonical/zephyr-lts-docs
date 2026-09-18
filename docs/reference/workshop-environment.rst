.. _ref_workshop_environment:

.. meta::
   :description: Reference for the Zephyr Workshop SDKs, definition, project
                 files, actions, and host interfaces.

Workshop environment
====================

The |product_name| Workshop is the standard development environment.
It combines SDKs from the SDK Store into one environment.
The Workshop uses the |workshop_base_samp| base.

SDK selection
-------------

.. list-table::
   :header-rows: 1

   * - SDK
     - Channel
     - Purpose
   * - :samp:`uv`
     - :samp:`latest/stable`
     - Provide the Python environment used by Zephyr tools.
   * - :samp:`zephyr`
     - |workshop_sdk_channel_samp|
     - Provide the Zephyr source and build integration.
   * - :samp:`zephyr-sdk-ng`
     - |sdk_ng_channel_samp|
     - Provide host tools and the Zephyr SDK bundle.
   * - :samp:`zephyr-amd64`
     - |sdk_ng_channel_samp|
     - Provide the x86 cross-compiler used by :samp:`qemu_x86`.

The definition connects the Python environment,
SDK bundle, and x86 toolchain to the :samp:`zephyr` SDK.
The Workshop project is mounted at :file:`/project`,
and the writable Zephyr source is at :file:`/project/zephyr`.

Each SDK entry pins one channel. To find other versions and channels an SDK
publishes, follow :ref:`how_find_sdk_versions`.

Definition
----------

Use this definition for a |product_name| workspace:

.. literalinclude:: workshop.yaml
   :language: yaml
   :caption: .workshop/zephyr-24-04.yaml

Store the definition in the project repository.
Do not store :file:`.workshop.lock` in the repository.

Actions
-------

.. list-table::
   :header-rows: 1
   :widths: 10 40 50

   * - Action
     - Purpose
     - Example
   * - :samp:`sync`
     - Synchronize all :program:`west` projects to the manifest revisions.
     - .. code-block:: console
          :substitutions:

          $ workshop run |workshop_name| -- sync
   * - :samp:`build`
     - Run :command:`west build` from the Zephyr source directory with
       :envvar:`ZEPHYR_MODULES` cleared.
     - .. code-block:: console
          :substitutions:

          $ workshop run |workshop_name| -- build \
            -b qemu_x86 samples/hello_world
   * - :samp:`flash`
     - Run :command:`west flash` from the Zephyr source directory with
       :envvar:`ZEPHYR_MODULES` cleared.
     - .. code-block:: console
          :substitutions:

          $ workshop run |workshop_name| -- flash

ZEPHYR_MODULES override
-----------------------

The :samp:`zephyr` SDK adds the following line to :file:`~/.profile` during
project setup:

.. code-block:: console

   export ZEPHYR_MODULES=/home/workshop/modules

The path points to the SDK's own modules directory, not to the workspace.

:command:`west build` treats :envvar:`ZEPHYR_MODULES` as the complete
module list. When the variable is set, west does not read the workspace
manifest and loads modules only from the named path. Boards that need
headers from workspace modules then fail with a missing-header error.

The ``build`` and ``flash`` actions in the reference definition clear the
variable before calling west. You therefore do not need extra steps when
you build with :command:`workshop run`.

In an interactive shell, clear the variable before you build:

.. code-block:: console

   unset ZEPHYR_MODULES

To clear the variable in every shell session, add the command to the
:file:`hooks/setup-project` file of an in-project SDK. For a worked example,
see :ref:`how_install_ppa_dependencies`.

Host interfaces
---------------

The base definition does not grant access to host devices.
The host devices required for flashing vary by board and runner.
For example, a serial runner can use a :samp:`tty` device,
while a debug probe can expose a different subsystem.

Declare narrowly scoped custom-device plugs in an in-project SDK.
Use the device subsystem along with any vendor and product IDs reported by the host.
Workshop does not connect custom-device plugs automatically
because they grant access to host hardware.
Follow :ref:`how_access_hardware_from_workshop` for the procedure.

Some runners, such as :samp:`jlink` and :samp:`nrfutil`,
also call a vendor tool that the SDK bundle does not provide.
Package the tool in an in-project SDK,
as described in :ref:`how_adding_vendor_tools_to_workshop`.


See also
--------

Tutorial:

- :ref:`tut_get_started_with_workshop`

How-to guides:

- :ref:`how_access_hardware_from_workshop`
- :ref:`how_adding_vendor_tools_to_workshop`
- :ref:`how_find_sdk_versions`

Explanation:

- :ref:`exp_development_environments`
