# -*- coding: utf-8 -*-
# vim: ft=sls

{#- Get the `tplroot` from `tpldir` #}
{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as vscode with context %}

include:
  - {{ tplroot }}.package


{%- for user in vscode.users | rejectattr('xdg', 'sameas', false) %}

{%-   set user_default_conf = user.home | path_join(vscode.lookup.paths.confdir) %}
{%-   set user_default_data = user.home | path_join(vscode.lookup.paths.datadir) %}
{%-   set user_xdg_confdir = user.xdg.config | path_join(vscode.lookup.paths.xdg_dirname) %}
{%-   set user_xdg_datadir = user.xdg.data | path_join(vscode.lookup.paths.xdg_dirname) %}


Existing VSCode extensions are cluttering $HOME for user '{{ user.name }}':
  file.rename:
    - name: {{ user_default_data | path_join('extensions') }}
    - source: {{ user_xdg_datadir | path_join('extensions') }}
    - onlyif:
      - test -e '{{ user_default_data | path_join('extensions') }}'

Visual Studio Code does not have its data dir in XDG_DATA_HOME for user '{{ user.name }}':
  file.absent:
    - name: {{ user_xdg_datadir }}
    - require:
      - Existing VSCode extensions are cluttering $HOME for user '{{ user.name }}'

{%-   if 'Darwin' == grains.kernel %}

Visual Studio Code does not care about XDG location of config dir for user '{{ user.name }}':
  file.absent:
    - name: {{ user_default_conf }}
    - onlyif:
      - test -L '{{ user_default_conf }}'

Existing Visual Studio Code config lives in Library for user '{{ user.name }}':
  file.rename:
    - name: {{ user_default_conf }}
    - source: {{ user_xdg_confdir }}
    - require:
      - Visual Studio Code does not care about XDG location of config dir for user '{{ user.name }}'

# workaround for file.rename not supporting user/group/mode for makedirs
Visual Studio Code does not have its config dir in XDG_CONFIG_HOME for user '{{ user.name }}':
  file.absent:
    - name: {{ user.xdg.config }}
    - require:
      - Existing Visual Studio Code config lives in Library for user '{{ user.name }}'
{%-   endif %}

# @FIXME
# This actually does not make sense and might be harmful:
# Each file is executed for all users, thus this breaks
# when more than one is defined!
Visual Studio Code uses XDG dirs during this salt run:
  environ.setenv:
    - false_unsets: true
    - value:
        VSCODE_EXTENSIONS: false

{%-   if user.get('persistenv') %}

# This would likely need global environment variables to work
# even when launching via GUI. See `tool_env`.
Visual Studio Code knows about XDG location for user '{{ user.name }}':
  file.replace:
    - name: {{ user.home | path_join(user.persistenv) }}
    - pattern: ^{{ 'export VSCODE_EXTENSIONS="${XDG_DATA_HOME:-$HOME/.local/share}/'
                  ~ vscode.lookup.xdg_dirname | path_join('extensions') ~ '"' | regex_escape ~ '$' }}
    - repl: ''
    - ignore_if_missing: true
{%-   endif %}
{%- endfor %}
