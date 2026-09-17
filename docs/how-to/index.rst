.. _how-to-guides:

.. meta::
   :description: Procedures for manual Zephyr setup and hardware access.

How-to guides
=============

These articles cover specific tasks
that arise when you develop applications with |product_name|.


Set up a development environment
--------------------------------

Workshop is the standard development path.
For hosts where Workshop is unavailable, use the manual installation guide.

.. toctree::
   :titlesonly:

   install-manually

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
