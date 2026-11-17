.. _ref_releases:

.. meta::
   :description: Release naming, update channels, and source identification for
                 Canonical's Zephyr distribution.

Releases
========

Canonical uses an Ubuntu-style year and month for Zephyr LTS and interim
releases. The product name |product_release_samp| identifies this |release_kind|
release series.

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
     - Zephyr |upstream_release|
   * - Upstream SDK
     - |sdk-version|

Updates
-------

Canonical publishes compatible tool updates to the |sdk_ng_channel_samp|
SDK channel. Apply an SDK update with :command:`workshop refresh`:

.. code-block:: console
   :substitutions:

   $ workshop refresh |workshop_name|

Software in the |product_name| Personal Package Archive (PPA), |zephyr-lts-ppa|,
is updated on a rolling basis, as determined by the security scanning that
Canonical provides.

Each |product_name| source update is given a new immutable tag. To move an
existing workspace to a newer source tag, fetch and check out the tag in the
manifest repository:

.. code-block:: console
   :substitutions:

   $ git -C |manifest_repository| fetch origin tag <source-tag>
   $ git -C |manifest_repository| switch --detach <source-tag>

Then synchronize the other projects with the revisions in that tagged manifest:

.. code-block:: console
   :substitutions:

   $ workshop run |workshop_name| -- sync

To record a reproducible source identifier, query the manifest repository tag
from the workspace root:

.. code-block:: console
   :substitutions:

   $ git -C |manifest_repository| describe --tags --exact-match

Previous Releases
-----------------

All previous releases publish their source tags in the manifest repository
|manifest_repository_url_samp|.

.. list-table::
   :header-rows: 1

   * - Product release
     - Workshop SDK channel
     - Source tag
     - Upstream base
     - Upstream SDK
   * - Zephyr 26.04 LTS
     - ``26.04/stable``
     - ``26.04.0``
     - Zephyr 4.4
     - 1.0.1
   * - Zephyr 24.04 LTS
     - ``24.04/stable``
     - ``24.04.0``
     - Zephyr 3.7
     - 0.16.9

.. _ref_releases_support_periods:

Support periods
---------------

Each release line receives security fixes until its Canonical end of life.
After that date, the release line no longer receives security fixes.
The `release plan
<https://discourse.ubuntu.com/t/zephyr-lts-release-plan-and-activity/89358>`__
lists planned releases and is updated as plans change.

.. list-table::
   :header-rows: 1

   * - Release line
     - Support level
     - Release date
     - Zephyr version
     - Upstream end of life
     - Canonical end of life
   * - 26.10
     - Interim
     - Dec 2026
     - 4.5
     - Oct 2027
     - Jul 2027
   * - 26.04
     - LTS
     - Sep 2026
     - 4.4
     - Apr 2027
     - Apr 2037
   * - 24.04
     - LTS
     - Sep 2026
     - 3.7
     - Jul 2029
     - Jul 2039

See also
--------

Explanation:

- :ref:`exp_canonical_distribution`
- :ref:`exp_security_support`

Reference:

- :ref:`ref_repositories`
- :ref:`release-notes`
