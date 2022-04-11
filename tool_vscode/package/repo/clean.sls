# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as vscode with context %}


{%- if vscode.lookup.pkg.manager not in ['apt', 'dnf', 'yum', 'zypper'] %}
{%-   if salt['state.sls_exists'](slsdotpath ~ '.' ~ vscode.lookup.pkg.manager ~ '.clean') %}

include:
  - {{ slsdotpath ~ '.' ~ vscode.lookup.pkg.manager ~ '.clean' }}
{%-   endif %}

{%- else %}

{%-   if 'apt' == vscode.lookup.pkg.manager %}

Visual Studio Code {{ reponame }} signing key is unavailable:
  file.absent:
    - name: {{ vscode.lookup.pkg.repos[reponame].keyring.file }}
{%-   endif %}

{%-   for reponame, repodata in vscode.lookup.pkg.repos.items() %}

Visual Studio Code {{ reponame }} repository is absent:
  pkgrepo.absent:
{%-     for conf in ['name', 'ppa', 'ppa_auth', 'keyid', 'keyid_ppa', 'copr'] %}
{%-       if conf in repodata %}
    - {{ conf }}: {{ repodata[conf] }}
{%-       endif %}
{%-     endfor %}
{%-   endfor %}
{%- endif %}
