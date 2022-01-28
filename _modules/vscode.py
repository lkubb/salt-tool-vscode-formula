import salt.utils.platform
from salt.exceptions import CommandExecutionError
import json


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
        for f in ['/opt/homebrew/bin', '/usr/local/bin']:
            p = __salt__["cmd.run"]("test -s {}/code && echo {}/code".format(f, f) , runas=user)
            # if p := __salt__["cmd.run"]("test -s {}/code && echo {}/code".format(f, f) , runas=user):
            if p:
                return p
    raise CommandExecutionError("Could not find code executable.")


def is_installed(name, user=None):
    return name in _list_installed(user)


def install(name, user=None):
    e = _which(user)

    return not __salt__['cmd.retcode']("{} --install-extension '{}'".format(e, name), runas=user)


def remove(name, user=None):
    e = _which(user)

    return not __salt__['cmd.retcode']("{} --uninstall-extension '{}'".format(e, name), runas=user)


def _list_installed(user=None):
    e = _which(user)
    out = json.loads(__salt__['cmd.run_stdout']('{} --list-extensions'.format(e), runas=user, raise_err=True))
    if out:
        return _parse(out)
    raise CommandExecutionError('Something went wrong while calling VSCode.')


def _parse(installed):
    return list(installed.splitlines())
