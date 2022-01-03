{%- from 'tool-vscode/map.jinja' import vscode -%}

include:
  - .package
{%- if vscode.users | rejectattr('xdg', 'sameas', False) %}
  - .xdg
{%- endif %}
{%- if vscode.users | selectattr('dotconfig', 'defined') | selectattr('dotconfig') %}
  - .configsync
{%- endif %}
