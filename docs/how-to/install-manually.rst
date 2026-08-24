.. _how_install_manually:

.. meta::
   :description: Install the Zephyr source and development tools manually on
                 Ubuntu without Workshop.

How to install Zephyr manually
==============================

This guide installs |product_name|
without the standard Workshop development environment.
It follows the upstream Zephyr installation model
and keeps Python packages in a virtual environment.

Workshop is the supported standard path.
With a manual installation,
you must maintain each host dependency.

Prerequisites
-------------

Before starting, ensure you have these requirements satisfied:

* A supported Ubuntu host.
* Access to the internet.
* Permission to use :command:`sudo` on the host.

Install host packages
---------------------

Update the package index:

.. code-block:: console

   $ sudo apt update

Install the build and Python packages:

.. code-block:: console

   $ sudo apt install --no-install-recommends \
       git cmake ninja-build gperf ccache dfu-util device-tree-compiler wget \
       python3-dev python3-pip python3-setuptools python3-tk python3-venv \
       python3-wheel xz-utils file make gcc gcc-multilib g++-multilib \
       libsdl2-dev libmagic1

Create the west workspace
-------------------------

Create a Python virtual environment,
then activate it:

.. code-block:: console

   $ mkdir -p ~/zephyrproject
   $ python3 -m venv ~/zephyrproject/.venv
   $ source ~/zephyrproject/.venv/bin/activate

Install :program:`west`:

.. code-block:: console

   (.venv) $ pip install west

Initialize the workspace from the |source_tag| source tag
in Canonical's Zephyr manifest repository:

.. parsed-literal::

   (.venv) $ west init \
       -m |manifest_repository_url| \
       --mr |source_tag| ~/zephyrproject
   (.venv) $ cd ~/zephyrproject

Download shallow copies of the pinned repositories:

.. code-block:: console

   (.venv) $ west update --narrow -o=--depth=1

This fetches only the selected revisions with one commit of history,
which reduces the download size and disk usage.

Install the Python requirements
from the Zephyr source:

.. code-block:: console

   (.venv) $ pip install -r zephyr/scripts/requirements.txt

Export the Zephyr CMake package:

.. code-block:: console

   (.venv) $ west zephyr-export

Install a toolchain
-------------------

Install the Zephyr SDK version
that the source tree specifies.
Read the version from :file:`SDK_VERSION`:

.. code-block:: console

   (.venv) $ cat zephyr/SDK_VERSION

Follow the `upstream Zephyr SDK installation procedure`_.
Install the version from :file:`SDK_VERSION`.

The Zephyr SDK supplies cross-compilers,
QEMU, and OpenOCD.
The `sdk-ng repository`_
contains Canonical's port of its source.

Check the installation
----------------------

Build the Hello World sample:

.. code-block:: console

   (.venv) $ cd ~/zephyrproject/zephyr
   (.venv) $ west build -p always -b qemu_x86 samples/hello_world

Run the sample in QEMU:

.. code-block:: console

   (.venv) $ west build -t run

Press :kbd:`Ctrl+A`, then press :kbd:`X` to stop QEMU.

Activate the virtual environment before each development session:

.. code-block:: console

   $ source ~/zephyrproject/.venv/bin/activate


See also
--------

Tutorial:

- :ref:`tut_get_started_with_workshop`

Explanation:

- :ref:`exp_development_environments`

Reference:

- :ref:`ref_repositories`
