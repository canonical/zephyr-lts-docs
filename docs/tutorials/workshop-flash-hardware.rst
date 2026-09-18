.. _tut_flash_hardware:

.. meta::
   :description: Connect a development board to a Workshop and flash a Zephyr
                 application to real hardware.

Flash hardware from Workshop
============================

In this tutorial, you'll flash a Zephyr application to a physical board from a
|product_name| Workshop.

Flashing is an inherently unsafe process because it must interface with the host
machine and the real world. To gain the benefits of Workshop and to be able to flash hardware, first identify the host device that the board’s flash runner uses. Then grant Workshop access to that host device and install the runner tool in the Workshop container. This configuration preserves the security hygiene that Workshop provides, allows flashing without ``udev`` rules or ``sudo``, and creates a reproducible and sandboxed working environment.

Prerequisites
-------------

* A launched |workshop_name_samp| Workshop with a synced workspace, as created
  in :ref:`tut_get_started_with_workshop`.
* A board from the :zephyr-docs:`supported boards <boards/index.html>` list,
  connected to the host over USB.

Identify the board device class
-------------------------------

The flash runner decides which host device the board needs, but the device class
varies between boards. To find the runner for your board, open the page for your
board in the :zephyr-docs:`supported boards <boards/index.html>` list and go to
its **Programming and Debugging** section. If the page has no such section,
search the page for mentions of ``flash``, ``flashing``, or ``debug``. Find the names of the default runner and the tool that the runner calls, then read
the matching row in this table.

.. list-table::
   :header-rows: 1

   * - Board name
     - Default flash runner
     - Board device class
     - Host device
   * - ESP32-C3-DevKitM
       (:samp:`esp32c3_devkitm/esp32c3`)
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

For example, the page for the ESP32-C3-DevKitM
(:zephyr-docs:`esp32c3_devkitm <boards/espressif/esp32c3_devkitm/doc/index.html>`)
uses the :samp:`esp32` runner, which flashes over the USB serial bootloader with
:samp:`esptool.py`. The board therefore needs a serial host device, such as
:file:`/dev/ttyUSB0`.

Find the device identifiers
---------------------------

Run these commands on the host.

Workshop uses device identifiers to grant access to the flashing interface of
the board. The board device class determines which device that interface uses.
When you connect the board, the Linux host exposes the interface as a device. A
USB serial bootloader appears as a serial device node. An on-board debug probe,
such as a J-Link, appears as a USB device.

USB serial bootloader
~~~~~~~~~~~~~~~~~~~~~

A board with a serial bootloader exposes a USB serial adapter. First, find the
device node:

.. code-block:: console

   $ ls /dev/ttyUSB* /dev/ttyACM*
   ls: cannot access '/dev/ttyACM*': No such file or directory
   /dev/ttyUSB0

Here the board is :file:`/dev/ttyUSB0`. The error for :file:`/dev/ttyACM*` means
that no device of that type is present. Boards that use a different adapter chip
or the USB controller built into the SoC can expose :file:`/dev/ttyACM0`
instead. Use the node reported for your device.

If you connected several serial devices, unplug the board and run the command
again: the node that disappears belongs to the board. You can also watch the
node appear as you plug the board in:

.. code-block:: console

   $ udevadm monitor --udev --subsystem-match=tty

Now query its subsystem, vendor ID, and product ID:

.. code-block:: console

   $ udevadm info --query=property \
       --property=SUBSYSTEM \
       --property=ID_VENDOR_ID \
       --property=ID_MODEL_ID \
       /dev/ttyUSB0
   SUBSYSTEM=tty
   ID_MODEL_ID=ea60
   ID_VENDOR_ID=10c4

This output is from a CP2102 adapter, common on ESP32 kits. Record the
:samp:`ID_VENDOR_ID` and :samp:`ID_MODEL_ID` values reported for your device.
We will need them for the rest of the tutorial.

USB probe
~~~~~~~~~

A board with an on-board debug probe registers as a raw USB device, rather than
a serial node. List the USB devices:

