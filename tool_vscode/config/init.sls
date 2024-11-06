# vim: ft=sls

{#-
    Manages the Visual Studio Code package configuration by

    * recursively syncing from a dotfiles repo

    Has a dependency on `tool_vscode.package`_.
#}

include:
  - .sync
