.. _exp_development_environments:

.. meta::
   :description: Why Workshop is the standard Zephyr development path and when
                 to use a manual installation.

Development environments
========================

Zephyr development needs host tools, Python packages, and target toolchains.
Their compatible versions change between Zephyr releases.

Workshop keeps this software in a versioned development environment.
The :samp:`zephyr` SDK channel
binds the tools to |product_name|.
The project directory stays on the host
and is mounted at :file:`/project`.

Why Workshop is the standard path
---------------------------------

Workshop gives each developer the same base and SDK channel.
It reduces differences between workstations and CI jobs.

An SDK refresh updates the tools as one tested unit.
An immutable source tag selects the manifest and repository revisions
as a separate tested unit.
This design keeps tool updates separate from source updates.

Hardware access is explicit.
Workshop does not connect custom-device interfaces automatically.
The developer grants access only when a board needs it.

When to install manually
------------------------

A manual installation is useful when Workshop cannot run on the host.
It is also useful when a developer must inspect each tool separately.

The manual path has the same source manifest and west workflow.
However, the developer maintains the host packages, Python environment,
Zephyr SDK, and device permissions.

Both paths produce standard Zephyr workspaces.
They differ in how the host tools
and toolchains are supplied.


See also
--------

Tutorial:

- :ref:`tut_get_started_with_workshop`

How-to guides:

- :ref:`how_install_manually`

Reference:

- :ref:`ref_workshop_environment`
