.. _how_install_ppa_dependencies:

.. meta::
   :description: Install PPA packages with the Canonical version pin inside
                 a Workshop container, in the shell or through an
                 in-project SDK.

How to install PPA dependencies in Workshop
===========================================

|product_name| publishes pinned Python dependencies, toolchains, and
Zephyr modules through the |zephyr-lts-ppa| Personal Package Archive (PPA).
A Workshop container uses the Ubuntu archive by default, so packages it
installs do not carry the Canonical version pin.

This guide has two approaches. The ephemeral approach runs the commands
in the container shell. The persistent approach installs the same
packages through an in-project SDK, which re-applies them on every
rebuild and survives :command:`workshop refresh`.

Prerequisites
-------------

Before starting, ensure you have these requirements satisfied:

* A running |workshop_name_samp| Workshop, as described in
  :ref:`tut_get_started_with_workshop`.
* Permission to use :command:`sudo` in the Workshop container.

Ephemeral install
-----------------

The ephemeral approach applies to the current container only.
A :command:`workshop refresh` removes the changes.

Open a shell in the Workshop:

.. code-block:: console
   :substitutions:

   $ workshop shell |workshop_name|

Add the PPA and refresh the package index:

.. code-block:: console
   :substitutions:

   $ sudo add-apt-repository |zephyr-lts-ppa|
   $ sudo apt update

Install the version pin:

.. code-block:: console
   :substitutions:

   $ sudo apt install |zephyr-ppa-pin|

The pin package |zephyr-ppa-pin_samp| sets the apt preference of the
PPA to 1001, higher than the 500 of the Ubuntu archive. With the pin
installed, apt selects the PPA version of a package whenever both
sources publish it. To confirm the pin, check the policy of a package
that both sources publish:

.. code-block:: console

   $ apt-cache policy west

The PPA version must be the installed and candidate version,
at preference 1001:

.. code-block:: text
   :substitutions:

   west:
     Installed: 1.5.0-1+ppa20260916171518
     Candidate: 1.5.0-1+ppa20260916171518
     Version table:
    *** 1.5.0-1+ppa20260916171518 1001
         1001 |ppa-content-url| resolute/main amd64 Packages
        1.5.0-1 500
         500 http://archive.ubuntu.com/ubuntu resolute/universe amd64 Packages

To install every package that the PPA publishes, including the Zephyr
modules, install the package names from the downloaded PPA index:

.. code-block:: console
   :substitutions:

   $ sudo apt install -y $(
     for index in /var/lib/apt/lists/*|ppa-archive|*_Packages*; do
       case "$index" in
         *.lz4) lz4 -dc "$index" ;;
         *)     cat "$index" ;;
       esac
     done |
     awk '/^Package:/ { print $2 }' | sort -u
   )

To install only the base, build-test, and run-test dependencies,
exclude the Zephyr modules and install the package list explicitly:

.. code-block:: console

   $ sudo apt install -y \
     gcovr junitparser mypy openocd patool pykwalify reuse west \
     python3-anytree python3-can python3-canopen python3-cbor python3-colorama \
     python3-coverage python3-dotenv python3-intelhex python3-jsonschema \
     python3-junitparser python3-mypy python3-natsort python3-numpy \
     python3-numpy-dev python3-opencv python3-packaging python3-packaging-whl \
     python3-ply python3-psutil python3-pyelftools python3-pykwalify \
     python3-pylink-square python3-pyocd python3-pytest python3-pytest-subtests \
     python3-requests python3-semver python3-serial python3-spdx-tools \
     python3-tabulate python3-tqdm python3-yaml esptool

.. note::

   ESP32 boards need the apt copy of ``esptool`` from the PPA. The pip
   copy builds and flashes, but :command:`west espressif monitor`
   requires the apt package. Both install commands include it.

Grant the container user access to serial devices:

.. code-block:: console

   $ sudo usermod -a -G dialout workshop

Exit the shell and re-enter it so the group change takes effect.

Persistent install
------------------

The persistent approach places the same commands in an in-project SDK.
Every Workshop build runs the SDK setup hooks, so the PPA and the pin
survive :command:`workshop refresh`.

On the host, create the in-project SDK directory and its files:

.. code-block:: console
   :substitutions:

   $ mkdir -p .workshop/|workshop_name|-sdk/hooks
   $ touch .workshop/|workshop_name|-sdk/sdk.yaml
   $ touch .workshop/|workshop_name|-sdk/hooks/setup-base
   $ touch .workshop/|workshop_name|-sdk/hooks/setup-project

Paste the PPA setup into ``.workshop/|workshop_name|-sdk/hooks/setup-base``.
The hook runs as root, so the commands need no :command:`sudo`:

.. code-block:: shell
   :substitutions:

   # Add the PPA and its version pin.
   add-apt-repository |zephyr-lts-ppa|
   apt update
   apt install -y |zephyr-ppa-pin|
   # Install the base, build-test, and run-test dependencies.
   apt install -y \
     gcovr junitparser mypy openocd patool pykwalify reuse west \
     python3-anytree python3-can python3-canopen python3-cbor python3-colorama \
     python3-coverage python3-dotenv python3-intelhex python3-jsonschema \
     python3-junitparser python3-mypy python3-natsort python3-numpy \
     python3-numpy-dev python3-opencv python3-packaging python3-packaging-whl \
     python3-ply python3-psutil python3-pyelftools python3-pykwalify \
     python3-pylink-square python3-pyocd python3-pytest python3-pytest-subtests \
     python3-requests python3-semver python3-serial python3-spdx-tools \
     python3-tabulate python3-tqdm python3-yaml esptool
   # Ensure hardware is detectable within the container.
   usermod -a -G dialout workshop

Paste the following into
``.workshop/|workshop_name|-sdk/hooks/setup-project``:

.. code-block:: shell

   echo 'unset ZEPHYR_MODULES' >> ~/.profile

Describe the SDK in ``.workshop/|workshop_name|-sdk/sdk.yaml``:

.. code-block:: yaml
   :substitutions:

   name: |workshop_name|-sdk
   summary: Zephyr |product_release| - PPA + venv

Register the in-project SDK in |workshop_definition_file|:

.. code-block:: yaml
   :substitutions:

   sdks:
     ...  # existing SDKs
     - name: project-|workshop_name|-sdk

Refresh the Workshop, then enter the shell:

.. code-block:: console
   :substitutions:

   $ workshop refresh |workshop_name|
   $ workshop shell |workshop_name|

See also
--------

Tutorial:

- :ref:`tut_get_started_with_workshop`

How-to:

- :ref:`how_install_manually`

Explanation:

- :ref:`exp_canonical_distribution`
