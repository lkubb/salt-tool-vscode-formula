# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as vscode with context %}


{%- if grains['os'] in ['Debian', 'Ubuntu'] %}

Ensure Visual Studio Code APT repository can be managed:
  pkg.installed:
    - pkgs:
      - apt-transport-https           # the repos use https
      - python-apt                    # required by Salt
{%-   if 'Ubuntu' == grains['os'] %}
      - python-software-properties    # to better support PPA repositories
{%-   endif %}
{%- endif %}

{%- for reponame in vscode.lookup.pkg.enablerepo %}

{%-   if 'apt' == vscode.lookup.pkg.manager %}

Visual Studio Code {{ reponame }} signing key is available:
  file.managed:
    - name: {{ vscode.lookup.pkg.repos[reponame].keyring.file }}
    - source: {{ files_switch([salt['file.basename'](vscode.lookup.pkg.repos[reponame].keyring.file)],
                          lookup='Visual Studio Code ' ~ reponame ~ ' signing key is available')
              }}
      - {{ vscode.lookup.pkg.repos[reponame].keyring.source }}
    - source_hash: {{ vscode.lookup.pkg.repos[reponame].keyring.source_hash }}
    - user: root
    - group: {{ brave.lookup.rootgroup }}
    - mode: '0644'
    - dir_mode: '0755'
    - makedirs: true
    # since we dearmor the file after, do not attempt to overwrite when changed
    - unless:
      - test -e '{{ vscode.lookup.pkg.repos[reponame].keyring.file }}'

Visual Studio Code {{ reponame }} signing key is dearmored:
  cmd.run:
    - name: cat '{{ vscode.lookup.pkg.repos[reponame].keyring.file }}' | gpg --dearmor > {{ vscode.lookup.pkg.repos[reponame].keyring.file }}
    - onchanges:
      - Visual Studio Code {{ reponame }} signing key is available
{%-   endif %}

Visual Studio Code {{ reponame }} repository is available:
  pkgrepo.managed:
{%-   for conf, val in vscode.lookup.pkg.repos[reponame].items() %}
    - {{ conf }}: {{ val }}
{%-   endfor %}
{%-   if vscode.lookup.pkg.manager in ['dnf', 'yum', 'zypper'] %}
    - enabled: 1
{%-   endif %}
{%-   if 'apt' == vscode.lookup.pkg.manager %}
    - require:
      - Visual Studio Code {{ reponame }} signing key is available
{%-   endif %}
    - require_in:
      - Visual Studio Code is installed
{%- endfor %}

{%- for reponame, repodata in vscode.lookup.pkg.repos.items() %}

{%-   if reponame not in vscode.lookup.pkg.enablerepo %}
Visual Studio Code {{ reponame }} repository is disabled:
  pkgrepo.absent:
{%-     for conf in ['name', 'ppa', 'ppa_auth', 'keyid', 'keyid_ppa', 'copr'] %}
{%-       if conf in repodata %}
    - {{ conf }}: {{ repodata[conf] }}
{%-       endif %}
{%-     endfor %}
    - require_in:
      - Visual Studio Code is installed
{%-   endif %}
{%- endfor %}
