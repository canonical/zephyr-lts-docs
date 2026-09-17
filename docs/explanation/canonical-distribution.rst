.. _exp_canonical_distribution:

.. meta::
   :description: How Canonical creates and maintains its Zephyr LTS
                 distribution from an upstream Zephyr release.

Canonical's Zephyr distribution
================================

To provide long-term support, Canonical forks Zephyr and maintains the Zephyr module repositories and any other repositories required to support or develop Zephyr |upstream_release|.


The LTS distribution stores these sources in `Launchpad
<https://code.launchpad.net/~arctic-tern>`__. Each upstream repository has a
corresponding git repository with the same name in the Zephyr RTOS Launchpad
project. For example, the upstream |upstream_sdk_ng_link| has a
corresponding |product_name| sdk-ng
:canonical-zephyr:`hosted <sdk-ng>` on Launchpad.

The distribution diverges from upstream in the provided :canonical-zephyr:`west
manifest <west-manifest>`, which is altered to target the distribution's forks.
Canonical publishes the manifest repository with an immutable source tag for
each tested source set.

This model preserves the standard multi-repository workflow and yields one
source namespace for maintenance changes.

The role of the manifest
------------------------

A Zephyr workspace contains many repositories. The manifest records their URLs,
paths, groups, and revisions.

The manifest revisions form a unified, tested, source set. The aforementioned
source tag fixes the manifest repository to this tested set. This way
:command:`west update` keeps repositories aligned, while still allowing one to
:command:`git pull` to move one repository outside the tested set.

Relationship and divergence with upstream
-----------------------------------------

Canonical keeps upstream project names and source structure. This structure
preserves familiar upstream concepts, commands, and application layouts.

Canonical can add maintenance patches to each forked repository in accordance
with upstream and will continue to patch for the duration of the long-term
support offering. The Canonical repository history identifies these changes. The
release notes describe changes that affect users.

A central divergence with upstream is the use of a personal package archive
(PPA), rather than a python package index, for python dependencies. The
|zephyr-lts-ppa| provided by Canonical contains the python dependencies normally
installed by ``pip`` during ``pip install -r requirements.txt``. However, using
the PPA installs all python dependencies globally rather than in a ``venv``
environment. This tradeoff is purposeful; the PPA provides Canonical's Security
guarantees for each python dependency. We recommend users to employ either
`Docker <https://snapcraft.io/docker>`_ or `LXD <https://snapcraft.io/lxd>`_
containers to mitigate the cost of losing the python sandbox.

Another divergence with upstream is that Canonical's distribution patches the
``VERSIONS`` file to match |product_release| rather than |upstream_release|.
Similarly, we patch the boot banner to welcome our users to the Canonical
distribution.

See also
--------

How-to:

- :ref:`how_install_ppa_dependencies`

Reference:

- :ref:`ref_repositories`
- :ref:`ref_releases`