.. code-block:: console

   $ lsusb
   Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
   Bus 002 Device 002: ID 0bda:0487 Realtek Semiconductor Corp. Dell dock
   ...
   Bus 003 Device 015: ID 10c4:ea60 Silicon Labs CP210x UART Bridge
   ...

The output shows one line per device. The last line above is the CP2102 serial
adapter of an ESP32-C3-DevKitM. A board with a J-Link probe shows a line such as
:samp:`ID 1366:1061 SEGGER J-Link` instead. The first hexadecimal value after
:samp:`ID` is the vendor ID, here :samp:`10c4`. The second value is the product
ID, here :samp:`ea60`. Record the values that correspond to your board. We will
need them for the rest of the tutorial.

If you connected several boards, unplug the target board and run the command
again: the line that disappears belongs to the board.

Some debug probes also expose a serial console. If you need console access in
the Workshop, identify the additional serial device and declare a separate
:samp:`tty` plug for it.

Create a device SDK
-------------------

Make these edits and run these commands on the host.

Now that we have the ``VENDOR_ID`` and ``PRODUCT_ID`` values, we can create a
:workshop-docs:`Workshop SDK <reference/definition-files/sdk-definition>`. We'll
create an in-project SDK that declares one custom-device :workshop-docs:`plug
<explanation/interfaces/plugs-and-slots/>` for each device your boards need:

.. code-block:: console

   $ mkdir -p .workshop/board-devices
   $ editor .workshop/board-devices/sdk.yaml

The :samp:`sdk.yaml` file defines the interfaces to your hardware and will be
imported by the |workshop_definition_file| for the project. Each plug requires a
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

* If you have a USB serial adapter, use :samp:`tty` for ``subsystem``. This is
  the case for the console of an ESP32 board.
* If you have an on-board debug probe that appears as a raw USB device, use
  :samp:`usb` for ``subsystem``. This is the case for a J-Link on a Nordic DK
  or the ST-Link on a Nucleo-64 board.

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
     nrf5340-console:
       interface: custom-device
       subsystem: tty
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

Run these commands on the host.

Apply the updated definition:

.. code-block:: console
   :substitutions:

   $ workshop refresh |workshop_name|

Connect each plug to the system custom-device slot. Use the plug names you
declared in the device SDK:

.. code-block:: console
   :substitutions:

   $ workshop connect |workshop_name|/board-devices:<PLUG> :custom-device

The command prints nothing on success. For the example plugs above:

.. code-block:: console
   :substitutions:

   $ workshop connect |workshop_name|/board-devices:esp32c3-serial :custom-device
   $ workshop connect |workshop_name|/board-devices:nrf5340-probe :custom-device
   $ workshop connect zephyr-26-04/board-devices:nrf5340-console :custom-device


Verify the connections:

.. parsed-literal::

   $ workshop connections |workshop_name|
   **INTERFACE**      **PLUG**                                          **SLOT**                                          **NOTES**
   custom-device  |workshop_name|/board-devices:esp32c3-serial     |workshop_name|/system:custom-device             manual
   custom-device  |workshop_name|/board-devices:nrf5340-probe      |workshop_name|/system:custom-device             manual
   custom-device  |workshop_name|/board-devices:nrf5340-console    |workshop_name|/system:custom-device             manual
   ...

Each connection must show :samp:`system:custom-device` in the :samp:`SLOT`
column and :samp:`manual` in the :samp:`NOTES` column. A plug that is declared
but not connected shows :samp:`-` in the :samp:`SLOT` column:

.. parsed-literal::

   $ workshop disconnect |workshop_name|/board-devices:esp32c3-serial 
   $ workshop connections |workshop_name|
   **INTERFACE**      **PLUG**                                          **SLOT**                                          **NOTES**
   custom-device  |workshop_name|/board-devices:esp32c3-serial      -                                             -
   ...

The plug gives the
Workshop access to the device node. You no longer need host udev rules or
:command:`sudo` for flashing.

.. warning::

   USB probe pass-through is a known issue in Workshop 24.04.
   A plug with :samp:`subsystem: usb` can pass the connection check above
   while the container gets no device node under :file:`/dev/bus/usb/`.
   Flashing then fails with ``LIBUSB_ERROR_NO_DEVICE``.
   A :samp:`tty` plug for the same board still works.

