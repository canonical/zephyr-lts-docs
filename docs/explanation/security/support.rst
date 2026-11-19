.. _exp_security_support:

.. meta::
   :description: The security policy for Zephyr LTS: supported releases,
                 support periods, what Canonical fixes, how fixes reach you,
                 and how to report and disclose vulnerabilities.

Security support
================

Canonical provides security maintenance for |product_name|. This page describes
the security policy for every active release line. Specifically, What the policy
encompasses, for how long, what Canonical fixes, how fixes reach you, and how to
report a vulnerability.


Support period
--------------

Every active release line receives security fixes until its end of life. Within
a release line, only the latest update receives security fixes. For the support
level and end of life of each release line, see the :ref:`Releases
<ref_releases_support_periods>` page.

.. only:: lts

   Standard security maintenance lasts as long as the upstream Zephyr Project
   maintains the |upstream_release| LTS line, as set by the upstream
   :zephyr-docs:`release process <project/release_process.html>`.
   After that, `Extended Security Maintenance (ESM)
   <https://ubuntu.com/zephyr>`__, a Canonical product that customers can
   purchase, continues security maintenance.
   If upstream extends its maintenance of the |upstream_release| line, or a
   customer agreement includes a longer commitment, Canonical maintains the
   |product_release| release series for that longer period.

.. only:: interim

   Standard security maintenance lasts nine months. To keep receiving security
   fixes after that, please move to a newer release.

When the applicable maintenance period ends, |product_name| will no longer
receives security fixes.


What Canonical fixes
--------------------

In line with Canonical's Secure Software Development Lifecycle (SSDLC),
Canonical fixes at least the following vulnerabilities in supported releases:

* Every vulnerability rated High or Critical,
  with a CVSS 3.1 or 4.0 score of 7.0 or higher.
* Every vulnerability in the CISA
  `Known Exploited Vulnerabilities
  <https://www.cisa.gov/known-exploited-vulnerabilities-catalog>`__ catalog,
  whatever its CVSS score.

Canonical fixes lower-severity vulnerabilities on a best-effort basis, usually
as part of a routine update. All releases are validated on the :ref:`supported
platform set <ref_supported_boards>`.


How fixes reach you
-------------------

Canonical delivers security fixes as new updates of the |product_release|
release series. Each update has a new immutable source tag. You receive the
fixes when you move your workspace to the new tag and rebuild your firmware.

Canonical announces each update in:

* The :ref:`release notes <release-notes>`.
* The `Zephyr LTS release plan and activity
  <https://discourse.ubuntu.com/t/zephyr-lts-release-plan-and-activity/89358>`__
  topic on Ubuntu Discourse.
* `Ubuntu Security Notices <https://ubuntu.com/security/notices>`__,
  where applicable.

See :ref:`how_get_security_updates`.


Report a vulnerability
----------------------

If the upstream Zephyr Project still maintains the Zephyr version that your
release line is based on, report the vulnerability upstream, as described in the
upstream :zephyr-docs:`vulnerability reporting process
<security/reporting.html>`. The :ref:`Releases <ref_releases_support_periods>`
page lists the upstream end of life of each release line.

If upstream no longer maintains that version, report the vulnerability to
Canonical as a `Private Security
<https://ubuntu.com/docs/launchpad/user/explanation/privacy-confidentiality-and-disclosure/#private-security>`__
bug in the `Zephyr RTOS Launchpad bug tracker`_. Only the project's security
group can see Private Security bugs.
Include a description of the problem, the steps to reproduce it, the affected
versions, and any mitigations that you know of. You do not need a complete
analysis or a proof of concept. If you are not sure whether a problem affects
security, report it anyway.

Please do not report security problems in a public forum, such as a public
Launchpad bug or a public GitHub repository, and do not disclose them publicly
until Canonical has investigated them and coordinated a fix.

For how to collect the details of a report, see
:ref:`how_report_a_vulnerability`.


Disclosure
----------

|product_name| adopts the `Ubuntu security disclosure and embargo policy
<https://ubuntu.com/security/disclosure-policy>`__, which describes what you can
expect when you report a vulnerability and what Canonical expects from you.
Canonical follows a coordinated disclosure process: it publishes the details of
a vulnerability after a fix is available and any embargo has ended. Upstream
Zephyr embargoes last at most 90 days.


See also
--------

How-to guides:

- :ref:`how_get_security_updates`
- :ref:`how_report_a_vulnerability`

Reference:

- :ref:`ref_releases`
- :ref:`ref_supported_boards`
