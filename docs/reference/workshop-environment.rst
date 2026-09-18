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
The Workshop mounts the project at :file:`/project`,
and the writable Zephyr source is at :file:`/project/zephyr`.

Each SDK entry pins one channel. To find other versions and channels an SDK
publishes, follow :ref:`how_find_sdk_versions`.

Definition
----------

Use this definition for a |product_name| workspace:

.. literalinclude:: workshop.yaml
   :language: yaml
   :caption: .workshop/zephyr-26-04.yaml

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
     - Run :command:`west build` from the Zephyr source directory.
     - .. code-block:: console
          :substitutions:

          $ workshop run |workshop_name| -- build \
            -b qemu_x86 samples/hello_world
   * - :samp:`flash`
     - Run :command:`west flash` from the Zephyr source directory.
     - .. code-block:: console
          :substitutions:

          $ workshop run |workshop_name| -- flash

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
