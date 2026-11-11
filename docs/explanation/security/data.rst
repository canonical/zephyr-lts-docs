.. _exp_security_data:

.. meta::
   :description: Where devices built on Zephyr LTS store data, how deletion
                 works, and how Zephyr LTS uses cryptography.

Security of data
================

This page describes where a device built on |product_name| holds data,
how deleting that data works, and how |product_name| uses cryptography
to protect it.


Data collection and storage
---------------------------

Zephyr doesn't collect usage data or send data to Canonical.
Your application decides what data a device collects, stores, and sends.

Data on a device lives in three places:

* **Memory**: Thread data, network buffers, and keys in use.
  This data is lost on reset.
* **Flash**: Settings stored with the NVS or ZMS backends, file systems such as
  LittleFS and FAT, and PSA Secure Storage. This data persists across resets.
  It typically also persists across firmware updates, because MCUboot replaces
  only the image slots.
* **Outside the device**: Network and radio traffic, log output,
  coredumps, and MCUmgr responses.


Data lifecycle, deletion, and retention
---------------------------------------

Zephyr has no retention policy. Stored data stays until your application
deletes it. Deleting data doesn't always erase it: the NVS and ZMS backends
and file systems mark deleted data as free, but its contents can remain
in flash until the storage reuses that space.
To remove data permanently, erase the flash partition that holds it.


Cryptography
------------

|product_name| uses cryptography in these places:

* **PSA Crypto API**: Mbed TLS implements the standard PSA Crypto API.
  Use this API rather than custom cryptographic code.
* **Random numbers**: Entropy drivers backed by the SoC's hardware random
  number generator seed the generator that Zephyr uses for keys, nonces,
  and Bluetooth addresses.
* **Verified boot**: MCUboot verifies image signatures
  with ECDSA P-256, Ed25519, or RSA.
* **TLS and DTLS**: Mbed TLS secures network sessions
  and MCUmgr over UDP.
* **Bluetooth LE**: LE Secure Connections pairing derives link keys
  with elliptic-curve Diffie-Hellman key exchange.
* **Secure storage**: Zephyr's PSA Secure Storage implementation encrypts and
  authenticates each entry. Its protection depends on the encryption key
  provider. The default provider derives keys from the device ID,
  which isn't secret. Secure storage doesn't protect data from code running
  on the device or from an unlocked debug port.

The strength of the cryptographic primitives and of the entropy source
depends on the libraries and the hardware.


See also
--------

Explanation:

- :ref:`exp_security_risks`

How-to guides:

- :ref:`how_harden_an_application`

Reference:

- :zephyr-docs:`Upstream Zephyr secure storage documentation <services/storage/secure_storage/index.html>`
- :zephyr-docs:`Upstream Zephyr PSA Crypto documentation <services/crypto/psa_crypto.html>`
