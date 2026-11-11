.. _how_get_security_updates:

.. meta::
   :description: Check for, apply, and deploy Zephyr LTS security updates,
                 and learn how Canonical announces them.

How to get security updates
===========================

Canonical delivers security fixes for |product_name| as new source updates.
Each update has a new immutable source tag.
Only the latest update of the |product_release| release series
receives security fixes, so keep your workspace on it.

Prerequisites
-------------

Before starting, ensure you have these requirements satisfied:

* A |product_name| workspace, in Workshop or on a host system.
* No uncommitted changes in the workspace repositories that you need to keep.

Run the commands in this guide from the root of your workspace.

How you are notified
--------------------

Canonical announces each update in the :ref:`release notes <release-notes>`
and, where applicable, in
`Ubuntu Security Notices <https://ubuntu.com/security/notices>`__.
The release notes also describe any action that you must take,
such as a configuration change.

Updates aren't automatic
------------------------

A source tag never changes, and your workspace moves to a new tag
only when you switch it.
You therefore decide when to apply an update, and you don't need
to turn off or postpone automatic source updates.

Each day that you delay an update, devices built from your workspace keep
any vulnerabilities that the update fixes.
Older updates in the |product_release| series don't receive security fixes.

Check your current update
-------------------------

Print the source tag that your workspace uses:

.. code-block:: console
   :substitutions:

   $ git -C |manifest_repository| describe --tags --exact-match

Find the latest update
----------------------

Fetch the tags from Canonical's manifest repository:

.. code-block:: console
   :substitutions:

   $ git -C |manifest_repository| fetch origin --tags

List the updates in the |product_release| series, newest first:

.. code-block:: console
   :substitutions:

   $ git -C |manifest_repository| tag --list '|product_release|.*' \
       --sort=-version:refname

If the first tag in the list differs from your current tag,
read its release notes, then apply it.

Apply the update
----------------

Move the manifest repository to the new tag,
replacing :samp:`{source-tag}` with the tag:

.. code-block:: console
   :substitutions:

   $ git -C |manifest_repository| switch --detach <source-tag>

Synchronize the other repositories with the revisions that the tag pins.
In Workshop, run the ``sync`` action:

.. code-block:: console
   :substitutions:

   $ workshop run |workshop_name| -- sync

On a host system installation, run :command:`west update` instead:

.. code-block:: console

   $ west update

Confirm that the workspace now uses the new tag:

.. code-block:: console
   :substitutions:

   $ git -C |manifest_repository| describe --tags --exact-match

Update the development tools
----------------------------

In Workshop, refresh the SDKs:

.. code-block:: console
   :substitutions:

   $ workshop refresh |workshop_name|

On a host system installation, upgrade the packages from the PPA:

.. code-block:: console

   $ sudo apt update
   $ sudo apt upgrade

Rebuild and deploy your firmware
--------------------------------

A source update fixes nothing on devices until you rebuild the firmware
and install it on them:

#. Rebuild your application with your production configuration.
#. If you use MCUboot downgrade prevention,
   increase the version in your application's :file:`VERSION` file.
#. Sign the image with your production key.
#. Deliver the image to your devices with your update mechanism,
   such as MCUmgr image upload with MCUboot.
#. Record the |product_name| source tag with the firmware release.

See also
--------

Explanation:

- :ref:`exp_security_support`

How-to guides:

- :ref:`how_harden_an_application`
- :ref:`how_report_a_vulnerability`

Reference:

- :ref:`ref_releases`
- `Security policy`_
