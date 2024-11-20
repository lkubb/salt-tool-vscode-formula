.. _readme:

Visual Studio Code Formula
==========================

Manages Visual Studio Code in the user environment.

.. contents:: **Table of Contents**
   :depth: 1

Usage
-----
Applying ``tool_vscode`` will make sure ``vscode`` is configured as specified.

Execution and state module
~~~~~~~~~~~~~~~~~~~~~~~~~~
This formula provides a custom execution module and state to manage extensions installed with Visual Studio Code. The functions are self-explanatory, please see the source code or the rendered docs at :ref:`em_vscode` and :ref:`sm_vscode`.

Configuration
-------------

This formula
~~~~~~~~~~~~
The general configuration structure is in line with all other formulae from the `tool` suite, for details see :ref:`toolsuite`. An example pillar is provided, see :ref:`pillar.example`. Note that you do not need to specify everything by pillar. Often, it's much easier and less resource-heavy to use the ``parameters/<grain>/<value>.yaml`` files for non-sensitive settings. The underlying logic is explained in :ref:`map.jinja`.

User-specific
^^^^^^^^^^^^^
The following shows an example of ``tool_vscode`` per-user configuration. If provided by pillar, namespace it to ``tool_global:users`` and/or ``tool_vscode:users``. For the ``parameters`` YAML file variant, it needs to be nested under a ``values`` parent key. The YAML files are expected to be found in

1. ``salt://tool_vscode/parameters/<grain>/<value>.yaml`` or
2. ``salt://tool_global/parameters/<grain>/<value>.yaml``.

.. code-block:: yaml

  user:

      # Force the usage of XDG directories for this user.
    xdg: true

      # Sync this user's config from a dotfiles repo.
      # The available paths and their priority can be found in the
      # rendered `config/sync.sls` file (currently, @TODO docs).
      # Overview in descending priority:
      # salt://dotconfig/<minion_id>/<user>/Code
      # salt://dotconfig/<minion_id>/Code
      # salt://dotconfig/<os_family>/<user>/Code
      # salt://dotconfig/<os_family>/Code
      # salt://dotconfig/default/<user>/Code
      # salt://dotconfig/default/Code
    dotconfig:              # can be bool or mapping
      file_mode: '0600'     # default: keep destination or salt umask (new)
      dir_mode: '0700'      # default: 0700
      clean: false          # delete files in target. default: false

      # Persist environment variables used by this formula for this
      # user to this file (will be appended to a file relative to $HOME)
    persistenv: '.config/zsh/zshenv'

      # Add runcom hooks specific to this formula to this file
      # for this user (will be appended to a file relative to $HOME)
    rchook: '.config/zsh/zshrc'

      # This user's configuration for this formula. Will be overridden by
      # user-specific configuration in `tool_vscode:users`.
      # Set this to `false` to disable configuration for this user.
    vscode:
      extensions:
          # List of extensions that should NOT be installed.
        absent:
          - golang.go
          # List of extensions that should be installed.
        wanted:
          - ms-vscode.cpptools
          - ms-python.python

Formula-specific
^^^^^^^^^^^^^^^^

.. code-block:: yaml

  tool_vscode:

      # Default formula configuration for all users.
    defaults:
      extensions: default value for all users

Dotfiles
~~~~~~~~
``tool_vscode.config.sync`` will recursively apply templates from

* ``salt://dotconfig/<minion_id>/<user>/Code``
* ``salt://dotconfig/<minion_id>/Code``
* ``salt://dotconfig/<os_family>/<user>/Code``
* ``salt://dotconfig/<os_family>/Code``
* ``salt://dotconfig/default/<user>/Code``
* ``salt://dotconfig/default/Code``

to the user's config dir for every user that has it enabled (see ``user.dotconfig``). The target folder will not be cleaned by default (ie files in the target that are absent from the user's dotconfig will stay).

The URL list above is in descending priority. This means user-specific configuration from wider scopes will be overridden by more system-specific general configuration.


Available states
----------------

The following states are found in this formula:

.. contents::
   :local:


``tool_vscode``
~~~~~~~~~~~~~~~
*Meta-state*.

Performs all operations described in this formula according to the specified configuration.


``tool_vscode.package``
~~~~~~~~~~~~~~~~~~~~~~~
Installs the Visual Studio Code package only.


``tool_vscode.package.repo``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
This state will install the configured Visual Studio Code repository.
This works for apt/dnf/yum/zypper-based distributions only by default.


``tool_vscode.xdg``
~~~~~~~~~~~~~~~~~~~
Ensures Visual Studio Code adheres to the XDG spec
as best as possible for all managed users.
Has a dependency on `tool_vscode.package`_.


``tool_vscode.config``
~~~~~~~~~~~~~~~~~~~~~~
Manages the Visual Studio Code package configuration by

* recursively syncing from a dotfiles repo

Has a dependency on `tool_vscode.package`_.


``tool_vscode.extensions``
~~~~~~~~~~~~~~~~~~~~~~~~~~



``tool_vscode.clean``
~~~~~~~~~~~~~~~~~~~~~
*Meta-state*.

Undoes everything performed in the ``tool_vscode`` meta-state
in reverse order.


``tool_vscode.package.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Removes the Visual Studio Code package.
Has a dependency on `tool_vscode.config.clean`_.


``tool_vscode.package.repo.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
This state will remove the configured Visual Studio Code repository.
This works for apt/dnf/yum/zypper-based distributions only by default.


``tool_vscode.xdg.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~
Removes Visual Studio Code XDG compatibility crutches for all managed users.


``tool_vscode.config.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Removes the configuration of the Visual Studio Code package.


``tool_vscode.extensions.clean``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~




Development
-----------

Contributing to this repo
~~~~~~~~~~~~~~~~~~~~~~~~~

Commit messages
^^^^^^^^^^^^^^^

Commit message formatting is significant.

Please see `How to contribute <https://github.com/saltstack-formulas/.github/blob/master/CONTRIBUTING.rst>`_ for more details.

pre-commit
^^^^^^^^^^

`pre-commit <https://pre-commit.com/>`_ is configured for this formula, which you may optionally use to ease the steps involved in submitting your changes.
First install  the ``pre-commit`` package manager using the appropriate `method <https://pre-commit.com/#installation>`_, then run ``bin/install-hooks`` and
now ``pre-commit`` will run automatically on each ``git commit``.

.. code-block:: console

  $ bin/install-hooks
  pre-commit installed at .git/hooks/pre-commit
  pre-commit installed at .git/hooks/commit-msg

State documentation
~~~~~~~~~~~~~~~~~~~
There is a script that semi-autodocuments available states: ``bin/slsdoc``.

If a ``.sls`` file begins with a Jinja comment, it will dump that into the docs. It can be configured differently depending on the formula. See the script source code for details currently.

This means if you feel a state should be documented, make sure to write a comment explaining it.

Todo
----
This formula has not been tested and mostly exists as documentation atm. Especially the dotfiles and xdg parts might be flaky.

References
----------
- found `this formula <https://github.com/saltstack-formulas/vscode-formula>`_ after the fact
