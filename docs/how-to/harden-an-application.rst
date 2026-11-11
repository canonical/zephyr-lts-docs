.. _how_harden_an_application:

.. meta::
   :description: Harden a Zephyr LTS application before you ship it: run the
                 hardening tool, enable memory protection, sign firmware, and
                 lock down management, storage, and diagnostics.

How to harden an application for production
===========================================

Zephyr samples and board configurations are set up for development.
Before you ship firmware built on |product_name|,
apply the protections in this guide.
:ref:`Risks <exp_security_risks>` explains the risk
that each protection addresses.

Some steps depend on your hardware and on the features that your application
uses. Skip the sections for features that your firmware doesn't include.

Prerequisites
-------------

Before starting, ensure you have these requirements satisfied:

* A launched |workshop_name_samp| Workshop.
  On a host system installation, run the same :command:`west` commands
  directly.
* An application that builds for a board in the
  :ref:`supported platform set <ref_supported_boards>`.
* The documentation for your SoC, for the debug port and DMA steps.

The Workshop ``build`` action runs :command:`west build` in
:file:`/project/zephyr`, so application paths in this guide are relative
to that directory.

Check the configuration with the hardening tool
-----------------------------------------------

Zephyr's :zephyr-docs:`hardening tool <security/hardening-tool.html>`
compares a build's Kconfig options
with the recommendations of the Zephyr Security Working Group.

Build your application, replacing :samp:`{board}` and :samp:`{application}`:

.. code-block:: console
   :substitutions:

   $ workshop run |workshop_name| -- build -p always -b <board> <application>

Run the hardening tool against the build:

.. code-block:: console
   :substitutions:

   $ workshop run |workshop_name| -- build -t hardenconfig

The tool prints a table of options whose current value
differs from the recommended value.

Keep production settings in a separate configuration file,
so that development builds keep their debugging features.
Create :file:`production.conf` in your application directory,
add the recommended values to it,
and pass the file to production builds:

.. code-block:: console
   :substitutions:

   $ workshop run |workshop_name| -- build -p always -b <board> <application> \
       -- -DEXTRA_CONF_FILE=production.conf

Run the hardening tool again and review each remaining failure.
Some recommendations don't apply to every platform.
Record the reason for each flagged option that you keep.

The hardening tool also flags ``CONFIG_TEST_RANDOM_GENERATOR``.
This option allows a non-random number generator, so keys and nonces
generated with it are predictable. Never ship it.

Enable memory protection
------------------------

On nRF52840, STM32H753ZI, RW612, and RA8M1,
enable user mode and stack protection in :file:`production.conf`:

.. code-block:: text
   :caption: production.conf

   CONFIG_USERSPACE=y
   CONFIG_HW_STACK_PROTECTION=y
   CONFIG_STACK_CANARIES=y
   CONFIG_STACK_SENTINEL=y

User mode only protects threads that run in it.
Create application threads with the ``K_USER`` option,
grant each thread only the kernel objects and memory partitions it needs,
and keep the number of kernel-mode threads to a minimum.
For details, see the upstream
:zephyr-docs:`user mode documentation <kernel/usermode/index.html>`.

ESP32-C3 and ESP32-S3 don't support user mode in Zephyr.
Every thread runs with kernel privilege,
so don't run untrusted code, including loadable extensions,
on these platforms.

Sign firmware with your own key
-------------------------------

MCUboot verifies each firmware image's signature before it runs.
If you enable MCUboot without setting a signing key,
the build signs images with a sample key from the MCUboot repository.
That key is public, so anyone can sign firmware that your devices accept.

From the root of your workspace, generate an ECDSA P-256 signing key
with MCUboot's :command:`imgtool`:

.. code-block:: console

   $ python3 bootloader/mcuboot/scripts/imgtool.py keygen \
       -k /path/to/signing-key.pem -t ecdsa-p256

Store the private key outside your application repository
and restrict access to it.
Anyone who has the key can sign firmware for your devices.

Create :file:`sysbuild.conf` in your application directory
to build MCUboot with your key:

.. code-block:: text
   :caption: sysbuild.conf

   SB_CONFIG_BOOTLOADER_MCUBOOT=y
   SB_CONFIG_BOOT_SIGNATURE_TYPE_ECDSA_P256=y
   SB_CONFIG_BOOT_SIGNATURE_KEY_FILE="/path/to/signing-key.pem"

