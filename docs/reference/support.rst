.. _ref_support:

.. meta::
   :description: Where to report Zephyr LTS problems and the information to
                 include in a report.

Support
=======

Search this documentation before you report a problem.
When you open a report,
include enough information
for another developer to reproduce the problem.
If the problem affects security, don't report it in a public bug:
follow :ref:`how_report_a_vulnerability` instead.

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

File public source defects in the `Zephyr RTOS Launchpad bug tracker`_.


See also
--------

Explanation:

- :ref:`exp_security_support`

How-to guides:

- :ref:`how_report_a_vulnerability`

Reference:

- :ref:`ref_releases`
- `Security policy <https://github.com/canonical/zephyr-lts-docs/blob/main/SECURITY.md>`__
