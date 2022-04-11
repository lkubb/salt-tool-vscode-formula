# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as vscode with context %}

include:
  - {{ tplroot }}.package

# https://github.com/microsoft/vscode/issues/68958
# https://github.com/microsoft/vscode/issues/3884


{%- for user in vscode.users | rejectattr('xdg', 'sameas', False) %}

{%-   set user_default_conf = user.home | path_join(vscode.lookup.paths.confdir) %}
{%-   set user_default_data = user.home | path_join(vscode.lookup.paths.datadir) %}
{%-   set user_xdg_confdir = user.xdg.config | path_join(vscode.lookup.paths.xdg_dirname) %}
{%-   set user_xdg_datadir = user.xdg.data | path_join(vscode.lookup.paths.xdg_dirname) %}
{%-   set user_xdg_conffile = user_xdg_confdir | path_join(vscode.lookup.paths.xdg_conffile) %}

# workaround for file.rename not supporting user/group/mode for makedirs
Visual Studio Code has its data dir in XDG_DATA_HOME for user '{{ user.name }}':
  file.directory:
    - name: {{ user_xdg_datadir }}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - mode: '0700'
    - makedirs: true

Existing VSCode extensions are migrated for user '{{ user.name }}':
  file.rename:
    - name: {{ user_xdg_datadir | path_join('extensions') }}
    - source: {{ user_default_data | path_join('extensions') }}
    - require:
      - Visual Studio Code has its data dir in XDG_DATA_HOME for user '{{ user.name }}'
    - require_in:
      - Visual Studio Code setup is completed

{%-   if 'Darwin' == grains.kernel %}
{#-     On MacOS, force settings to XDG_CONFIG_HOME. -#}

# workaround for file.rename not supporting user/group/mode for makedirs
XDG_CONFIG_HOME exists for Visual Studio Code for user '{{ user.name }}':
  file.directory:
    - name: {{ user.xdg.config }}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - mode: '0700'
    - makedirs: true

Existing Visual Studio Code configuration is migrated for user '{{ user.name }}':
  file.rename:
    - name: {{ user_xdg_confdir }}
    - source: {{ user_default_conf }}
    - require:
      - XDG_CONFIG_HOME exists for Visual Studio Code for user '{{ user.name }}'
    - require_in:
      - Visual Studio Code setup is completed
    - unless:
      - test -L '{{ user_default_conf }}'

# cannot use file.rename and file.symlink in one state ID (same state module)
Visual Studio Code knows about XDG location of config dir for user '{{ user.name }}':
  file.symlink:
    - name: {{ user_default_conf }}
    - target: {{ user_xdg_confdir }}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - makedirs: true
    - require:
      - Existing Visual Studio Code configuration is migrated for user '{{ user.name }}'
    - require_in:
      - Visual Studio Code setup is completed

Visual Studio Code has its config file in XDG_CONFIG_HOME for user '{{ user.name }}':
  file.managed:
    - name: {{ user_xdg_conffile }}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - replace: false
    - makedirs: true
    - mode: '0600'
    - dir_mode: '0700'
    - require:
      - Existing Visual Studio Code configuration is migrated for user '{{ user.name }}'
    - require_in:
      - Visual Studio Code setup is completed
{%-   endif %}

# @FIXME
# This actually does not make sense and might be harmful:
# Each file is executed for all users, thus this breaks
# when more than one is defined!
Visual Studio Code uses XDG dirs during this salt run:
  environ.setenv:
    - value:
        VSCODE_EXTENSIONS: "{{ user_xdg_datadir | path_join('extensions') }}"
    - require_in:
      - Visual Studio Code setup is completed

{%-   if user.get('persistenv') %}

persistenv file for Visual Studio Code exists for user '{{ user.name }}':
  file.managed:
    - name: {{ user.home | path_join(user.persistenv) }}
    - user: {{ user.name }}
    - group: {{ user.group }}
    - replace: false
    - mode: '0600'
    - dir_mode: '0700'
    - makedirs: true

# This would likely need global environment variables to work
# even when launching via GUI. See `tool_env`.
Visual Studio Code knows about XDG location for user '{{ user.name }}':
  file.append:
    - name: {{ user.home | path_join(user.persistenv) }}
    - text: export VSCODE_EXTENSIONS="${XDG_DATA_HOME:-$HOME/.local/share}/{{ vscode.lookup.paths.xdg_dirname | path_join('extensions') }}"
    - require:
      - persistenv file for Visual Studio Code exists for user '{{ user.name }}'
    - require_in:
      - Visual Studio Code setup is completed
{%-   endif %}
{%- endfor %}