To stop attackers from reinstalling older, vulnerable firmware,
enable downgrade prevention in MCUboot. Create :file:`sysbuild/mcuboot.conf`
in your application directory:

.. code-block:: text
   :caption: sysbuild/mcuboot.conf

   CONFIG_MCUBOOT_DOWNGRADE_PREVENTION=y

With downgrade prevention, MCUboot accepts an update only if its version is
higher than the running version. The build takes the image version from the
:file:`VERSION` file in your application directory,
so increase it for every release.

Build with sysbuild:

.. code-block:: console
   :substitutions:

   $ workshop run |workshop_name| -- build -p always --sysbuild \
       -b <board> <application> -- -DEXTRA_CONF_FILE=production.conf

For more options, such as image encryption, see the upstream
:zephyr-docs:`sysbuild <build/sysbuild/index.html>`
and :zephyr-docs:`device firmware upgrade <services/device_mgmt/dfu.html>`
documentation.

Lock the debug port and restrict DMA
------------------------------------

An unlocked SWD or JTAG port lets anyone with physical access read memory,
including keys, and take control of the CPU.
Before you ship a device, lock or turn off the debug port
with your SoC's access port protection or readout protection mechanism.
Some of these mechanisms are permanent,
so test the procedure on a development board first.

DMA controllers move data without passing through the MPU.
Restrict DMA-capable peripherals to dedicated buffers,
validate DMA descriptors and lengths,
and use your SoC's bus firewall where it has one.

These steps are specific to each SoC. Follow your SoC vendor's documentation.

Secure device management
------------------------

MCUmgr can upload firmware, reset the device, and read files and settings.
It has no authentication of its own and relies on its transport.

Over Bluetooth LE, require an encrypted and authenticated link:

.. code-block:: text
   :caption: production.conf

   CONFIG_MCUMGR_TRANSPORT_BT_PERM_RW_AUTHEN=y

Over UDP, enable DTLS:

.. code-block:: text
   :caption: production.conf

   CONFIG_MCUMGR_TRANSPORT_UDP_DTLS=y

With DTLS enabled, the UDP transport doesn't start at boot.
Your application adds the credentials,
then opens the transport with ``smp_udp_open()``.

Anyone with physical access to a UART can use the UART transport.
Don't include it in production firmware unless the port is physically secured.

Turn off the command groups that your product doesn't need:

.. code-block:: text
   :caption: production.conf

   CONFIG_MCUMGR_GRP_FS=n
   CONFIG_MCUMGR_GRP_SHELL=n
   CONFIG_MCUMGR_GRP_SETTINGS=n

To check or record each command, enable
``CONFIG_MCUMGR_MGMT_NOTIFICATION_HOOKS`` and register a callback.
A record of commands lets you tell who changed a device.
See the upstream :zephyr-docs:`MCUmgr documentation
<services/device_mgmt/mcumgr.html>`.

Restrict the shell, logging, and coredumps
------------------------------------------

The shell, log output, and coredumps can expose secrets and kernel state,
and an open shell gives anyone with console access control of the device.
Turn them off in production:

.. code-block:: text
   :caption: production.conf

   CONFIG_SHELL=n
   CONFIG_LOG=n
   CONFIG_DEBUG_COREDUMP=n

If your product needs a shell, require a login before any other command.
The upstream
:upstream-zephyr-branch:`shell module sample <samples/subsys/shell/shell_module>`
shows a login configuration in :file:`prj_login.conf`.
It limits the shell to a login command with ``CONFIG_SHELL_CMD_ROOT``
and hides typed characters with ``CONFIG_SHELL_START_OBSCURED``.

If your product needs logging, never log keys, credentials, or personal data.

Protect secrets at rest
-----------------------

Store keys and credentials through the PSA Crypto and PSA Secure Storage APIs,
not as plaintext settings or files.
Enable Zephyr's
:zephyr-docs:`secure storage <services/storage/secure_storage/index.html>`
implementation of these APIs:

.. code-block:: text
   :caption: production.conf

   CONFIG_SECURE_STORAGE=y

Secure storage encrypts and authenticates each entry,
but its protection depends on the encryption key provider.
The default provider derives keys from the device ID, which isn't secret.
Implement a key provider backed by a device-unique hardware key
through ``CONFIG_SECURE_STORAGE_ITS_TRANSFORM_AEAD_KEY_PROVIDER``.

