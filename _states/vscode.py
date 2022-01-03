"""
VSCode extension management salt states
======================================================

"""

# import logging
import salt.exceptions

# import salt.utils.platform

# log = logging.getLogger(__name__)

__virtualname__ = "vscode"


def __virtual__():
    return __virtualname__


def installed(name, user=None):
    """
    Make sure VSCode extension is installed.

    CLI Example:

    .. code-block:: bash

        salt '*' vscode.installed ms-vscode.cpptools user=user

    name
        The extension id to install, if not installed already.

    user
        The username to install the extension for. Defaults to salt user.

    """
    ret = {"name": name, "result": True, "comment": "", "changes": {}}

    try:
        if __salt__["vscode.is_installed"](name, user):
            ret["comment"] = "VSCode extension is already installed."
        elif __opts__['test']:
            ret['result'] = None
            ret['comment'] = "VSCode extension '{}' would have been installed for user '{}'.".format(name, user)
            ret["changes"] = {'installed': name}
        elif __salt__["vscode.install"](name, user):
            ret["comment"] = "VSCode extension '{}' was installed for user '{}'.".format(name, user)
            ret["changes"] = {'installed': name}
        else:
            ret["result"] = False
            ret["comment"] = "Something went wrong while calling VSCode."
    except salt.exceptions.CommandExecutionError as e:
        ret["result"] = False
        ret["comment"] = str(e)

    return ret


def absent(name, user=None):
    """
    Make sure VSCode extension is removed.

    CLI Example:

    .. code-block:: bash

        salt '*' vscode.absent ms-vscode.cpptools user=user

    name
        The extension id to remove, if installed.

    user
        The username to remove the extension for. Defaults to salt user.

    """
    ret = {"name": name, "result": True, "comment": "", "changes": {}}

    try:
        if not __salt__["vscode.is_installed"](name, user):
            ret["comment"] = "VSCode extension is already absent."
        elif __opts__['test']:
            ret['result'] = None
            ret['comment'] = "VSCode extension '{}' would have been removed for user '{}'.".format(name, user)
            ret["changes"] = {'installed': name}
        elif __salt__["vscode.remove"](name, user):
            ret["comment"] = "VSCode extension '{}' was removed for user '{}'.".format(name, user)
            ret["changes"] = {'installed': name}
        else:
            ret["result"] = False
            ret["comment"] = "Something went wrong while calling VSCode."
    except salt.exceptions.CommandExecutionError as e:
        ret["result"] = False
        ret["comment"] = str(e)

    return ret
