.. _tut_get_started_with_workshop:

.. meta::
   :description: Build and run a Zephyr application in a complete Workshop
                 development environment.

Get started with Workshop
=========================

In this tutorial, you'll create a |product_name| workspace and build and run the
Hello World sample.

Prerequisites
-------------

* A host running |ubuntu-base| or another Linux distribution that supports snaps.
* Access to the internet.
* Permission to use :command:`sudo` on the host.

Install Workshop and LXD
------------------------

Workshop is the standard development environment for |product_name|. The
Workshop definition contains the Zephyr source, Python environment, SDK bundle,
and x86 toolchain. LXD is a container manager that Workshop uses to create and run its development environment.

Install LXD 6 and Workshop:

.. code-block:: console

   $ sudo snap install --channel=6/stable lxd
   $ sudo snap install --classic workshop

To avoid using :command:`sudo` for every LXD operation, add your user to the :samp:`lxd` group:

.. code-block:: console

   $ sudo usermod --append --groups lxd "$USER"
   $ newgrp lxd

Define a development environment
--------------------------------

Create a directory for your project:

.. code-block:: console

   $ mkdir zephyrproject
   $ cd zephyrproject

Now we must create a Workshop environment definition under :file:`.workshop/`.
You may do that manually by copying the following template:

.. code-block:: console
   :substitutions:

   $ mkdir .workshop
   $ editor .workshop/|workshop_definition|

Add the sample environment definition to the file:

.. literalinclude:: ../reference/workshop.yaml
   :language: yaml
   :caption: .workshop/|workshop_name|.yaml

Or you may have Workshop initialize the |product_name| template for you on the
command line:

.. code-block::
   :substitutions:

   $ workshop init zephyr-|product_release| --sdks zephyr,zephyr-sdk-ng,zephyr-amd6 --base |workshop_base|

But be sure to add the :samp:`sdks`, :samp:`connections` and :samp:`actions`
from the aforementioned |workshop_name_samp| yaml file.

This YAML file declares the base system, Zephyr SDKs, toolchains, and project actions:

* ``name`` an identifier for the Workshop environment.
* ``base`` an Ubuntu base image used to create the environment.
* ``sdks`` a list of the SDKs that Workshop installs.  ``name`` selects an SDK    and its ``channel`` selects the version channel to use.
* ``connections`` link the SDK components so that one component can use    another. A ``plug`` requests an interface, and a ``slot`` provides it, for    example, ``plug: zephyr:venv`` connects to ``slot: uv:venv`` so the Zephyr    environment can use the Python environment provided by ``uv``.
* ``actions`` defines commands that Workshop can run from the host

To see the other versions and channels an SDK publishes, follow
:ref:`how_find_sdk_versions`.

Launch the development environment:

.. code-block:: console
   :substitutions:

   $ workshop launch |workshop_name|

Workshop will read the definition, create the environment via LXD, and download the Ubuntu base image and SDKs.
The first launch may take several minutes.

Initialize and download the Zephyr source
-----------------------------------------

Once the development environment is launched, start a Workshop shell:

.. code-block:: console
   :substitutions:

   $ workshop shell |workshop_name|

Create a :program:`west` workspace using Canonical’s Zephyr manifest repository
and select the |source_tag_samp| source tag.

.. code-block:: console
   :substitutions:

   |workshop_project_prompt| west init \
   -m |manifest_repository_url| \
   --mr |source_tag| .

The source tag identifies an immutable, tested |product_name| source set. Verify
the selected tag:

.. code-block:: console
   :substitutions:

   |workshop_project_prompt| git -C |manifest_repository| \
   describe --tags --exact-match

which should yield:

.. code-block:: console
   :substitutions:

   |source_tag|

Download the repositories from the |product_name| manifest:

.. code-block:: console
   :substitutions:

   |workshop_project_prompt| west update --narrow -o=--depth=1

The manifest pins each repository to a tested revision. It also directs west to
the Zephyr RTOS Launchpad project.

Export the Zephyr CMake package:

.. code-block:: console
   :substitutions:

   |workshop_project_prompt| west zephyr-export

`west zephyr-export` exports the Zephyr package and registers Zephyr with CMake, so plain CMake projects can locate the Zephyr build system without relying on West to set :envvar:`ZEPHYR_BASE`.

Build and run Hello World
-------------------------

Change to the Zephyr repository:

.. code-block:: console
   :substitutions:

   |workshop_project_prompt| cd zephyr

.. important::
   By default, :envvar:`ZEPHYR_MODULES` points to the :samp:`zephyr` SDK's own
   directory. With that value set, west cannot see the modules in the
   workspace, and a build that needs a workspace module fails with a
   missing-header error. Clear the value before building in the shell:

   .. code-block:: console
      :substitutions:

      |workshop_zephyr_prompt| unset ZEPHYR_MODULES

   The ``build`` and ``flash`` actions described below already clear the
   value. For details, see :ref:`ref_workshop_environment`.

Build Hello World for the `qemu_x86` board:

.. code-block:: console
   :substitutions:

    |workshop_zephyr_prompt| west build -p always -b qemu_x86 samples/hello_world

Run the built application:

.. code-block:: console
   :substitutions:

   |workshop_zephyr_prompt| west build -t run

The console should show output similar to:

.. code-block:: text

   *** Booting Zephyr OS LTS build ... ***
   Hello World! qemu_x86

Press :kbd:`Ctrl+A`, then press :kbd:`X` to stop QEMU.

Exit the Workshop shell:

.. code-block:: console

   exit

You will return to the host's terminal.

Run Workshop actions from the host
----------------------------------

You do not have to enter the Workshop shell manually for every task. The
``actions`` mapping in the workshop manifest file defines commands
that Workshop can run from the host.

For example, the manifest file in this tutorial defines ``sync``, ``build``, and ``flash`` actions:

.. literalinclude:: ../reference/workshop.yaml
   :language: yaml
   :start-after: slot: zephyr-amd64:toolchain
   :caption: .workshop/zephyr-24-04.yaml

To update all repositories defined in the West manifest, run the ``sync`` action:

.. code-block:: console
   :substitutions:

   $ workshop run |workshop_name| -- sync

Any arguments supplied after the action name are passed to the command
defined for that action.

For example, the following command runs the ``build`` action and passes
the build options to ``west build`` through ``"$@"``:

.. code-block:: console
   :substitutions:

   $ workshop run |workshop_name| -- build -p always \
   -b qemu_x86 samples/synchronization

The ``build`` action then runs three commands:

.. code-block::

   source /var/lib/workshop/sdk/zephyr/venv/bin/activate
   cd /project/zephyr
   env -u ZEPHYR_MODULES west build -p always -b qemu_x86 samples/synchronization

You can define additional actions in the workshop manifest file to automate other tasks in a similar manner, see :workshop-docs:`Customize Workshop actions
<how-to/customize-workshops/add-actions/>`.

Next steps
----------

You now have a working |product_name| development environment.

To flash a physical board, follow :ref:`tut_flash_hardware`.

To pin an SDK to a different version, follow :ref:`how_find_sdk_versions`.

To understand the files that Workshop manages, read
:ref:`ref_workshop_environment`.
