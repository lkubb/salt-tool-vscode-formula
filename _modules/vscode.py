import json

import salt.utils.platform
from salt.exceptions import CommandExecutionError

__virtualname__ = "vscode"


def __virtual__():
    return __virtualname__


def _which(user=None):
    e = __salt__["cmd.run"]("command -v code", runas=user)
    # if e := __salt__["cmd.run"]("command -v code", runas=user):
    if e:
        return e
    if salt.utils.platform.is_darwin():
        # brew --prefix does not work
        for f in ["/opt/homebrew/bin", "/usr/local/bin"]:
            p = __salt__["cmd.run"](
                "test -s {}/code && echo {}/code".format(f, f), runas=user
            )
            # if p := __salt__["cmd.run"]("test -s {}/code && echo {}/code".format(f, f) , runas=user):
            if p:
                return p
    raise CommandExecutionError("Could not find code executable.")


def is_installed(name, user=None):
    """
    Check whether VSCode extension is installed.

    CLI Example:

    .. code-block:: bash

        salt '*' vscode.is_installed ms-vscode.cpptools user=user

    name
        The extension id to check for

    user
        The username to check the extension for. Defaults to salt user.
    """
    return name in list_installed(user)


def install(name, user=None):
    """
    Install a VSCode extension.

    CLI Example:

    .. code-block:: bash

        salt '*' vscode.install ms-vscode.cpptools user=user

    name
        The extension id to install

    user
        The username to install the extension for. Defaults to salt user.
    """
    e = _which(user)

    out = __salt__["cmd.run_all"](
        "{} --install-extension '{}'".format(e, name), runas=user
    )

    if out["retcode"]:
        raise CommandExecutionError("Error from `code`: {}".format(out["stderr"]))

    return True


def remove(name, user=None):
    """
    Remove a VSCode extension.

    CLI Example:

    .. code-block:: bash

        salt '*' vscode.remove ms-vscode.cpptools user=user

    name
        The extension id to remove

    user
        The username to remove the extension for. Defaults to salt user.
    """
    e = _which(user)

    out = __salt__["cmd.run_all"](
        "{} --uninstall-extension '{}'".format(e, name), runas=user
    )

    if out["retcode"]:
        raise CommandExecutionError("Error from `code`: {}".format(out["stderr"]))

    return True


def list_installed(user=None):
    """
    Lists installed VSCode extensions.

    CLI Example:

    .. code-block:: bash

        salt '*' vscode.list_installed user=user

    user
        The username to list the extensions for. Defaults to salt user.
    """
    e = _which(user)

    out = __salt__["cmd.run_all"]("{} --list-extensions".format(e), runas=user)

    if out["retcode"]:
        raise CommandExecutionError("Error from `code`: {}".format(out["stderr"]))

    if out["stdout"]:
        return _parse(out["stdout"])

    return []


def _parse(installed):
    return list(installed.splitlines())
