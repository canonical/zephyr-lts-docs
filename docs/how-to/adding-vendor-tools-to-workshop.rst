.. _how_adding_vendor_tools_to_workshop:

.. meta::
   :description: How to install vendor flash and debug tools as an in-project
                 SDK for Zephyr Workshop, with SEGGER J-Link and nRF Util as
                 worked examples.

How to add vendor tools to Workshop
====================================

Some west runners call vendor-supplied tools provided separately from the Zephyr SDK bundle and Ubuntu archive. Such tools can be packaged as an in-project SDK to
be included in the Workshop environment via a :file:`setup-project` hook. This
will lead :command:`workshop refresh` to install them automatically. This guide
covers the general procedure, then works through it with two examples: `SEGGER
J-Link <https://www.segger.com/downloads/jlink/>`_ for the :samp:`jlink` runner,
and `nRF Util <https://www.nordicsemi.com/Products/Development-tools/nRF-Util>`_
for the :samp:`nrfutil` runner.

Prerequisites
-------------

Before starting, ensure you have these requirements satisfied:

* A launched |workshop_name_samp| Workshop with a synced workspace, as created
  in :ref:`tut_get_started_with_workshop`.
* A development board connected to the host, with a custom-device plug already
  connected for its flash or debug probe, as described in
  :ref:`how_access_hardware_from_workshop`.

All host commands in this guide must be run from the project directory that
contains |workshop_definition_file|.

Create a tool SDK
------------------

Create an in-project SDK directory with a :file:`hooks` subdirectory:

.. code-block:: console

   $ mkdir -p .workshop/<TOOL_SDK_NAME>/hooks
   $ editor .workshop/<TOOL_SDK_NAME>/sdk.yaml

This SDK carries no plugs of its own. Hardware access still comes from the
custom-device plug declared in your board-device SDK. Give the SDK a name
only:

.. code-block:: yaml
   :caption: .workshop/<TOOL_SDK_NAME>/sdk.yaml

   name: <TOOL_SDK_NAME>

and now we can add the hook file.

Add an install hook
--------------------

Create the :file:`setup-project` hook:

.. code-block:: console

   $ editor .workshop/<TOOL_SDK_NAME>/hooks/setup-project

Populate the hook with the commands that download and install the vendor tool,
for example a :command:`curl` download followed by :command:`apt-get install`:

.. code-block:: bash
   :caption: .workshop/<TOOL_SDK_NAME>/hooks/setup-project

   #!/bin/bash
   set -euo pipefail

   # Download the tool from the vendor.
   tool_archive=/tmp/<TOOL_ARCHIVE>
   curl -sSL -o "${tool_archive}" "<TOOL_DOWNLOAD_URL>"

   # Install it, for example as a Debian package...
   sudo apt-get update
   sudo apt-get install -y "${tool_archive}"

   rm -f "${tool_archive}"

Now make the hook executable on the host:

.. code-block:: console

   $ chmod +x .workshop/<TOOL_SDK_NAME>/hooks/setup-project

Add the tool SDK
-----------------

Add the in-project SDK to the :samp:`sdks` list in |workshop_definition_file|:

.. code-block:: yaml

   sdks:
     # Existing SDK entries...
     - name: project-<TOOL_SDK_NAME>

Apply the updated definition:

.. code-block:: console
   :substitutions:

   $ workshop refresh |workshop_name|

The hook runs only during a refresh and will reinstall the tool every time
the Workshop filesystem is rebuilt.

Verify the tool
-----------------

Open a shell in the Workshop and check that the tool is on the :envvar:`PATH`:

.. code-block:: console
   :substitutions:

   $ workshop shell |workshop_name|
   |workshop_project_prompt| command -v <TOOL_BINARY>

You should observe a filepath for the tool. If nothing is returned, the tool is absent, you should review the hook and rerun :command:`workshop refresh`.

The rest of this guide applies the procedure above to two Nordic vendor tools
that share a single tool SDK, :samp:`nordic-tools`, because both are needed to
flash the same class of Nordic boards.

Example: SEGGER J-Link
------------------------

