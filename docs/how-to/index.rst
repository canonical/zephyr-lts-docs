.. _how-to-guides:

.. meta::
   :description: Procedures for development environment setup, hardware access,
                 and application security.

How-to guides
=============

These articles cover specific tasks
that arise when you develop applications with |product_name|.


Set up a development environment
--------------------------------

Workshop is the standard development path.
For hosts where Workshop is unavailable, use the host system installation guide.

.. toctree::
   :titlesonly:

   install-on-host-system

The PPA publishes pinned packages that the Workshop does not install.
Add them to a Workshop with the Canonical version preference:

.. toctree::
   :titlesonly:

   How to install PPA dependencies in Workshop <install-ppa-dependencies>

Develop in VS Code
------------------

The Workshop extension for VS Code connects the editor
to a running Workshop environment:

.. toctree::
   :titlesonly:

   How to use Workshop from VS Code <use-workshop-from-vscode>


Choose SDK versions
--------------------

Each SDK entry in a Workshop definition pins one channel.
Find other versions and channels an SDK publishes:

.. toctree::
   :titlesonly:

   How to find other SDK versions <find-sdk-versions>


Work with hardware
------------------

Workshop keeps access to host devices disconnected by default.
Connect the interface when you need to flash a physical board:

.. toctree::
   :titlesonly:

   How to access hardware from Workshop <access-hardware-from-workshop>


Install vendor flash tools
---------------------------

Some runners depend on vendor tools that are not part of the SDK
or the Ubuntu archive. Package them in an in-project SDK:

.. toctree::
   :titlesonly:

   How to add vendor tools to Workshop <adding-vendor-tools-to-workshop>


Security
--------

Harden firmware before you ship it, keep it up to date,
and report vulnerabilities privately:

.. toctree::
   :titlesonly:

   How to harden an application for production <harden-an-application>
   How to get security updates <get-security-updates>
   How to report a security vulnerability <report-a-vulnerability>
