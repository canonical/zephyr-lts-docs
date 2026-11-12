.. _how_find_sdk_versions:

.. meta::
   :description: Find the SDK versions and channels available in the SDK
                 Store, and pin a Workshop definition to a different one.

How to find other SDK versions
===============================

Every SDK entry in |workshop_definition_file| pins one :samp:`channel`, and a
channel tracks one version at a time. Use the :command:`sdk` command, which
ships as part of the ``workshop`` snap, to see which versions an SDK
publishes, then edit the definition to select a different one.

Prerequisites
-------------

Before starting, ensure you have these requirements satisfied:

* Workshop installed on the host, as described in
  :ref:`tut_get_started_with_workshop`. The :command:`workshop` snap also
  installs the :command:`sdk` command.
* A project directory that contains |workshop_definition_file|.

Run the host commands in this guide from that project directory.

Install the sdk command
-------------------------

The :command:`workshop` snap includes :command:`sdk` by default:

.. code-block:: console

   $ sudo snap install --classic workshop

Confirm the command is available:

.. code-block:: console

   $ command -v sdk
   /snap/bin/sdk

If the command is not found, refresh the snap to the latest revision:

.. code-block:: console

   $ sudo snap refresh workshop

Find SDKs by name
------------------

You can search the SDK Store for SDKs matching a name:

.. code-block:: console
   :caption: find all sdks with zephyr in the name

   $ sdk find zephyr

.. code-block:: text

   NAME                               VERSION  PUBLISHER        SUMMARY
   zephyr                             4.4.2    Dmitry Lyfar     Zephyr SDK
   zephyr-arc                         1.0.1    Lincoln Wallace  Zephyr Toolchain
   zephyr-arc64                       1.0.1    Lincoln Wallace  Zephyr Toolchain
   zephyr-xtensa-espressif-esp32s2    1.0.1    Lincoln Wallace  Zephyr Toolchain
   ...

The :samp:`VERSION` column shows only the version published to each SDK's
default channel, usually :samp:`latest/stable`. Toolchain SDKs such as
:samp:`zephyr-xtensa-espressif-esp32s2` can look pinned to a single version,
:samp:`1.0.1` here, even though other channels of the same SDK publish
different versions.

Inspect the channels of an SDK
-------------------------------

To find other versions, inspect the SDK with the :command:`sdk info` command.
It lists every channel an SDK publishes, with the version, build date, and
revision:

..
   This sdk info is populated by running `make transcripts`

.. code-block:: console
   :caption: Find all versions of zephyr-xtensa-espressif-esp32s2

   $ sdk info zephyr-xtensa-espressif-esp32s2

.. literalinclude:: /_dev/transcripts/sdk-info.txt
   :language: text
   :lines: 1-25

Each row of the :samp:`CHANNELS` table is one :samp:`<track>/<risk>` channel. An
arrow (:samp:`↑`) means that risk level publishes the same revision as the row
above it. The example shows the start of the output; the full table also lists
tracks such as :samp:`0.16.9/stable`, :samp:`0.17.4/stable`, and
:samp:`1.0.1/stable`, which each pin a different version with the same level of
risk.


Select a different channel
----------------------------

Edit |workshop_definition_file| and change the :samp:`channel` of the SDK entry
to one of the channels reported by :command:`sdk info`:

.. code-block:: yaml
   :caption: |workshop_definition_file|
   :substitutions:

   sdks:
     # Existing SDK entries...
     - name: zephyr-xtensa-espressif-esp32s2
       channel: |sdk_ng_channel|

Apply the updated definition with a :samp:`refresh`:

.. code-block:: console
   :substitutions:

   $ workshop refresh |workshop_name|

Verify the change
-------------------

Confirm the connected SDK now reports the channel you selected:

.. code-block:: console
   :substitutions:

   $ workshop info |workshop_name|

.. code-block:: text
   :substitutions:

   name:     |workshop_name|
   base:     |workshop_base|
   project:  /home/user/hello-zephyr
   status:   ready
   notes:    -
   sdks:
     system:
       installed:  (1)
     uv:
       tracking:   latest/stable
       installed:  0.9.7  2026-09-01  (3)
     zephyr:
       tracking:   |workshop_sdk_channel|
       installed:  |upstream_docs_release|  2026-08-20  (12)
     zephyr-sdk-ng:
       tracking:   |sdk_ng_channel|
       installed:  |sdk-version|  2026-09-17  (41)
     zephyr-xtensa-espressif-esp32s2:
       tracking:   |sdk_ng_channel|
       installed:  |sdk-version|  2026-09-17  (34)

Find the SDK name under the :samp:`sdks` key. Its :samp:`tracking` field must
match the channel you set in |workshop_definition_file|, and
:samp:`installed` must show the version and revision that channel publishes.

See also
--------

Tutorial:

- :ref:`tut_get_started_with_workshop`

Reference:

- :ref:`ref_workshop_environment`