The :samp:`jlink` runner flashes Nordic boards through their on-board J-Link
debug probe. Neither the SEGGER J-Link tools nor a Linux package for them is
part of the SDK bundle or the Ubuntu archive.

Create the tool SDK:

.. code-block:: console

   $ mkdir -p .workshop/nordic-tools/hooks
   $ editor .workshop/nordic-tools/sdk.yaml

.. code-block:: yaml
   :caption: .workshop/nordic-tools/sdk.yaml

   name: nordic-tools

Open the `J-Link downloads page <https://www.segger.com/downloads/jlink/>`_
and find the current 64-bit Linux :samp:`.deb` package under **J-Link Software
and Documentation Pack**. Note its file name; the package name changes with
each J-Link release.

Create the :file:`setup-project` hook, substituting the file name you noted
above, and accepting the SEGGER license agreement non-interactively:

.. code-block:: bash
   :caption: .workshop/nordic-tools/hooks/setup-project

   #!/bin/bash
   set -euo pipefail

   jlink_deb=/tmp/JLink_Linux_x86_64_deb.deb
   curl -sSL --data 'accept_license_agreement=accepted' \
       -o "${jlink_deb}" \
       "https://www.segger.com/downloads/jlink/<PACKAGE_FILE_NAME>"
   sudo apt-get update
   sudo apt-get install -y "${jlink_deb}"
   rm -f "${jlink_deb}"

Replace :samp:`<PACKAGE_FILE_NAME>` with the file name from the downloads
page, then make the hook executable:

.. code-block:: console

   $ chmod +x .workshop/nordic-tools/hooks/setup-project

Add the SDK and apply it:

.. code-block:: yaml

   sdks:
     # Existing SDK entries...
     - name: project-nordic-tools

.. code-block:: console
   :substitutions:

   $ workshop refresh |workshop_name|

Verify the tool and flash with the :samp:`jlink` runner:

.. code-block:: console
   :substitutions:

   $ workshop shell |workshop_name|
   |workshop_project_prompt| command -v JLinkExe
   /usr/bin/JLinkExe

.. code-block:: console
   :substitutions:

   |workshop_zephyr_prompt| west flash -r jlink

Example: nRF Util
-------------------

The :samp:`nrfutil` runner flashes Nordic boards through the :samp:`device`
command bundle of nRF Util. nRF Util is not part of the SDK bundle or the
Ubuntu archive either.

If you already created the :samp:`nordic-tools` SDK for J-Link above, reuse it
and append to the existing hook. Otherwise create the SDK as shown in the
J-Link example first.

Open the `nRF Util downloads page
<https://www.nordicsemi.com/Products/Development-tools/nRF-Util/Download>`_
and copy the download link for **Linux (x64)**.

Append the download and the :samp:`device` command bundle to the hook:

.. code-block:: bash
   :caption: .workshop/nordic-tools/hooks/setup-project

   nrfutil_bin=/usr/local/bin/nrfutil
   sudo curl -sSL -o "${nrfutil_bin}" "<NRFUTIL_LINUX_X64_URL>"
   sudo chmod +x "${nrfutil_bin}"
   nrfutil install device --yes

Replace :samp:`<NRFUTIL_LINUX_X64_URL>` with the link you copied. The
:samp:`device` command bundle includes the commands the :samp:`nrfutil` runner uses to flash and manage devices.

If you have not already applied the :samp:`nordic-tools` SDK, add it to
|workshop_definition_file| and refresh, as shown in the J-Link example.
Otherwise, reapply the definition to pick up the updated hook:

.. code-block:: console
   :substitutions:

   $ workshop refresh |workshop_name|

Verify the tool and flash with the :samp:`nrfutil` runner:

.. code-block:: console
   :substitutions:

   $ workshop shell |workshop_name|
   |workshop_project_prompt| command -v nrfutil
   /usr/local/bin/nrfutil

.. code-block:: console
   :substitutions:

   |workshop_zephyr_prompt| west flash -r nrfutil

The board documentation lists the options each runner accepts.

See also
--------

Tutorial:

- :ref:`tut_flash_hardware`

How-to guides:

- :ref:`how_access_hardware_from_workshop`

Reference:

- :ref:`ref_workshop_environment`
