.. _how_use_workshop_from_vscode:

.. meta::
   :description: Connect Visual Studio Code to a running Workshop environment
                 and develop inside the container.

How to use Workshop from VS Code
================================

The Workshop extension for Visual Studio Code connects a VS Code window
to a running Workshop environment.
The editor, terminal, and debugger run inside the container,
while the window stays on the host.
The host needs no Zephyr SDKs or toolchains.
Each developer gets the same base and SDK channel,
and VS Code keeps IDE features
such as code completion and debugging.

Prerequisites
-------------

Before starting, ensure you have these requirements satisfied:

* Visual Studio Code installed on any host that can run Workshop.
* A launched Workshop. See :ref:`tut_get_started_with_workshop`.

The extension uses the :guilabel:`Remote - SSH` extension,
which VS Code installs automatically as a dependency.

Install the extension
---------------------

Install the :guilabel:`Workshop` extension published by Canonical
from the :guilabel:`Extensions` view or from the command line:

.. code-block:: console

   $ code --install-extension canonical.workshop
   Installing extensions...
   Installing extension 'canonical.workshop'...
   Extension 'canonical.workshop' v0.5.2 was successfully installed.


Open the project in the Workshop
--------------------------------

Open the project folder in VS Code.
The folder must contain |workshop_definition_file|,
and the Workshop must be launched:

.. code-block:: console
   :substitutions:

   $ workshop launch |workshop_name|
   $ code .

A :guilabel:`Workshop` panel appears in the :guilabel:`Activity Bar`.
It lists the Workshops defined for the project.

Click :guilabel:`Reopen in Workshop` next to your Workshop in the panel,
or run :guilabel:`Workshop: Reopen in Workshop`
from the :guilabel:`Command Palette`.
VS Code reconnects the window inside the container.

The remote indicator in the status bar shows the Workshop name
when the window is connected.

Verify the connection
---------------------

Open an integrated terminal
with :menuselection:`Terminal --> New Terminal`.
The prompt shows a shell inside the Workshop:

.. code-block:: console
   :substitutions:

   |workshop_project_prompt|

Build and run the Hello World sample to confirm
that the toolchain is available:

.. code-block:: console
   :substitutions:

   |workshop_project_prompt| west build -p always \
       -b qemu_x86 zephyr/samples/hello_world
   |workshop_project_prompt| west build -t run

The terminal prints the Zephyr boot banner
and the :samp:`Hello World!` message.
The window now uses the SDKs and toolchains installed in the Workshop
instead of the tools on the host.

Return to the local window
--------------------------

To close the connection without stopping the Workshop,
click :guilabel:`Reopen Locally` in the Workshop panel
or in the remote indicator in the status bar.

The Workshop keeps running after you return to the local window.
Stop it from the host when you no longer need it:

.. code-block:: console
   :substitutions:

   $ workshop stop |workshop_name|

Allow the extension in untrusted workspaces
-------------------------------------------

When VS Code opens a folder in Restricted Mode,
it disables most extensions, including this one.
The Workshop panel cannot reconnect or reopen locally
in an untrusted workspace.

To allow the extension to run in untrusted workspaces,
add the following to your user :file:`settings.json`
(:kbd:`Ctrl+Shift+P`, then :guilabel:`Preferences: Open User Settings (JSON)`):

.. code-block:: json

   {
     "extensions.supportUntrustedWorkspaces": {
       "canonical.workshop": {
         "supported": true
       }
     }
   }

The Workshop panel stays active in Restricted Mode,
so you can open the project in a Workshop sandbox
while the host still does not trust it.

See also
--------

Tutorial:

- :ref:`tut_get_started_with_workshop`

How-to:

- :ref:`how_access_hardware_from_workshop`

Reference:

- :ref:`ref_workshop_environment`
