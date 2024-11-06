# vim: ft=sls

{#-
    *Meta-state*.

    Undoes everything performed in the ``tool_vscode`` meta-state
    in reverse order.
#}

include:
  - .extensions.clean
  - .config.clean
  - .package.clean
