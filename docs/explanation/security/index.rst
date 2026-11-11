.. _exp_security:

.. meta::
   :description: Security overview of Zephyr LTS: shared responsibilities and
                 an entry point to the system overview, risks, data handling,
                 and security support.

Security overview
=================

.. toctree::
   :hidden:

   System overview <system-overview>
   Risks <risks>
   Security of data <data>
   Security support <support>

|product_name| is a source distribution of the Zephyr real-time operating
system. Device makers use it to build firmware for microcontroller-based
devices. This section explains where threats to those devices come from,
which protections Zephyr provides, which protections you must enable,
and how Canonical maintains the security of the distribution.
Canonical's threat model for |product_name| is the basis for this section.

Security is shared between Canonical and you:

* Canonical maintains the source, the development tools,
  and the security fixes for |product_name|.
* You choose the configuration, write the application, provision keys,
  and update the devices in the field.

Zephyr is highly configurable, and most of its protections are build-time
options. The security of a device built on |product_name| therefore depends
mostly on the configuration that you choose.


In this section
---------------

:ref:`exp_security_system_overview`
   The components of a device and of the supply chain, the trust boundaries
   between them, and the security controls that protect each boundary.

:ref:`exp_security_risks`
   The risks of misconfiguring Zephyr or leaving its controls off,
   and the risks that remain outside Zephyr's control.

:ref:`exp_security_data`
   Where a device stores data, how deletion works,
   and how |product_name| uses cryptography.

:ref:`exp_security_support`
   What Canonical fixes, for how long, and how fixes reach you.


Security how-to guides
----------------------

* :ref:`how_harden_an_application`
* :ref:`how_get_security_updates`
* :ref:`how_report_a_vulnerability`

.. todo::

   These security documentation topics need decisions from the product leads:

   * How to manage authentication and identity
   * How to configure logging and monitoring,
     and the risks of turning logging off
   * How to export or migrate data at rest
   * How to integrate devices securely with other products and services
   * How to decommission a device securely, including how to remove user data
   * How to reset a device or workspace to its original state
   * Whether Workshop SDKs update automatically,
     and how to postpone or turn off those updates
   * Reference: logging schema


See also
--------

Explanation:

- :ref:`exp_canonical_distribution`
- :ref:`exp_development_environments`

Reference:

- :ref:`ref_supported_boards`
- :ref:`ref_releases`
- `Security policy`_
- :zephyr-docs:`Upstream Zephyr security documentation <security/index.html>`
