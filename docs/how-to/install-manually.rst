.. _how_install_manually:

.. meta::
   :description: Install the Zephyr source and development tools manually on
                 Ubuntu without Workshop.

How to install |product_name| manually
======================================

This guide installs |product_name| without the standard Workshop development
environment. It follows the upstream Zephyr installation model but installs
:program:`west` and its Python requirements from Ubuntu packages instead of
:command:`pip` and a Python virtual environment.

Workshop is the supported standard path. With a manual installation, you must
maintain each host dependency.

Prerequisites
-------------

Before starting, ensure you have these requirements satisfied:

* A supported Ubuntu host, we recommend |ubuntu-base|.
* Access to the internet.
* Permission to use :command:`sudo` on the host.

Install host packages and the Package Index
-------------------------------------------

To provide LTS guarantees, we encourage users to install :program:`west`, the
Zephyr toolchains and Python dependencies through the |product_name| Personal
Package Archive (PPA): |zephyr-lts-ppa|.

This will add packages globally, ff this is not desirable the rest of this
how-to can be run in a `Docker <https://snapcraft.io/docker>`_ or `LXD
<https://snapcraft.io/lxd>`_ container.

.. code-block:: console

   $ sudo add-apt-repository ppa:arctic-tern/zephyr-toolchain

Update the package index:

.. code-block:: console

   $ sudo apt update

Install the build packages:

.. code-block:: console

   $ sudo apt install --no-install-recommends \
       git cmake ninja-build gperf ccache dfu-util device-tree-compiler wget \
       xz-utils file make gcc gcc-multilib g++-multilib libsdl2-dev libmagic1

Create the west workspace
-------------------------

Install :program:`west`:

.. code-block:: console

   $ sudo apt install west

Initialize the workspace from the |source_tag| source tag in Canonical's Zephyr
manifest repository:

.. parsed-literal::

   $ west init -m |manifest_repository_url| \
   --mr |source_tag| ~/zephyrproject
   $ cd ~/zephyrproject

Download shallow copies of the pinned repositories:

.. code-block:: console

   $ west update --narrow -o=--depth=1

Install the Python packages that the Zephyr source tree requires:

.. code-block:: console

   $ sudo apt install --no-install-recommends \
       python3-yaml python3-pykwalify python3-canopen python3-packaging \
       python3-progress python3-psutil python3-pylink-square python3-serial \
       python3-requests python3-anytree python3-intelhex python3-pyelftools

Export the Zephyr CMake package:

.. code-block:: console

   $ west zephyr-export

Install the |product_name| SDK
------------------------------

The :canonical-zephyr:`sdk-ng repository <sdk-ng>` contains the LTS version of
the |zephyr-upstream| SDK.

First, ensure that SDK version listed in :file:`zephyr/SDK_VERSION` match
|sdk-version|:

.. code-block:: console
   :substitutions:

   $ cat zephyr/SDK_VERSION

   |sdk-version|

Install the common SDK files. This will register the CMake package and export
:samp:`ZEPHYR_SDK_INSTALL_DIR`:

.. code-block:: console

   $ sudo apt install rtos-zephyr-sdk-ng-common

Install the toolchain package for your target architecture. The Hello World
sample in this guide targets :samp:`qemu_x86`, which requires the
``x86_64-zephyr-elf`` toolchain:

.. code-block:: console

   $ sudo apt install rtos-zephyr-sdk-x86-64-zephyr-elf

.. note::

   If you are targeting a different board,
   search the PPA for its toolchain package:

   .. code-block:: console

      $ apt search rtos-zephyr-sdk-

.. note::

   To install every toolchain instead,
   use the ``rtos-zephyr-sdk-ng`` metapackage:

   .. code-block:: console

      $ sudo apt install rtos-zephyr-sdk-ng

Start a new shell, or source the profile script directly, so
:samp:`ZEPHYR_SDK_INSTALL_DIR` takes effect:

.. code-block:: console

   $ source /etc/profile.d/zephyr-sdk-ng.sh

West reads :samp:`ZEPHYR_SDK_INSTALL_DIR` to find the SDK.

.. note::

   The SDK toolchain packages do not include OpenOCD or its udev rules,
   unlike the upstream tarball. To flash real hardware, install OpenOCD
   from the Ubuntu archive, which already provides the required udev
   rules:

   .. code-block:: console

      $ sudo apt install openocd


Build Hello World
-----------------

Now build the Hello World sample:

.. code-block:: console

   $ cd ~/zephyrproject/zephyr
   $ west build -p always -b qemu_x86 samples/hello_world

And run the sample in QEMU:

.. code-block:: console

   $ west build -t run

Press :kbd:`Ctrl+A`, then press :kbd:`X` to stop QEMU.

See also
--------

Tutorial:

- :ref:`tut_get_started_with_workshop`

Explanation:

- :ref:`exp_development_environments`

Reference:

- :ref:`ref_repositories`
