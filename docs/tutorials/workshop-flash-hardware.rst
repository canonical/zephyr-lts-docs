.. _tut_flash_hardware:

.. meta::
   :description: Connect a development board to a Workshop and flash a Zephyr
                 application to real hardware.

Flash hardware from Workshop
============================

In this tutorial, you'll flash a Zephyr application to a physical board from a
|product_name| Workshop.

Flashing is an inherently unsafe process because it must interface with the host
machine and the real world. To gain the benefits of Workshop and be able to
flash hardware we must first identify the host device that the board's flash
runner uses. Then we must encode access to that host device for Workshop and
install the runner tool into our Workshop container. This preserves the security
hygiene that Workshop provides, allows flashing without ``udev`` rules or
``sudo``, and creates a reproducible and sandboxed working environment.

Prerequisites
-------------

* A launched |workshop_name_samp| Workshop with a synced workspace, as created
  in :ref:`tut_get_started_with_workshop`.
* A :zephyr-docs:`supported boards <boards/index.html>` connected to the host over USB.

Identify the board device class
---------------------------------

Before giving Workshop access to a board, determine which host device the board
uses for flashing. 

Start with the board name, for example
``esp32c3_devkitm/esp32c3``, and follow these steps:

 Find your board's page in the :zephyr-docs:`Supported Boards <boards/index.html>` list and open its page. 

Go the **Programming and Debugging** section or, if it is absent, look up on the page for this section, search the board page for mentions of ``flash``, ``flashing``, or ``debug``. 

Once you have the runner's name, check the table to find the board's device class:


