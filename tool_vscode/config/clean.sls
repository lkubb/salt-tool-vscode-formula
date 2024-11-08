# vim: ft=sls

{#-
    Removes the configuration of the Visual Studio Code package.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as vscode with context %}


{%- for user in vscode.users %}

Visual Studio Code config/data dirs are absent for user '{{ user.name }}':
  file.absent:
    - names:
      - {{ user["_vscode"].confdir }}
      - {{ user["_vscode"].datadir }}
{%- endfor %}
