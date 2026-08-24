.. _ref_releases:

.. meta::
   :description: Release naming, update channels, and source identification for
                 Canonical's Zephyr LTS distribution.

Releases
========

Canonical uses an Ubuntu-style year and month
for Zephyr LTS releases.
The product name |product_release_samp|
identifies this LTS release series.

Release identifiers
-------------------

.. list-table::
   :header-rows: 1

   * - Item
     - Identifier
   * - Product release
     - |product_name|
   * - Workshop SDK channel
     - |workshop_sdk_channel_samp|
   * - Manifest repository
     - |manifest_repository_url_samp|
   * - Source tag
     - |source_tag_samp|
   * - Upstream base
     - Zephyr |upstream_release| LTS

Updates
-------

Canonical publishes compatible tool updates
to the |workshop_sdk_channel_samp| SDK channel.
Apply an SDK update with :command:`workshop refresh`:

.. parsed-literal::

   $ workshop refresh |workshop_name|

Each |product_name| source update has a new immutable tag.
To move an existing workspace to a newer source tag,
fetch and check out the tag in the manifest repository:

.. parsed-literal::

   $ git -C |manifest_repository| fetch origin tag <source-tag>
   $ git -C |manifest_repository| switch --detach <source-tag>

Then synchronize the other projects
with the revisions in that tagged manifest:

.. parsed-literal::

   $ workshop run |workshop_name| -- sync

To record a reproducible source identifier,
query the manifest repository tag
from the workspace root:

.. parsed-literal::

   $ git -C |manifest_repository| describe --tags --exact-match


See also
--------

Explanation:

- :ref:`exp_canonical_distribution`

Reference:

- :ref:`ref_repositories`
- :ref:`release-notes`
