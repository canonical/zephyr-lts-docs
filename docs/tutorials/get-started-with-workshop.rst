.. _tut_get_started_with_workshop:

.. meta::
   :description: Build and run a Zephyr application in a complete Workshop
                 development environment.

Get started with Workshop
=========================

In this tutorial, you'll create a |product_name| workspace and build and run the
Hello World sample.

Workshop is the standard development environment for |product_name|. The
Workshop definition combines the Zephyr source, Python environment, SDK bundle,
and x86 toolchain.

Install Workshop
----------------

Prerequisites
~~~~~~~~~~~~~

Before starting, ensure you have these requirements satisfied:

* A host running |ubuntu-base| or another Linux distribution that supports snaps.
* Access to the internet.
* Permission to use :command:`sudo` on the host.

Install LXD 6 and Workshop:

.. code-block:: console

   $ sudo snap install --channel=6/stable lxd
   $ sudo snap install --classic workshop

Add your user to the :samp:`lxd` group:

.. code-block:: console

   $ sudo usermod --append --groups lxd "$USER"
   $ newgrp lxd

Create the project
------------------

Create a project directory:

.. code-block:: console

   $ mkdir zephyrproject
   $ cd zephyrproject

Create the Workshop definition under :file:`.workshop/`:

.. parsed-literal::

   $ mkdir .workshop
   $ editor .workshop/|workshop_definition|

Add this content to the file:

.. todo::

   Jeff: This pulls in 3.7/stable zephyr. We need this to be 24.04/stable.
   :issue:`RTOS-226 <RTOS-226>`


.. literalinclude:: ../reference/workshop.yaml
   :language: yaml
   :caption: .workshop/zephyr-24-04.yaml

Launch the development environment:

.. parsed-literal::

   $ workshop launch |workshop_name|

Workshop downloads the Ubuntu base and the SDKs in the definition.
The first launch can take several minutes.

Download the source
-------------------

Open a shell in the Workshop:

.. parsed-literal::

   $ workshop shell |workshop_name|

Initialize a :program:`west` workspace from the |source_tag| source tag in
Canonical's Zephyr manifest repository:

.. parsed-literal::

   |workshop_project_prompt| west init \
   -m |manifest_repository_url| \
   --mr |source_tag| .

The source tag identifies an immutable, tested |product_name| source set. Verify
the selected tag:

.. parsed-literal::

   |workshop_project_prompt| git -C |manifest_repository| \
   describe --tags --exact-match

   |source_tag|

Download the repositories from the |product_name| manifest:

.. parsed-literal::

   |workshop_project_prompt| west update

The manifest pins each repository to a tested revision. It also directs west to
the Zephyr RTOS Launchpad project.

Export the Zephyr CMake package:

.. parsed-literal::

   |workshop_project_prompt| west zephyr-export

Extract the SDK host tools
--------------------------

.. todo::

   Jeff: this section is needed until :issue:`RTOS-226 <RTOS-226>` and
   :issue:`RTOS-225 <RTOS-225>` are resolved.

.. parsed-literal::

   |workshop_project_prompt| sudo bash /var/lib/workshop/sdk/zephyr/zephyr-sdk/zephyr-sdk/zephyr-sdk-x86_64-hosttools-standalone-0.9.sh -d ~/hosttools -y -n
   |workshop_project_prompt| echo 'export PATH=~/hosttools/sysroots/x86_64-pokysdk-linux/usr/bin:$PATH' >> ~/.profile

Build and run Hello World
-------------------------

Change to the Zephyr repository:

.. parsed-literal::

   |workshop_project_prompt| cd zephyr

Build Hello World for the QEMU x86 board:

.. todo::

   Jeff: these environment variables must be passed until :issue:`sdk issue
   RTOS-226 <RTOS-226>` and :issue:`RTOS-225 <RTOS-225>` are resolved.

.. parsed-literal::

   |workshop_zephyr_prompt| west build -p always -b qemu_x86 samples/hello_world -- \
    -DZEPHYR_TOOLCHAIN_VARIANT=cross-compile \
    -DCROSS_COMPILE=/var/lib/workshop/sdk/zephyr/zephyr-sdk/zephyr-sdk/x86_64-zephyr-elf/bin/x86_64-zephyr-elf-

Run the application in QEMU:

.. parsed-literal::

   |workshop_zephyr_prompt| west build -t run

The console should show output similar to:

.. code-block:: text

   *** Booting Zephyr OS build ... ***
   Hello World! qemu_x86

Press :kbd:`Ctrl+A`, then press :kbd:`X` to stop QEMU.
Run :command:`exit` to leave the Workshop shell.

Use the project actions
-----------------------

Instead of manually entering a workshop shell, you may also run ``actions`` from
the host's project directory.

For example, one can run the ``sync`` action to synchronize all manifest
projects with the revisions selected by the source tag:

.. parsed-literal::

   $ workshop run |workshop_name| -- sync

.. todo::

   Jeff: the following is not tested yet

Build another application:

.. parsed-literal::

   $ workshop run |workshop_name| -- build -p always \
   -b qemu_x86 samples/basic/blinky

Next steps
----------

You now have a working |product_name| development environment.

To flash a physical board, follow :ref:`tut_flash_hardware`.

To understand the files that Workshop manages, read
:ref:`ref_workshop_environment`.
