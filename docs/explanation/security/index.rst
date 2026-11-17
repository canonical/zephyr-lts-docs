.. _exp_security:

.. meta::
   :description: Security overview of Zephyr LTS: shared responsibilities and
                 an entry point to the system overview, risks, data handling,
                 and security support.

Security overview
=================

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

These pages describe the components of a device and its supply chain,
the risks of misconfiguring Zephyr, how a device handles data,
and the security support that Canonical provides:

.. toctree::
   :titlesonly:

   System overview <system-overview>
   Risks <risks>
   Security of data <data>
   Security support <support>


Security how-to guides
----------------------

* :ref:`how_harden_an_application`
* :ref:`how_get_security_updates`
* :ref:`how_report_a_vulnerability`


See also
--------

Explanation:

- :ref:`exp_canonical_distribution`
- :ref:`exp_development_environments`

Reference:

- :ref:`ref_supported_boards`
- :ref:`ref_releases`
- :zephyr-docs:`Upstream Zephyr security documentation <security/index.html>`
