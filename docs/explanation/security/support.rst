.. _exp_security_support:

.. meta::
   :description: The security maintenance that Canonical provides for Zephyr
                 LTS: what it fixes, for how long, and how fixes reach you.

Security support
================

Canonical provides security maintenance for |product_name|
as described in the `Security policy`_.

What Canonical fixes
   At minimum, every vulnerability with a CVSS 3.1 or 4.0 score of 7.0 or
   higher, and every vulnerability in the CISA
   `Known Exploited Vulnerabilities
   <https://www.cisa.gov/known-exploited-vulnerabilities-catalog>`__ catalog.
   Canonical fixes lower-severity vulnerabilities on a best-effort basis.

Which releases
   Only the latest update of the |product_release| release series.
   Canonical validates releases on the :ref:`supported platform set
   <ref_supported_boards>`. Other targets carry no CI commitment or
   fix obligation.

For how long
   Standard security maintenance lasts as long as the upstream Zephyr Project
   maintains the |upstream_release| LTS line, approximately 2.5 years.
   Extended Security Maintenance (ESM), a Canonical product that customers can
   purchase, continues security maintenance after that.
   When the applicable maintenance period ends,
   |product_name| no longer receives security fixes.

How fixes reach you
   As new source tags announced in the :ref:`release notes <release-notes>`
   and, where applicable,
   `Ubuntu Security Notices <https://ubuntu.com/security/notices>`__.
   See :ref:`how_get_security_updates`.

How to report a vulnerability
   Privately, by email. See :ref:`how_report_a_vulnerability`.

.. todo::

   Add the end dates for standard security maintenance and ESM,
   and a link where customers can purchase ESM.
   The security policy names this page as the published source
   for these dates.


See also
--------

How-to guides:

- :ref:`how_get_security_updates`
- :ref:`how_report_a_vulnerability`

Reference:

- :ref:`ref_releases`
- :ref:`ref_supported_boards`
- `Security policy`_
