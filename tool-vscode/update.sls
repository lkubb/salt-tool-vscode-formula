{%- from 'tool-vscode/map.jinja' import vscode %}

{%- if vscode.users | selectattr('dotconfig', 'defined') | selectattr('dotconfig') %}
include:
  - .configsync
{%- endif %}
