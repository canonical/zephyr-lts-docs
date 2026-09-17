:relatedlinks: [Zephyr&#32;manifest](https://code.launchpad.net/~arctic-tern/zephyr-rtos/+git/zephyr-manifest), [Zephyr&#32;Project](https://www.zephyrproject.org/), [Workshop](https://documentation.ubuntu.com/workshop/)

.. _home:

.. meta::
   :description: Documentation for Canonical's Zephyr LTS distribution,
                 including setup, source repositories, and support.

Zephyr |zephyr-lts|
===================

.. toctree::
   :hidden:

   Home <self>
   Tutorial <tutorials/index>
   How-to guides <how-to/index>
   Reference <reference/index>
   Explanation <explanation/index>

.. toctree::
   :hidden:

   Release notes <release-notes/index>
   Contribute <contribute/index>


|product_name| is Canonical's long-term support distribution
of the Zephyr real-time operating system (RTOS).
Canonical maintains Zephyr and its modules
in the `Zephyr RTOS Launchpad project`_.

|Workshop|_ is the standard development environment for |product_name|.
The Zephyr Workshop SDK supplies the compiler, host tools,
Python tools, and Zephyr dependencies for this release.
Start with the :ref:`Workshop tutorial <tut_get_started_with_workshop>`.

If Workshop is not suitable for your system,
follow the :ref:`manual installation guide <how_install_manually>`.

----

.. todolist::


In this documentation
---------------------

.. list-table::
   :widths: 20 80
   :class: borderless

   * - **Tutorial**
     - :ref:`Get started with Workshop <tut_get_started_with_workshop>`

   * - **Development environments**
     - :ref:`Workshop environment <ref_workshop_environment>` •
       :ref:`Manual installation <how_install_manually>` •
       :ref:`Development environment concepts <exp_development_environments>`

   * - **Hardware**
     - :ref:`Access hardware from Workshop <how_access_hardware_from_workshop>` •
       :ref:`Flash hardware from Workshop <tut_flash_hardware>`

   * - **Source and releases**
     - :ref:`Source repositories <ref_repositories>` •
       :ref:`Releases <ref_releases>` •
       :ref:`Zephyr 24.04 release notes <release_notes_24_04>`

   * - **Project**
     - :ref:`Canonical's Zephyr distribution <exp_canonical_distribution>` •
       :ref:`Support and security <ref_support>` •
       :ref:`Contribute <contribute>`


How this documentation is organized
-----------------------------------

This documentation follows the
`Diátaxis documentation framework`_,
organizing content by the type of information users need.
The four sections serve different purposes:

:doc:`Tutorial <tutorials/index>`: A hands-on learning path
that takes you from a new development environment
to a running Zephyr application.

:doc:`How-to guides <how-to/index>`: Instructions for specific tasks,
such as installing the toolchain manually
or connecting a physical board to Workshop.

:doc:`Reference <reference/index>`: Technical details
about the Workshop environment, source repositories, releases, and support.

:doc:`Explanation <explanation/index>`: Discussion of the distribution model
and the development environments available for |product_name|.

----

.. _project_community:

Project and community
---------------------

|product_name| is based on upstream Zephyr |upstream_release|.
Canonical maintains the distribution source
and maintains its module revisions through a west manifest.

.. rubric:: Get involved

- :ref:`Contribute to this documentation <contribute>`
- `Report a documentation issue`_

.. rubric:: Releases and support

- :ref:`Release notes <release-notes>`
- :ref:`Support and security <ref_support>`

.. rubric:: Governance and policies

- `Ubuntu Code of Conduct`_
- `Security policy`_
- `License`_