Verify the runner tool
----------------------

The Workshop setup hooks install the core build tools,
such as CMake, Ninja, and west.
They do not install every flash tool.
Check that the tool your runner calls is present.

Open a shell in the Workshop. Then activate the shared Python virtual
environment of the Zephyr SDK:

.. code-block:: console
   :substitutions:

   $ workshop shell |workshop_name|
   |workshop_project_prompt| source /var/lib/workshop/sdk/zephyr/venv/bin/activate

Check the tool for your runner:

.. code-block:: console
   :substitutions:

   |workshop_project_prompt| command -v esptool.py   # esp32 runner
   |workshop_project_prompt| command -v pyocd        # pyocd runner
   /usr/bin/pyocd
   |workshop_project_prompt| command -v openocd      # openocd runner

If the command prints a path, such as
:file:`/usr/bin/pyocd`, the tool is ready. If
the command prints nothing, install the tool into the Workshop container.
Install Python tools into the virtual environment with :command:`pip`:

.. code-block:: console
   :substitutions:

   |workshop_project_prompt| pip install esptool     # esp32 runner
   |workshop_project_prompt| pip install pyocd       # pyocd runner

Similarly, install :samp:`openocd` from the Ubuntu archive:

.. code-block:: console
   :substitutions:

   |workshop_project_prompt| sudo apt update
   |workshop_project_prompt| sudo apt install openocd

The :samp:`nrfjprog`, :samp:`jlink`, and :samp:`nrfutil` runners need vendor
tools. Neither the nRF Command Line Tools, nRF Util, nor the SEGGER J-Link
tools are part of the SDK or the Ubuntu archive. To package a vendor tool as
a reproducible in-project SDK, follow :ref:`how_adding_vendor_tools_to_workshop`,
which works through SEGGER J-Link and nRF Util as examples. For other vendor
tools, follow the installation steps in the board documentation, for example
the :zephyr-docs:`nRF52840 DK <boards/nordic/nrf52840dk/doc/index.html>` page.

Make the runner tool installation reproducible
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tools installed with :command:`pip` or :command:`apt` from a Workshop shell do
not survive :command:`workshop refresh`. The refresh rebuilds the Workshop
filesystem and restores only the content that was installed by SDK :workshop-docs:`hooks
<explanation/sdks/runtime-hooks>`. To reinstall a Python runner tool
automatically, add it to the :file:`setup-project` hook of the device SDK.

The hook lives in the project directory on the host. Leave the Workshop shell,
or open a second terminal on the host. Then create the hook:

.. code-block:: console
   :caption: create the hook on the host

   $ touch .workshop/board-devices/hooks/setup-project
   $ editor .workshop/board-devices/hooks/setup-project

Populate ``setup-project`` with:

.. code-block:: bash
   :caption: .workshop/board-devices/hooks/setup-project

   source /var/lib/workshop/sdk/zephyr/venv/bin/activate
   pip install esptool pyocd

List the device SDK after the :samp:`zephyr` SDK in the
:samp:`sdks` list. Hooks run in list order, and the shared virtual environment
must exist before the hook runs. Apply the change from the host:

.. parsed-literal::

   $ workshop refresh |workshop_name|

Install the target toolchain
----------------------------

Make these edits and run these commands on the host.

The Zephyr SDK bundle contains no cross-compilers.
Each target architecture is provided by a separate toolchain SDK.
The get-started definition connects only the host x86-64 toolchain.

Only the toolchain SDK is downloaded when it is added to the :samp:`sdks` list.
A :samp:`connections` entry is still required to mount the toolchain into the
Zephyr SDK bundle. Each entry connects a plug from the :samp:`zephyr-sdk-ng`
SDK to the :samp:`toolchain` slot of the toolchain SDK.

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
     - name: zephyr-riscv64
       channel: |sdk_ng_channel|

   connections:
     # Existing connections...
     - plug: zephyr-sdk-ng:arm
       slot: zephyr-arm:toolchain
     - plug: zephyr-sdk-ng:riscv64
       slot: zephyr-riscv64:toolchain
     - plug: zephyr-riscv64:venv
       slot: uv:venv

