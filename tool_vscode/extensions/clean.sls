# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as vscode with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch %}


{%- for user in vscode.users | selectattr('vscode.extensions', 'defined') | selectattr('vscode.extensions') %}

Configured VSCode extensions are absent for user '{{ user.name }}':
  vscode.absent:
    - names: {{ user.vscode.extensions.get('wanted', []) }}
    - user: {{ user.name }}
{%- endfor %}
