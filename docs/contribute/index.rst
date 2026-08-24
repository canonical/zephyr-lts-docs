.. _contribute:

.. meta::
   :description: How to build, test, and propose changes to the Zephyr LTS
                 documentation.

Contribute
==========

Contributions can correct technical errors,
improve procedures, or add missing reference information.

Before you start,
read the `Ubuntu Code of Conduct
<https://ubuntu.com/community/docs/ethos/code-of-conduct>`_.

Get the documentation source
----------------------------

Clone the documentation repository from GitHub:

.. code-block:: console

   $ git clone https://github.com/canonical/zephyr-lts-docs.git
   $ cd zephyr-lts-docs

Build the documentation
-----------------------

Install :program:`python3-venv` on Ubuntu:

.. code-block:: console

   $ sudo apt install python3-venv

Build the HTML documentation:

.. code-block:: console

   $ make -C docs html

The build treats Sphinx warnings as errors.

Check the change
----------------

Run the documentation checks:

.. code-block:: console

   $ make -C docs spelling
   $ make -C docs linkcheck
   $ make -C docs woke
   $ make -C docs lint-md

Write tutorials as lessons that teach through a complete task.
Write how-to guides as direct procedures for one goal.
Write reference pages for lookup.
Write explanations to describe concepts and design decisions.

Use short active sentences.
Give one instruction in each sentence.
Use the same term for the same item throughout a page.

Propose the change
------------------

Push the branch to your GitHub fork.
Then, open a pull request against :samp:`canonical/zephyr-lts-docs`.

Describe the problem, the change, and the checks that you ran.
