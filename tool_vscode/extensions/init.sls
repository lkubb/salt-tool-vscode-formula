# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_package_install = tplroot ~ '.package.install' %}
{%- from tplroot ~ "/map.jinja" import mapdata as vscode with context %}

include:
  - {{ sls_package_install }}


{%- for user in vscode.users | selectattr('vscode.extensions', 'defined') | selectattr('vscode.extensions') %}

Wanted VSCode extensions are installed for user '{{ user.name }}':
  vscode.installed:
    - names: {{ user.vscode.extensions.get('wanted', []) }}
    - user: {{ user.name }}
    - require:
      - sls: {{ sls_package_install }}

Unwanted VSCode extensions are absent for user '{{ user.name }}':
  vscode.absent:
    - names: {{ user.vscode.extensions.get('absent', []) }}
    - user: {{ user.name }}
    - require:
      - sls: {{ sls_package_install }}
{%- endfor %}
