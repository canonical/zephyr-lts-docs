.. _how_install_ppa_dependencies:

.. meta::
   :description: Install PPA packages with the Canonical version pin inside
                 a Workshop container.

How to install PPA dependencies in Workshop
===========================================

|product_name| publishes pinned Python dependencies, toolchains, and
Zephyr modules through the |zephyr-lts-ppa| Personal Package Archive (PPA).
A Workshop container uses the Ubuntu archive by default, so packages it
installs do not carry the Canonical version pin.

This guide adds the PPA to a Workshop, installs the version pin, and
installs PPA packages by their Launchpad origin.

Prerequisites
-------------

Before starting, ensure you have these requirements satisfied:

* A running |workshop_name_samp| Workshop, as described in
  :ref:`tut_get_started_with_workshop`.
* Permission to use :command:`sudo` in the Workshop container.

Open a shell in the Workshop:

.. code-block:: console
   :substitutions:

   $ workshop shell |workshop_name|

Add the PPA
-----------

Add the PPA to the container and refresh the package index:

.. code-block:: console
   :substitutions:

   $ sudo add-apt-repository |zephyr-lts-ppa|
   $ sudo apt update

Install the version pin
-----------------------

The pin package |zephyr-ppa-pin_samp| sets the apt preference of the PPA
to 1001, higher than the 500 of the Ubuntu archive. With the pin
installed, apt selects the PPA version of a package whenever both
sources publish it:

.. code-block:: console
   :substitutions:

   $ sudo apt install |zephyr-ppa-pin|

To confirm the pin, check the policy of a package that both sources
publish:

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

Install the packages
--------------------

Install every package that the PPA publishes:

.. code-block:: console
   :substitutions:

   $ sudo apt install '?origin(|ppa-origin|)'

The :samp:`?origin(...)` query selects packages by their Launchpad
origin, so apt installs only the packages from |zephyr-lts-ppa|.

The PPA also publishes the Zephyr modules. To install only the Python
dependencies, exclude the modules section:

.. code-block:: console
   :substitutions:

   $ sudo apt install '?origin(|ppa-origin|) !?section(zephyr-modules)'

Persistence
-----------

The commands above apply to the current container.
To keep the PPA and the pin across container rebuilds,
place the same commands in the Workshop setup hook:

.. code-block:: text
   :substitutions:

   .workshop/|workshop_name|/hooks/setup-base

See also
--------

Tutorial:

- :ref:`tut_get_started_with_workshop`

How-to:

- :ref:`how_install_on_host_system`

Explanation:

- :ref:`exp_canonical_distribution`
