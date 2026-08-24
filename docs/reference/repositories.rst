.. _ref_repositories:

.. meta::
   :description: URL rules and important Launchpad repositories for Canonical's
                 Zephyr LTS distribution.

Source repositories
===================

Canonical maintains the |product_name| source in the Zephyr RTOS Launchpad
project.
The :program:`west` manifest repository
is the source of truth for repository revisions.

URL format
----------

Each port keeps its upstream repository name.
Repository pages use this URL format:

.. parsed-literal::

   |launchpad_project_url|/+git/<repository>

Git operations use this URL format:

.. parsed-literal::

   |launchpad_git_base|/<repository>

For example, clone the manifest repository with :command:`git clone`:

.. parsed-literal::

   $ git clone |manifest_repository_url|

Important repositories
----------------------

.. list-table::
   :header-rows: 1

   * - Repository
     - Purpose
   * - `Zephyr manifest repository`_
     - West manifest that pins the tested |product_name| source set.
   * - `Zephyr source repository`_
     - Kernel, subsystems, boards, samples, and tests.
   * - `MCUboot repository`_
     - Secure bootloader used by Zephyr applications.
   * - `CMSIS repository`_
     - Cortex Microcontroller Software Interface Standard modules.
   * - `Nordic HAL repository`_
     - Hardware abstraction layer for Nordic Semiconductor devices.
   * - `STM32 HAL repository`_
     - Hardware abstraction layer for STM32 devices.
   * - `sdk-ng repository`_
     - Source for the Zephyr SDK toolchains and host tools.

Manifest behavior
-----------------

Canonical publishes each tested source set
as an immutable tag in the Zephyr manifest repository.
Select the required source tag with the :option:`!--mr` option to
:command:`west init`
instead of initializing from a moving branch.

When you run :command:`west update`
from a workspace that uses Canonical's manifest,
:program:`west` clones each project from the Zephyr RTOS Launchpad
project.
It checks out the revisions pinned by the manifest at the selected source tag.
It does not move the Zephyr manifest repository to a different source tag.

Do not replace the manifest revisions with moving branch names.
The pinned revisions define
the tested |product_name| source set.


See also
--------

Tutorial:

- :ref:`tut_get_started_with_workshop`

Explanation:

- :ref:`exp_canonical_distribution`

Reference:

- :ref:`ref_releases`
