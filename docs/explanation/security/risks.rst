.. _exp_security_risks:

.. meta::
   :description: The inherent risks of devices built on Zephyr LTS:
                 misconfiguration, input validation, denial of service, access
                 control, data handling, tampering, and non-repudiation.

Risks
=====

The threat model rates some risks as *inherent*: Zephyr can't remove them
because they follow from how you configure and use it.
This page describes them.


Misconfiguring or disabling security controls
---------------------------------------------

Zephyr samples and board configurations are set up for development.
They often enable the shell, logging, and debug features, and leave user mode
and stack protection off. When a product configuration copies these settings,
the :ref:`security controls <exp_security_controls>` that depend on your
configuration never take effect.
The threat model rates copied insecure defaults among the highest risks
for |product_name|. For example:

* Without user mode, every thread runs in kernel mode, so a memory-safety bug
  in any thread can compromise the whole device.
* If you enable MCUboot without setting your own signing key,
  the build signs firmware with a sample key from the MCUboot repository.
  That key is public, so anyone can create firmware that your devices accept.
* ``CONFIG_TEST_RANDOM_GENERATOR`` allows a non-random generator,
  which makes keys and nonces predictable.
* An unlocked debug port lets anyone with physical access
  read keys and replace firmware.

Run the hardening tool on every production build,
as described in :ref:`how_harden_an_application`.


Input validation
----------------

Data from the network, radios, USB, and flash can be controlled by an attacker.
Zephyr's stacks validate the protocol data that they parse,
but your application parses its own payloads.
A missing length or bounds check in application code can let crafted input
corrupt memory and run the attacker's code.
The network and Bluetooth stacks parse the most attacker-controlled input,
so keep your workspace on the latest update to receive their fixes.


Denial of service
-----------------

Connected devices receive traffic that they didn't ask for.
Fixed-size buffer pools and connection limits keep a flood from exhausting
memory, but the flood can still fill the pools and block legitimate traffic
while it lasts. Zephyr can't prevent volumetric attacks.
Size the pools and limits for your expected load,
and use a watchdog to recover a stalled device.


Access control
--------------

MCUmgr and the shell can upload firmware, reset the device,
and read or write files and settings.
Neither authenticates clients by itself: MCUmgr relies on its transport,
and the shell trusts anyone with access to the console.
If you expose them without authentication,
anyone who can reach them can control the device.
Inside the firmware, threads have no access control between them
unless you enable :ref:`user mode <exp_security_user_mode>`.


Handling data incorrectly
-------------------------

TLS private keys, Bluetooth bonding keys, and Thread network keys
are valuable targets. If you store them as plaintext settings or files,
anyone who can dump flash, or who can send MCUmgr settings or file commands,
can read them. Log messages and coredumps can also expose secrets from memory.
Stable Bluetooth addresses and hardware identifiers
let observers track a device and its user.


Tampering
---------

Without verified boot, anyone who can write to flash,
for example through MCUmgr, USB, or a debug probe,
can install firmware of their choice, and it persists across reboots.
Without downgrade prevention, an attacker can reinstall an older,
vulnerable version.

Software can't fully stop physical attacks.
Fault injection, such as voltage or clock glitching, can skip signature checks,
and side-channel analysis can extract keys.
Protection against these attacks depends on the SoC.

Zephyr doesn't detect tampering by itself.
To notice a malicious actor, your application must log security-relevant
events and you must monitor them.


Non-repudiation
---------------

Zephyr doesn't keep an audit trail.
Without one, you can't tell which client made a change through MCUmgr
or the shell. MCUmgr's notification hooks let your application check and record
each command.

To show which source a firmware release was built from,
record the |product_name| source tag with each release.


Risks outside Zephyr's control
------------------------------

* **Vendor binaries**: On RW612, ESP32-C3, and ESP32-S3, the radio stacks
  include closed-source code from NXP and Espressif.
  Canonical can't audit, test, or patch this code, and fixes depend on the
  vendor. Follow the vendors' security advisories as well as Canonical's.
* **Hardware**: Resistance to side-channel and fault-injection attacks, debug
  port locking, and DMA isolation depend on the SoC and its configuration.


See also
--------

Explanation:

- :ref:`exp_security_system_overview`
- :ref:`exp_security_data`

How-to guides:

- :ref:`how_harden_an_application`
- :ref:`how_get_security_updates`