Secure storage doesn't protect data from code running on the device
or from an unlocked debug port. Lock the debug port as well.

Require TLS peer verification
-----------------------------

For each TLS or DTLS socket, require peer verification
and set the host name that the certificate must match:

.. code-block:: c

   static const char hostname[] = "updates.example.com";
   int verify = ZSOCK_TLS_PEER_VERIFY_REQUIRED;

   zsock_setsockopt(sock, ZSOCK_SOL_TLS, ZSOCK_TLS_PEER_VERIFY,
                    &verify, sizeof(verify));
   zsock_setsockopt(sock, ZSOCK_SOL_TLS, ZSOCK_TLS_HOSTNAME,
                    hostname, sizeof(hostname));

Provision the CA certificates that the device trusts
with the TLS credentials API.
Give the device a trustworthy time source, such as SNTP or a real-time clock,
so that it can reject expired certificates.
See the upstream
:zephyr-docs:`sockets documentation <connectivity/networking/api/sockets.html>`.

Secure Bluetooth LE
-------------------

Allow only LE Secure Connections pairing,
and use resolvable private addresses so that observers can't track the device:

.. code-block:: text
   :caption: production.conf

   CONFIG_BT_SMP_SC_ONLY=y
   CONFIG_BT_PRIVACY=y

Don't enable fixed passkeys or debug keys in production.
The hardening tool flags ``CONFIG_BT_FIXED_PASSKEY``
and ``CONFIG_BT_USE_DEBUG_KEYS``.

Load extensions safely
----------------------

LLEXT loads and links code at run time and doesn't verify it.
If your application uses loadable extensions:

* Load extensions only from storage that an attacker can't write to.
* Verify each extension's signature in your application,
  for example with the PSA Crypto API, before you call ``llext_load()``.
* On MPU platforms, add the extension to a user-mode memory domain with
  ``llext_add_domain()`` and call it only from user-mode threads.

See the upstream :zephyr-docs:`LLEXT documentation <services/llext/index.html>`.

Plan for denial of service
--------------------------

Zephyr can't prevent floods of network or radio traffic.
Size buffer pools and connection limits for the load that you expect,
for example with ``CONFIG_NET_PKT_RX_COUNT``, ``CONFIG_NET_BUF_RX_COUNT``,
``CONFIG_NET_MAX_CONN``, and ``CONFIG_BT_MAX_CONN``.

Enable a hardware
:zephyr-docs:`watchdog <hardware/peripherals/watchdog.html>`
so that the device recovers if a flood or a fault stalls it.

Track vendor binaries
---------------------

On RW612, ESP32-C3, and ESP32-S3, the radio stacks include closed-source
vendor binaries. Fetch them with :command:`west blobs`, which checks each binary
against the SHA-256 checksum that the module pins.
In a Workshop shell, run the command for your platform's module:

.. code-block:: console
   :substitutions:

   |workshop_project_prompt| west blobs fetch hal_nxp
   |workshop_project_prompt| west blobs fetch hal_espressif

Canonical can't patch these binaries.
Follow the NXP and Espressif security advisories for your SoC.

Pre-deployment checklist
------------------------

Before you ship firmware, confirm that:

* The hardening tool reports no failures that you haven't reviewed.
* ``CONFIG_TEST_RANDOM_GENERATOR`` is not set.
* On MPU platforms, user mode and stack protection are enabled,
  and application threads run in user mode.
* MCUboot uses your own signing key, and downgrade prevention is enabled.
* The private signing key is stored outside the repository,
  with restricted access.
* The debug port is locked on production devices.
* MCUmgr runs only over authenticated transports,
  with unneeded command groups turned off.
* The shell, logging, and coredumps are turned off or restricted.
* Secrets are stored in secure storage with a hardware-backed key provider.
* Every TLS socket requires peer verification and checks the host name.
* Bluetooth LE allows only Secure Connections and uses privacy.
* Loadable extensions are verified before they load.
* Buffer pools and connection limits are sized, and a watchdog is enabled.
* The firmware is built from the latest |product_release| source tag,
  and the tag is recorded with the release.

See also
--------

Explanation:

- :ref:`exp_security_system_overview`
- :ref:`exp_security_risks`

How-to guides:

- :ref:`how_get_security_updates`

Reference:

- :ref:`ref_supported_boards`
- :zephyr-docs:`Upstream Zephyr secure coding guidelines <security/secure-coding.html>`
