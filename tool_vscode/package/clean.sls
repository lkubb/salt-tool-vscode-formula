# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as vscode with context %}

include:
  - {{ sls_config_clean }}
  - {{ slsdotpath }}.repo.clean


Visual Studio Code is removed:
  pkg.removed:
    - name: {{ vscode.lookup.pkg.name }}
    - require:
      - sls: {{ sls_config_clean }}
