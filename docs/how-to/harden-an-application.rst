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
uses. Skip the sections for features that your firmware does not include.

Prerequisites
-------------

Before starting, ensure you have these requirements satisfied:

* A launched |workshop_name_samp| Workshop.
  On a host system installation, run the same :command:`west` commands
  directly.
* An application that builds for a supported board.
* The documentation for your SoC, for the debug port and DMA steps.

The Workshop ``build`` action runs :command:`west build` in
:file:`/project/zephyr`. Thus, application paths in this guide are relative
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
Some recommendations do not apply to every platform.
Record the reason for each flagged option that you keep.

The hardening tool also flags ``CONFIG_TEST_RANDOM_GENERATOR``. This option
allows a non-random number generator, so keys and nonces generated with it are
predictable. Ensure that this is never shipped.

Enable memory protection
------------------------

Which memory protection you can enable depends on your board. User mode and
hardware stack protection need memory protection hardware on your SoC, such as a
memory protection unit (MPU), a memory management unit (MMU), or RISC-V Physical
Memory Protection (PMP). Zephyr's support for your SoC must also enable that
hardware. In lieu of memory protection hardware, you can still employ
software-based solutions such as stack canaries and a stack sentinel. There are
software checks and work on every board.

Check what your board supports
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The first task is to check what your board supports so that you know your
options. Build your application, then start a Workshop shell and search the
build configuration:

.. code-block:: console
   :substitutions:

   $ workshop shell |workshop_name|
   |workshop_project_prompt| cd zephyr
   |workshop_zephyr_prompt| grep -E \
       'ARCH_HAS_USERSPACE|ARCH_HAS_STACK_PROTECTION|CPU_HAS_MPU|CPU_HAS_MMU' \
       build/zephyr/.config

With sysbuild, the file is :file:`build/<name>/zephyr/.config`,
where ``<name>`` is the name of your application directory.

Each line that the command prints tells you what your board supports:

.. list-table::
   :header-rows: 1
   :widths: 45 55

   * - Line
     - Meaning
   * - ``CONFIG_ARCH_HAS_USERSPACE=y``
     - Your board supports user mode.
   * - ``CONFIG_ARCH_HAS_STACK_PROTECTION=y``
     - Your board supports hardware stack protection.
   * - ``CONFIG_CPU_HAS_MPU=y``
     - Zephyr uses an MPU or RISC-V PMP on your SoC.
   * - ``CONFIG_CPU_HAS_MMU=y``
     - Zephyr uses an MMU on your SoC.

If a line is missing, your board does not support that feature.
Some Arm Cortex-M cores without an MPU support hardware stack protection
but not user mode.

To see why an option is not available, open the configuration menu
in the same shell:

.. code-block:: console
   :substitutions:

   |workshop_zephyr_prompt| west build -t menuconfig

Press :kbd:`/`, search for ``USERSPACE`` or ``HW_STACK_PROTECTION``,
and select the option. Then press :kbd:`?` to list the option's dependencies
and their current values.

The build configuration shows only the memory protection hardware
that Zephyr enables on your SoC.
If none of these lines appear, either the SoC has no memory protection hardware,
or Zephyr does not support it on that SoC.
Your SoC's reference manual tells you whether the hardware exists.
In both cases, treat the board as one without user mode.
Do not enable a memory protection driver yourself,
such as ``CONFIG_RISCV_PMP``, on an SoC where Zephyr does not enable it.

Enable user mode
~~~~~~~~~~~~~~~~

If your board supports user mode, enable it together with hardware stack
protection and stack canaries in :file:`production.conf`:

.. code-block:: text
   :caption: production.conf

   CONFIG_USERSPACE=y
   CONFIG_HW_STACK_PROTECTION=y
   CONFIG_STACK_CANARIES=y

Build your application again with :file:`production.conf`, and check that
:file:`build/zephyr/.config` contains ``CONFIG_USERSPACE=y``.
If the line is missing, the build prints a warning that ``USERSPACE``
did not get the value ``y``, followed by the dependencies that are not met.

To confirm that user mode works on the hardware,
build and flash the upstream user-mode Hello World sample:

