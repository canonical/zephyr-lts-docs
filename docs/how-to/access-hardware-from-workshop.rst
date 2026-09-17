.. _how_access_hardware_from_workshop:

.. meta::
   :description: Give a Zephyr Workshop access to a development board and flash
                 an application.

How to access hardware from Workshop
====================================

The host device used to flash a board depends on the board and runner.
Create an in-project SDK with a custom-device plug
that matches only the device required by your board.

Prerequisites
-------------

Before starting, ensure you have these requirements satisfied:

* A launched |workshop_name_samp| Workshop.
* A development board connected to the host.
* A Zephyr application built for that board
  in :file:`/project/zephyr/build`.
* The host device node used by the board's flash runner.

Run the host commands in this guide from the project directory
that contains |workshop_definition_file|.

Identify the host device
------------------------

Use your board and runner documentation
to identify the device node used for flashing.
For a USB serial adapter, the node can be :file:`/dev/ttyUSB0`
or :file:`/dev/ttyACM0`.

Query its subsystem, vendor ID, and product ID:

.. code-block:: console

   $ udevadm info --query=property \
       --property=SUBSYSTEM \
       --property=ID_VENDOR_ID \
       --property=ID_MODEL_ID \
       /dev/ttyUSB0

The output for a serial adapter is similar to:

.. code-block:: text

   SUBSYSTEM=tty
   ID_VENDOR_ID=0403
   ID_MODEL_ID=6001

Use the values reported for your device.
Do not copy the example identifiers unless they match your hardware.

Create a device SDK
-------------------

Create an in-project SDK definition:

.. code-block:: console

   $ mkdir -p .workshop/board-device
   $ editor .workshop/board-device/sdk.yaml

Add a custom-device plug with the attributes from :command:`udevadm`:

.. code-block:: yaml
   :caption: .workshop/board-device/sdk.yaml

   name: board-device
   plugs:
     flash-device:
       interface: custom-device
       subsystem: tty
       vendorid: "0403"
       productid: "6001"

The :samp:`tty` subsystem applies to the serial-adapter example.
Use the subsystem reported for your device.
Always set :samp:`vendorid` for a :samp:`tty` device,
and set :samp:`productid` when the host reports one.
Quote both identifiers so YAML preserves leading zeroes.

Add the in-project SDK to the :samp:`sdks` list
in |workshop_definition_file|:

.. code-block:: yaml

   sdks:
     # Existing SDK entries...
     - name: project-board-device

Apply the updated definition:

.. code-block:: console
   :substitutions:

   $ workshop refresh |workshop_name|

Connect the device
------------------

Connect the plug to the system custom-device slot:

.. code-block:: console
   :substitutions:

   $ workshop connect \
       |workshop_name|/board-device:flash-device :custom-device

Verify the connection:

.. code-block:: console

   $ workshop connections --all

The connection for :samp:`board-device:flash-device`
must show :samp:`system:custom-device` in the slot column
and :samp:`manual` in the notes column.

Flash the application
---------------------

Flash the application
from the default :file:`/project/zephyr/build` directory:

.. code-block:: console
   :substitutions:

   $ workshop run |workshop_name| -- flash

To use a different build directory,
pass its path with the :option:`!-d` option:

.. code-block:: console
   :substitutions:

   $ workshop run |workshop_name| -- flash -d /project/path/to/build

Some boards expose more than one host device, or they require a board-specific runner and additional arguments.
Declare and connect one narrowly scoped plug for each required device.
Use :command:`west flash --context`
to list the available options.

Remove device access
--------------------

Disconnect the plug:

.. code-block:: console
   :substitutions:

   $ workshop disconnect |workshop_name|/board-device:flash-device

Run :command:`workshop connections --all`
to check that the plug is disconnected.


See also
--------

Tutorial:

- :ref:`tut_get_started_with_workshop`

Reference:

- :ref:`ref_workshop_environment`
