.. _release_notes_24_04:

.. meta::
   :description: Initial release notes for this Zephyr LTS distribution.

Zephyr 24.04 release notes
==========================

|product_name| is Canonical's distribution of upstream Zephyr
|upstream_release| LTS.

Development environment
-----------------------

The standard development path uses Workshop.
Use the :samp:`zephyr` SDK
from the |workshop_sdk_channel_samp| channel.

Source distribution
-------------------

Canonical maintains the source repositories
in the `Zephyr RTOS Launchpad project`_.
The Canonical :program:`west` manifest
pins the tested repository revisions.
The current source set is published with the immutable |source_tag_samp| tag.

Known limitations
-----------------

Workshop support requires an Ubuntu or snap-enabled Linux host.
Use the manual installation path
on an |ubuntu-base| host that cannot run Workshop.

The upstream pip model (:command:`pip install -r requirements.txt`) does
not work on a clean |ubuntu-base| image. It builds C extensions such as
``ruamel-yaml-clib`` from source, which requires ``python3-dev``, a
package that is not preinstalled. Install ``python3-dev`` or use the
:ref:`host install guide <how_install_on_host_system>`, which installs
the Python requirements as packages.


See also
--------

- :ref:`ref_releases`
- :ref:`ref_repositories`