.. code-block:: console
   :substitutions:

   $ workshop run |workshop_name| -- build -p always -b <board> \
       samples/userspace/hello_world_user
   $ workshop run |workshop_name| -- flash

The serial console prints this line, where ``<board>`` is your board:

.. code-block:: text

   Hello World from UserSpace! (<board>)

If the line says ``privileged mode`` instead, user mode is not active.

User mode only protects threads that run in it.
Create application threads with the ``K_USER`` option,
grant each thread only the kernel objects and memory partitions it needs,
and keep the number of kernel-mode threads to a minimum.
For details, see the upstream
:zephyr-docs:`user mode documentation <kernel/usermode/index.html>`.

Enable stack checks without user mode
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If your board supports hardware stack protection but not user mode,
enable hardware stack protection and stack canaries:

.. code-block:: text
   :caption: production.conf

   CONFIG_HW_STACK_PROTECTION=y
   CONFIG_STACK_CANARIES=y

If your board supports neither, enable the software stack checks:

.. code-block:: text
   :caption: production.conf

   CONFIG_STACK_CANARIES=y
   CONFIG_STACK_SENTINEL=y

The stack sentinel is a known value that Zephyr writes at the lowest address
of each thread's stack, where an overflow reaches first.
Zephyr checks the value when it switches threads
and when an interrupt returns, and stops the thread if the value has changed.
The sentinel detects an overflow only after it has happened,
and it misses an overflow that skips past the value without changing it,
so it does not replace hardware stack protection.

Without user mode, every thread runs with kernel privilege,
so do not run untrusted code, including loadable extensions.

Zephyr does not allow the stack sentinel together with user mode,
or with hardware stack protection that uses the MPU.
If the hardening tool flags ``CONFIG_STACK_SENTINEL`` on such a build,
record that hardware stack protection replaces it.

Sign firmware with your own key
-------------------------------

MCUboot verifies each firmware image's signature before it runs.
Signing firmware is optional, but we recommend it. Without signature
verification, anyone who can write to the device's flash, for example through
MCUmgr, USB, or a debug probe, can run firmware of their choice.

If you enable MCUboot without setting a signing key, the build signs images
with a sample key from the MCUboot repository. That key is public, so anyone
can sign firmware that your devices accept.

From the root of your workspace, generate an ECDSA P-256 signing key
with MCUboot's :command:`imgtool`:

.. code-block:: console

   $ python3 bootloader/mcuboot/scripts/imgtool.py keygen \
       -k /path/to/signing-key.pem -t ecdsa-p256

Store the private key outside your application repository and restrict access to
it. Anyone who has the key can sign firmware for your devices.

Create :file:`sysbuild.conf` in your application directory
to build MCUboot with your key:

.. code-block:: text
   :caption: sysbuild.conf

   SB_CONFIG_BOOTLOADER_MCUBOOT=y
   SB_CONFIG_BOOT_SIGNATURE_TYPE_ECDSA_P256=y
   SB_CONFIG_BOOT_SIGNATURE_KEY_FILE="/path/to/signing-key.pem"

To stop attackers from reinstalling older, vulnerable firmware, enable downgrade
prevention in MCUboot. Create :file:`sysbuild/mcuboot.conf` in your application
directory:

.. code-block:: text
   :caption: sysbuild/mcuboot.conf

   CONFIG_MCUBOOT_DOWNGRADE_PREVENTION=y

With downgrade prevention, MCUboot accepts an update only if its version is
higher than the running version. The build takes the image version from the
:file:`VERSION` file in your application directory, so increase it for every
release.

If your application already has a :file:`sysbuild` directory:

* Keep :file:`sysbuild.conf` in your application directory,
  not in :file:`sysbuild`. Sysbuild does not look for it there.
* Add the downgrade prevention line to :file:`sysbuild/mcuboot.conf`,
  even if your application also has a :file:`sysbuild/mcuboot` directory.
  Sysbuild uses that directory instead of MCUboot's default configuration,
  and still applies :file:`sysbuild/mcuboot.conf` on top of it.
* Set the signing key only in :file:`sysbuild.conf`. Sysbuild replaces any
  ``CONFIG_BOOT_SIGNATURE_KEY_FILE`` in MCUboot's configuration files with
  the value of ``SB_CONFIG_BOOT_SIGNATURE_KEY_FILE``,
  which defaults to the public sample key.

