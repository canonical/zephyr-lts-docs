.. _exp_canonical_distribution:

.. meta::
   :description: How Canonical creates and maintains its Zephyr LTS
                 distribution from an upstream Zephyr LTS release.

Canonical's Zephyr distribution
================================

|product_name| starts from the upstream Zephyr |upstream_release| LTS release.
Canonical maintains a coordinated set
of Zephyr and module repositories.

The distribution stores its source in Launchpad.
Each upstream repository has a port with the same name
in the Zephyr RTOS Launchpad project.
The Zephyr :program:`west` manifest
records the tested revision of each port.
Canonical publishes the manifest repository with an immutable source tag
for each tested source set.

This model preserves the standard multi-repository workflow
and gives Canonical one source namespace
for maintenance changes.

The role of the manifest
------------------------

A Zephyr workspace contains many repositories.
The manifest records their URLs, paths, groups, and revisions.

The manifest revisions form one tested source set.
For this reason,
:command:`west update` keeps repositories aligned,
while a separate :command:`git pull`
can move one repository outside the tested set.
The source tag fixes the manifest repository itself to that tested set.

Relationship with upstream
--------------------------

Canonical keeps upstream project names and source structure.
This structure preserves familiar upstream concepts,
commands, and application layouts.

Canonical can add maintenance patches to a port.
The Canonical repository history identifies these changes.
The release notes describe changes that affect users.


See also
--------

Reference:

- :ref:`ref_repositories`
- :ref:`ref_releases`
