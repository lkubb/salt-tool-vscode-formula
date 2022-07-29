# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as vscode with context %}

include:
  - {{ slsdotpath }}.repo


{%- if 'Windows' == grains.os %}

Visual Studio Code is installed:
  chocolatey.installed:
    - name: {{ vscode.lookup.pkg.name }}
{%- else %}

Visual Studio Code is installed:
  pkg.installed:
    - name: {{ vscode.lookup.pkg.name }}
{%- endif %}

Visual Studio Code setup is completed:
  test.nop:
    - name: Hooray, Visual Studio Code setup has finished.
    - require:
      - Visual Studio Code is installed