.. note::

   The :samp:`zephyr-riscv64` SDK needs the extra
   :file:`venv` connection in the example.
   Its :file:`setup-project` hook installs ESP32 flashing tools,
   such as :program:`esptool`,
   into the Python virtual environment.

Apply the updated definition:

.. code-block:: console
   :substitutions:

   $ workshop refresh |workshop_name|

Verify that each toolchain is connected. A connected toolchain shows the 
toolchain SDK in the :samp:`SLOT` column:

.. parsed-literal::

   $ workshop connections |workshop_name|
   **INTERFACE**      **PLUG**                                                 **SLOT**                                                    **NOTES**
   ...
   mount          |workshop_name|/zephyr-sdk-ng:arm                       |workshop_name|/zephyr-arm:toolchain                       -
   mount          |workshop_name|/zephyr-sdk-ng:riscv64                   |workshop_name|/zephyr-riscv64:toolchain                   -
   ...

A toolchain SDK that is downloaded but not connected shows
:samp:`system:mount` in the :samp:`SLOT` column instead:

.. parsed-literal::

   $ workshop connections |workshop_name|
   **INTERFACE**      **PLUG**                                                 **SLOT**                                                    **NOTES**
   ...
   mount          |workshop_name|/zephyr-sdk-ng:arm                       |workshop_name|/zephyr-arm:toolchain                       -
   mount          |workshop_name|/zephyr-sdk-ng:riscv64                   |workshop_name|/system:mount                               -
   ...


Build the application
---------------------

Run this command on the host.

Install and connect the toolchain SDK for the board architecture first, as
described in the previous section. Then build a sample for your board with the
:samp:`build` action. This example uses :samp:`samples/synchronization` because
:samp:`samples/basic/blinky` requires an :samp:`led0` alias that the device
trees of ESP32-C3 and ESP32-S3 devkits do not provide:

.. code-block:: console
   :substitutions:

   $ workshop run |workshop_name| -- build -p always -b \
      esp32c3_devkitm samples/synchronization

Replace the board target and the sample with the values for your board.

Flash the board
---------------

Run these commands in the Workshop shell. Change to the Zephyr source
directory:

.. code-block:: console
   :substitutions:

   |workshop_project_prompt| cd zephyr

First list the runners and options your board supports:

.. code-block:: console
   :substitutions:

   |workshop_zephyr_prompt| west flash --context

The output lists the runners available for the build and the default runner:

.. code-block:: text

   available runners in runners.yaml:
     openocd, esp32
   default runner in runners.yaml:
     esp32

Then flash the board:

.. code-block:: console
   :substitutions:

   |workshop_zephyr_prompt| west flash

The default runner of your board flashes the current :samp:`build` directory.
Most boards need no extra options.
For example, the ESP32-C3-DevKitM flashes with the default
:samp:`esp32` runner.
The runner finds :command:`esptool.py` and the serial device
automatically.

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
   -- west flash: rebuilding
   ninja: no work to do.
   -- west flash: using runner esp32
   -- runners.esp32: reset after flashing requested
   -- runners.esp32: Flashing esp32 chip on None (921600bps)
   esptool v5.4.0
   Connected to ESP32-C3 on /dev/ttyUSB0:
   Chip type:          ESP32-C3 (QFN32) (revision v0.3)
   Features:           Wi-Fi, BT 5 (LE), Single Core, 160MHz, Embedded Flash 4MB (XMC)
   Crystal frequency:  40MHz
   MAC:                10:91:a8:40:d7:d0

   Stub flasher running.
   Changing baud rate to 921600...
   Changed.

   Configuring flash size...
   Flash will be erased from 0x00000000 to 0x00020fff...
   Wrote 133812 bytes at 0x00000000 in 2.1 seconds (504.0 kbit/s).
   Hash of data verified.

   Hard resetting via RTS pin...

Press the reset button on the board if the application does not start.

Remove device access
--------------------

Run this command on the host.

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

To package a vendor tool as a reproducible in-project SDK, read
:ref:`how_adding_vendor_tools_to_workshop`.

To understand the files that Workshop manages, read
:ref:`ref_workshop_environment`.
