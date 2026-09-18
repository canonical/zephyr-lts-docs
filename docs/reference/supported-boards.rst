.. _ref_supported_boards:

.. meta::
   :description: The platforms, anchor development kits, and selection
                 criteria that define hardware support for |product_name|.

Supported Boards
=================

|product_name| claims support at the level of the silicon platform, rather than
by board. A supported board is one that is built around a supported SoC. As such,
to claim support for a silicon platform Canonical targets development kits,
called *anchors*, that represent each platform to validate: the silicon, the
hardware abstraction layer, and the driver stack.

Support commitments
--------------------

A supported platform is under full Canonical maintenance and validated on
physical hardware. Support carries the following commitments:

.. csv-table::
   :header: "Property", "Commitment"
   :widths: 20, 80

   "CI coverage", "Full regression, every release."
   "Physical validation", "Each platform is validated on its anchor development kit through automated hardware-in-the-loop (HIL) testing."
   "Bug policy", "Confirmed regressions block release candidates. Bugs are triaged and assigned within 90 days in accordance with upstream's policy."

CVE response follows Canonical's existing security policy; see
:ref:`ref_support`.

Targets outside the supported set carry no CI commitment or fix obligation
from Canonical. Bug reports against them are acknowledged, and fixes are
community-driven.

Supported platform set
------------------------

Each platform below is validated on its anchor development kit through automated
hardware-in-the-loop.

.. |br| raw:: html

   <br/>

.. csv-table::
   :header: "Platform (SoC)", "Anchor kit", "ISA", "Role"
   :widths: 15, 20, 16, 34

   "nRF52840", "``nrf52840dk/nrf52840``", "Cortex-M4F", "Wireless anchor |br| (BLE/Thread/802.15.4)"
   "STM32H753ZI", "``nucleo_h753zi``", "Cortex-M7", "Industrial/wired anchor |br| (Ethernet, CAN-FD, crypto)"
   "RW612", "``frdm_rw612``", "Cortex-M33", "NXP tri-radio anchor |br| (Wi-Fi 6/BLE/802.15.4)"
   "RA8M1", "``ek_ra8m1``", "Cortex-M85", "Renesas partner anchor |br| (Ethernet, CAN-FD)"
   "ESP32-C3", "``esp32c3_devkitm``", "RISC-V", "RISC-V anchor |br| (ISA constraint)"
   "ESP32-S3", "``esp32s3_devkitc``", "Xtensa", "Xtensa anchor |br| (ISA constraint)"

Each platform and anchor in this set is supported and tested with real hardware
with |product_name| in addition to testing done by upstream. All other supported
targets in Zephyr |upstream_release| are not validated with real hardware by
Canonical.

Emulation and validation resilience
-----------------------------------

Mature emulation is not a condition of support and does not affect platform
selection. Where available, QEMU or Renode models act as a continuity hedge
against the longevity risk inherent in a decade-long support horizon: if a
supported platform's silicon is discontinued before end-of-support, a mature
emulation model lets regression testing continue after the anchor
development kit can no longer be procured. Emulation supplements, but never
replaces, the mandatory HIL validation that defines support.

No emulation path validates Wi-Fi radio behavior. Wi-Fi validation for the
supported wireless platforms (RW612, ESP32-C3, ESP32-S3) depends entirely on
HIL. This concentrates a specific longevity risk on the RW612: it is the
only non-Espressif and only Wi-Fi 6 platform in the set, so its
discontinuation would remove that coverage with no fallback validation path.

Cohort reviews
----------------

The supported platform set evolves through cohort cycles rather than
remaining fixed. Reviews are held on the Ubuntu release cadence, every April
and October. Each review may promote, demote, or remove a platform based on
the criteria above. Modifying the supported set requires engineering team
consensus, with the team lead holding final decision authority.

See also
--------

Explanation:

- :ref:`exp_canonical_distribution`

Reference:

- :ref:`ref_releases`
- :ref:`ref_support`
- :zephyr-docs:`Upstream Supported Boards <boards/index.html>`