Build with sysbuild:

.. code-block:: console
   :substitutions:

   $ workshop run |workshop_name| -- build -p always --sysbuild \
       -b <board> <application> -- -DEXTRA_CONF_FILE=production.conf

Check that MCUboot uses your key and downgrade prevention.
The MCUboot configuration in :file:`build/mcuboot/zephyr/.config`
must contain these lines:

.. code-block:: text
   :caption: build/mcuboot/zephyr/.config

   CONFIG_BOOT_SIGNATURE_KEY_FILE="/path/to/signing-key.pem"
   CONFIG_MCUBOOT_DOWNGRADE_PREVENTION=y

If downgrade prevention is missing, check whether your build passes
``-Dmcuboot_EXTRA_CONF_FILE`` or ``-Dmcuboot_CONF_FILE``.
Either option makes sysbuild ignore :file:`sysbuild/mcuboot.conf`.

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

With DTLS enabled, the UDP transport does not start at boot.
Your application adds the credentials,
then opens the transport with ``smp_udp_open()``.

Anyone with physical access to a UART can use the UART transport.
Do not include it in production firmware unless the port is physically secured.

Turn off the command groups that your product does not need:

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
The default provider derives keys from the device ID, which is not secret.
Implement a key provider backed by a device-unique hardware key
through ``CONFIG_SECURE_STORAGE_ITS_TRANSFORM_AEAD_KEY_PROVIDER``.

Secure storage does not protect data from code running on the device
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
and use resolvable private addresses so that observers cannot track the device:

.. code-block:: text
   :caption: production.conf

   CONFIG_BT_SMP_SC_ONLY=y
   CONFIG_BT_PRIVACY=y

Do not enable fixed passkeys or debug keys in production.
The hardening tool flags ``CONFIG_BT_FIXED_PASSKEY``
and ``CONFIG_BT_USE_DEBUG_KEYS``.

Load extensions safely
----------------------

LLEXT loads and links code at run time and does not verify it.
If your application uses loadable extensions:

* Load extensions only from storage that an attacker cannot write to.
* Verify each extension's signature in your application,
  for example with the PSA Crypto API, before you call ``llext_load()``.
* If your board supports user mode, add the extension to a user-mode memory
  domain with ``llext_add_domain()`` and call it only from user-mode threads.

See the upstream :zephyr-docs:`LLEXT documentation <services/llext/index.html>`.

Plan for denial of service
--------------------------

Zephyr cannot prevent floods of network or radio traffic.
Size buffer pools and connection limits for the load that you expect,
for example with ``CONFIG_NET_PKT_RX_COUNT``, ``CONFIG_NET_BUF_RX_COUNT``,
``CONFIG_NET_MAX_CONN``, and ``CONFIG_BT_MAX_CONN``.

Enable a hardware
:zephyr-docs:`watchdog <hardware/peripherals/watchdog.html>`
so that the device recovers if a flood or a fault stalls it.

Track vendor binaries
---------------------

Some boards, such as the RW612, ESP32-C3, and ESP32-S3, use closed-source vendor
binaries. In these cases as part of the radio stack. You should ensure that each
binary blob is checked against the SHA-256 checksum that the pins the blob. Use
:command:`west blobs` to fetch the blob and check the blob against the SHA-256
checksum that the module pins. In a Workshop shell, run the command for your
platform's module:

.. code-block:: console
   :substitutions:

   |workshop_project_prompt| west blobs fetch hal_nxp
   |workshop_project_prompt| west blobs fetch hal_espressif

Canonical cannot patch these binaries. Follow the vendor's security advisories
for your SoC.

Pre-deployment checklist
------------------------

Before you ship firmware, confirm that:

* The hardening tool reports no failures that you have not reviewed.
* ``CONFIG_TEST_RANDOM_GENERATOR`` is not set.
* Stack protection is enabled. If your board supports user mode, user mode is
  enabled and application threads run in user mode.
* If you sign firmware, MCUboot uses your own signing key,
  downgrade prevention is enabled, and the private signing key is stored
  outside the repository, with restricted access.
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
