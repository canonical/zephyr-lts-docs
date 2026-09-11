.. _ref_support:

.. meta::
   :description: Support and security reporting information for Zephyr LTS.

Support and security
====================

Search this documentation before you report a problem.
When you open a report,
include enough information
for another developer to reproduce the problem.

Technical problems
------------------

Include this information in a technical report:

* The source tag:

  .. code-block::
     :substitutions:

     $ git -C |manifest_repository| describe --tags --exact-match

* The Zephyr repository revision:

  .. code-block::
     :substitutions:

     $ git -C zephyr rev-parse HEAD

* The output of :command:`workshop info`:

  .. code-block::
     :substitutions:

     $ workshop info |workshop_name|

* The board name and board revision.
* The complete command that failed.
* The complete error output as text.
* A small application that reproduces the problem, when possible.

Use the relevant project in the `Zephyr RTOS Launchpad project`_ for public
source defects.

Security problems
-----------------

Do not report a security problem in a public bug.
Email `security@ubuntu.com <mailto:security@ubuntu.com>`__.

Include the affected revision, reproduction steps,
and known mitigations in the message.
Read the `Ubuntu security disclosure policy
<https://ubuntu.com/security/disclosure-policy>`_ for more information.


See also
--------

Reference:

- :ref:`ref_releases`
- `Security policy <https://github.com/canonical/zephyr-lts-docs/blob/main/SECURITY.md>`__