.. todo:

   Jeff: I followed this advice, went to the upstream page and cross referenced
   and could not find ``pyocd` nor ``esp32`` for those boards. How is a user
   supposed to find the host device?


.. todo:

   Yana: Can you use `west flash --context` to identify the runner instead of looking up upstream documentation and try to flash in verbose mode to see what executable is actually triggered?
   If the default runner does not match what we have in the board, should the user change the default runner? Also, is Canonical going to maintain and verify each entry in this table? If yes, should we skip sending users upstream at all and just give them the table that is is built from the tested source?


.. list-table::
   :header-rows: 1

   * - Board name
     - Default flash runner
     - Board device class
     - Host device
   * - ESP32-C3-DevKitM (:samp:`esp32c3_devkitm/esp32c3`)
     - :samp:`esp32`
     - USB serial bootloader
     - Serial node, such as :file:`/dev/ttyUSB0`
   * - Nordic nRF52840 DK (:samp:`nrf52840dk/nrf52840`)
     - :samp:`nrfjprog`
     - On-board J-Link probe
     - USB probe
   * - BBC micro:bit v2 (:samp:`bbc_microbit_v2/nrf52833`)
     - :samp:`pyocd`
     - On-board CMSIS-DAP probe
     - USB probe
   * - STM32 Nucleo-64 (:samp:`nucleo_l476rg/stm32l476xx`)
     - :samp:`openocd`
     - On-board ST-Link probe
     - USB probe

.. todo::

   Jeff: :issue:`RTOS-241 <RTOS-241>` walk the an example of identifying the
   flash device class for the ESP32-C3-DevKitM since that is the working example
   for this chapter

Find the device identifiers
---------------------------

Workshop uses device identifiers to grant access to the
board's flashing interface.

The board device class identifies the flashing interface. When you connect the
board, Linux host exposes that interface as a device: a USB serial bootloader
appears as a serial device node, while an on-board debug probe, such as J-Link,
appears as a USB device. 

Finding the device identifiers depends on the host device type and the board's device class.

USB serial bootloader
~~~~~~~~~~~~~~~~~~~~~

.. todo::
   
   Yana: What if there are multiples devices connected? Should the user turn the target device on and off to see which one is specifically associated with the board?

A board with a serial bootloader exposes a USB serial adapter. First, find the
device node:

.. code-block:: console

   $ ls /dev/ttyUSB* /dev/ttyACM*

Now query its subsystem, vendor ID, and product ID:

.. code-block:: console

   $ udevadm info --query=property \
       --property=SUBSYSTEM \
       --property=ID_VENDOR_ID \
       --property=ID_MODEL_ID \
       /dev/ttyUSB0

The output for a CP2102 adapter, common on ESP32 kits, is similar to:

.. todo::

   Jeff: Where did this information come from? Show the real example and the
   output. That means show the output from the ``ls`` and from ``udevadm``.

.. code-block:: text

   SUBSYSTEM=tty
   ID_VENDOR_ID=10c4
   ID_MODEL_ID=ea60

.. todo::

   Yana: Isn't this already what we instruct users to do with run ls above? If we want to to clarify that a USB device can be exposed as either /dev/ttyUSB* or /dev/ttyACM*, let's move this sentence to be right after the ls command and to instruct users to just do a simple plug/unplug while monitoring with udev or smth to actually find the correct file. 

Some boards use a different adapter chip or the USB controller built into the
SoC. Those boards can expose :file:`/dev/ttyACM0` instead. Use the values
reported for your device.

USB probe
~~~~~~~~~

A board with an on-board debug probe registers as a raw USB device, rather than
a serial node. Thus the board will show as a USB device. List the USB devices:

.. code-block:: console

   $ lsusb

.. todo::

   Jeff: Show the real output without the metavariables. :issue:`RTOS-240
   <RTOS-240>`. Then show the form you have here and say "you can see the
   vendor_id is, product_id is..."

The output will show one line per device:

.. code-block:: console

   $ Bus 003 Device 012: ID <VENDOR_ID>:<PRODUCT_ID> SEGGER J-Link

The first hexadecimal value after :samp:`ID` is the vendor ID. The second value
is the product ID. Record the values that correspond to your board; we will need
them for the rest of the tutorial.

Some debug probes also expose a serial console. If you need console access in
Workshop, identify the additional serial device and declare a separate ``tty``
plug for it.

Create a device SDK
-------------------

Now that we have the ``VENDOR_ID`` and ``PRODUCT_ID`` we can create a
:workshop-docs:`Workshop SDK <reference/definition-files/sdk-definition>`. We'll
create an in-project SDK that declares one custom-device :workshop-docs:`plug
<explanation/interfaces/plugs-and-slots/>` for each device your boards need:

.. code-block:: console

   $ mkdir -p .workshop/board-devices
   $ editor .workshop/board-devices/sdk.yaml

The :samp:`sdk.yaml` file defines the interfaces to your hardware and will be
imported by the |workshop_definition_file| for the project. Here is an example
:samp:`sdk.yaml` file:



Each plug requires a
name, the :samp:`custom-device` interface, and at least one device filter. The
:samp:`subsystem` filter selects the device class:

.. code-block:: yaml
   :caption: .workshop/board-devices/sdk.yaml

   name: board-devices
   plugs:
     <BOARD>-serial:              # USB serial adapter
       interface: custom-device
       subsystem: tty
       vendorid: "<VENDOR ID>"
       productid: "<PRODUCT ID>"
     <BOARD>-probe:               # on-board debug probe
       interface: custom-device
       subsystem: usb
       vendorid: "<VENDOR ID>"
       productid: "<PRODUCT ID>"

* If you hade a USB serial adapter then use :samp:`tty` for ``subsystem``. This
  is the case for the console of an ESP32 board.
* If you hade an on-board debug probe that displayed as a raw USB device, then
  use :samp:`usb` for ``subsystem``. This is the case for a J-Link on a Nordic
  DK or the ST-Link on a Nucleo-64 board.

Add the :samp:`VENDOR_ID` and :samp:`PRODUCT_ID` values reported by the host to
match your device. Always set :samp:`VENDOR_ID` for a :samp:`tty` plug. A
:samp:`tty` plug without it can match system devices and fail the connection. If
you set :samp:`PRODUCT_ID`, you must also set :samp:`VENDOR_ID`.

Keep only the plug shapes your boards need. For example, here is the complete
Workshop definition file for a serial adapter for an ESP32-C3-DevKitM and a
J-Link probe for an nRF5340 DK:

.. code-block:: yaml

   name: board-devices
   plugs:
     esp32c3-serial:
       interface: custom-device
       subsystem: tty
       vendorid: "10c4"
       productid: "ea60"
     nrf5340-probe:
       interface: custom-device
       subsystem: usb
       vendorid: "1366"
       productid: "1061"

Now we add the in-project SDK to the :samp:`sdks` list in
|workshop_definition_file|:

.. code-block:: yaml

   sdks:
     # Existing SDK entries...
     - name: project-board-devices # import our devices plugs

Apply the definition and connect the devices
----------------------------------------------

Apply the updated definition:

.. code-block:: console
   :substitutions:

   $ workshop refresh |workshop_name|

Connect each plug to the system custom-device slot. Use the plug names you
declared in the device SDK:

.. code-block:: console
   :substitutions:

   $ workshop connect |workshop_name|/board-devices:<PLUG> :custom-device

.. todo::

   Jeff: Show the connect output :issue:`RTOS-240 <RTOS-240>`

For the example plugs above:

.. todo::

   Jeff: show don't tell :issue:`RTOS-240 <RTOS-240>`

.. code-block:: console
   :substitutions:

   $ workshop connect |workshop_name|/board-devices:esp32c3-serial :custom-device
   $ workshop connect |workshop_name|/board-devices:nrf5340-probe :custom-device

Verify the connections:

.. todo::

   Jeff: show don't tell :issue:`RTOS-240 <RTOS-240>`

.. code-block:: console

   $ workshop connections --all

Each connection must show :samp:`system:custom-device` in the slot column. The
plug gives the Workshop access to the device node. Thus, you no longer need host
udev rules or :command:`sudo` for flashing.

Verify the runner tool
----------------------

The Workshop setup hooks install the core build tools,
such as CMake, Ninja, and west.
They do not install every flash tool.
Check that the tool your runner calls is present.

Open a shell in the Workshop:

.. code-block:: console
   :substitutions:

   $ workshop shell |workshop_name|

Check the tool for your runner:

.. code-block:: console
   :substitutions:

   |workshop_project_prompt| command -v esptool.py   # esp32 runner
   |workshop_project_prompt| command -v pyocd        # pyocd runner
   |workshop_project_prompt| command -v openocd      # openocd runner

   .. todo::
         Yana: If the tool is not installed, it prints what? Nothing? 

If the command prints a path, the tool is ready. If the command prints then
you'll have to install the tool into the Workshop container. In your Workshop
shell you can use the standard python tools to install into the virtual
environment:

.. code-block:: console
   :substitutions:

   |workshop_project_prompt| pip install esptool     # esp32 runner
   |workshop_project_prompt| pip install pyocd       # pyocd runner

Similarly for the :samp:`openocd` runner:

.. code-block:: console
   :substitutions:

   |workshop_project_prompt| sudo apt update
   |workshop_project_prompt| sudo apt install openocd

The :samp:`nrfjprog` and :samp:`jlink` runners need vendor tools. Neither the
nRF Command Line Tools nor the SEGGER J-Link tools are part of the SDK or the
Ubuntu archive. Follow the installation steps in the board documentation, for
example the :zephyr-docs:`nRF52840 DK <boards/nordic/nrf52840dk/doc/index.html>`
page.

.. to-do::

   Yana: IMO, make a small but an explicit heading instead of a note, e.g. "Make your SDK setup reproducible" or "Add an SDK setup script" or something similar. 

   Also, if you do make it a separate heading, clarify that you need to leave the workshop shell to reinforce the mental model that separates the host environment from the Workshop container.

.. note::

   Tools installed with :command:`pip` or :command:`apt` from a Workshop shell
   do not survive :command:`workshop refresh`. The refresh rebuilds the Workshop
   filesystem and restores only content installed by SDK :workshop-docs:`hooks
   <explanation/sdks/runtime-hooks>`. To reinstall a Python runner tool
   automatically, add it to the :file:`setup-project` hook of the device SDK:

   .. code-block:: console
      :caption: create the hook

      $ touch .workshop/board-devices/hooks/setup-project
      $ editor .workshop/board-devices/sdk.yaml

   Now populate ``setup-project`` with:

   .. code-block:: bash
      :caption: .workshop/board-devices/hooks/setup-project

      source /var/lib/workshop/sdk/zephyr/venv/bin/activate
      pip install esptool pyocd

   Be sure to list the device SDK after the :samp:`zephyr` SDK in the
   :samp:`sdks` list. Hooks run in list order, and the shared virtual
   environment must exist before the hook runs.

.. todo::

   Yana: Without knowing Workshop-specific terms, is it clear based on the heading what "connect" means here? As this is entry-level tutorial, headings should probably be more goal-oriented and using terms that a non-Workshop dev would get -- "Install and configure the target toolchain"? "Configure the toolchain"? "Select the compilers"? "Add a toolchain"? 

Connect the target toolchain
----------------------------

The Zephyr SDK bundle contains no cross-compilers.
Each target architecture is provided by a separate toolchain SDK.
The get-started definition connects the host x86-64 toolchain only.

Adding a toolchain SDK to the :samp:`sdks` list only downloads it.
A :samp:`connections` entry is required to mount the toolchain
into the Zephyr SDK bundle.
Each entry connects a plug of the :samp:`zephyr-sdk-ng` SDK
to the :samp:`toolchain` slot of the toolchain SDK.

.. list-table::
   :header-rows: 1

   * - Board
     - Architecture
     - Toolchain SDK
     - Plug to connect
   * - Nordic nRF52840 DK (:samp:`nrf52840dk/nrf52840`)
     - Arm Cortex-M4
     - :samp:`zephyr-arm`
     - :samp:`zephyr-sdk-ng:arm`
   * - ESP32-S3-DevKitC (:samp:`esp32s3_devkitc/esp32s3/procpu`)
     - Xtensa
     - :samp:`zephyr-xtensa-espressif-esp32s3`
     - :samp:`zephyr-sdk-ng:xtensa-espressif-esp32s3`
   * - ESP32-C3-DevKitM (:samp:`esp32c3_devkitm`)
     - RISC-V
     - :samp:`zephyr-riscv64`
     - :samp:`zephyr-sdk-ng:riscv64`

For example, the SDK toolchain for the nRF52840 DK can be added to
Workshop as follows:

.. code-block:: yaml
   :caption: |workshop_definition_file|
   :substitutions:

   sdks:
     # Existing SDK entries...
     - name: zephyr-arm
       channel: |sdk_ng_channel|
     - name: zephyr-arm64
       channel: |sdk_ng_channel|
     - name: zephyr-riscv64
       channel: |sdk_ng_channel|

   connections:
     # Existing connections...
     - plug: zephyr-sdk-ng:arm
       slot: zephyr-arm:toolchain
     - plug: zephyr-sdk-ng:arm64
       slot: zephyr-arm64:toolchain
     - plug: zephyr-sdk-ng:riscv64
       slot: zephyr-riscv64:toolchain

.. important::

   .. todo::

      Jeff: ensure this is still the case after lincoln patches it.
      :issue:`RTOS-222 <RTOS-222>`

   Always install and connect :samp:`zephyr-arm64`,
   even if no target board uses AArch64.
   When the Zephyr SDK searches for its host tools,
   it probes the first toolchain directory in alphabetical order.
   That directory is :file:`aarch64-zephyr-elf`.
   If no :samp:`zephyr-arm64` SDK is connected,
   the directory stays empty.
   Every build then fails with
   "Zephyr was unable to find the toolchain".

Apply the updated definition:

.. code-block:: console
   :substitutions:

   $ workshop refresh |workshop_name|

Verify that each toolchain is connected:

.. code-block:: console
   :substitutions:

   $ workshop connections |workshop_name|

A connected toolchain shows the toolchain SDK slot
in the :samp:`SLOT` column,
while a toolchain SDK whose slot shows in the :samp:`PLUG` column
is downloaded but not connected.

Build the application
---------------------

Once, you have installed and configured the toolchain SDK for the board architecture, build a sample for your board with the :samp:`build` action.
This example uses ``samples/synchronization`` because
``samples/basic/blinky`` requires an ``led0`` alias that is not available on
ESP32-C3 and ESP32-S3 devkits.

.. code-block:: console
   :substitutions:

   $ workshop run |workshop_name| -- build -p always -b \\
      esp32c3_devkitm samples/synchronization

Replace the board target and the sample with the values for your board.

Flash the board
---------------

.. to-do::

   Yana: Is there a reason to switch from building from out of shell with a workshop action in the "Build the application" above and then flashing from within the shell? I think we switch instructions multiple times: Verify the runner tool -- in shell, Connect the target toolchain -- host, Build the application -- host, Flash the board -- in shell, Remove device access -- host. Make sure these switches are documented as the first thing under each heading.

Run :command:`west flash` from the Zephyr source directory
inside the Workshop shell:

.. code-block:: console
   :substitutions:

   |workshop_project_prompt| cd zephyr
   |workshop_zephyr_prompt| west flash

The default runner of your board flashes the current :samp:`build` directory.
Most boards need no extra options.
For example, the ESP32-C3-DevKitM flashes with the default
:samp:`esp32` runner.
The runner finds :command:`esptool.py` and the serial device
automatically.

List the runners and options your board supports:

.. code-block:: console
   :substitutions:

   |workshop_zephyr_prompt| west flash --context

Some boards support more than one runner. Select a different runner with the
:option:`!-r` option. For example, the nRF52840 DK defaults to :samp:`nrfjprog`.
If you installed the SEGGER tools instead of the nRF Command Line Tools, select
the :samp:`jlink` runner:

.. code-block:: console
   :substitutions:

   |workshop_zephyr_prompt| west flash -r jlink

The board documentation lists the options each runner accepts.
For example, on ESP32 boards where the runner does not find
:command:`esptool.py` or the serial device automatically,
pass both to the :samp:`esp32` runner:

.. code-block:: console
   :substitutions:

   |workshop_zephyr_prompt| west flash -- \
   --esp-idf-path /project/zephyr \
   --esp-tool "$(command -v esptool.py)" \
   --esp-device /dev/ttyUSB0

The :samp:`esp32` runner requires :option:`!--esp-idf-path`
even if :option:`!--esp-tool` points to esptool directly.
The runner ignores the path value.

When the runner needs no extra options,
you can also flash from the host with the :samp:`flash` action:

.. code-block:: console
   :substitutions:

   $ workshop run |workshop_name| -- flash

.. todo::

   Jeff: Show the success report output. :issue:`RTOS-240 <RTOS-240>`

The runner reports success at the end of its output.
Press the reset button on the board if the application does not start.

Remove device access
--------------------

Disconnect a plug when you no longer need the device:

.. code-block:: console
   :substitutions:

   $ workshop disconnect |workshop_name|/board-devices:esp32c3-serial

The plug remains declared in the device SDK. Connect it again with
:command:`workshop connect` for the next session.

Next steps
----------

You now have a Workshop that can flash your board.

For the full device access procedure and the connection reference, read
:ref:`how_access_hardware_from_workshop`.

To understand the files that Workshop manages, read
:ref:`ref_workshop_environment`.
