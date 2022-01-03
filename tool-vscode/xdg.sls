{%- from 'tool-vscode/map.jinja' import vscode -%}

include:
  - .package

# https://github.com/microsoft/vscode/issues/68958
# https://github.com/microsoft/vscode/issues/3884

{%- for user in vscode.users | rejectattr('xdg', 'sameas', False) %}
Existing VSCode extensions are migrated for user '{{ user.name }}':
  file.rename:
    - name: {{ user.xdg.data }}/vscode/extensions
    - source: {{ user.home }}/.vscode/extensions
    - onlyif:
      - test -e {{ user.home }}/.vscode/extensions
    - makedirs: true
    - prereq_in:
      - VSCode setup is completed

  {%- if 'Darwin' == grains['kernel'] %}

VSCode user settings are migrated to ~/.config/vscode for user {{ user.name }}:
  file.rename:
    - name: {{ user.xdg.config }}/vscode
    - source: {{ user.home }}/Library/Application Support/Code/User
    - onlyif:
      - test -e {{ user.home }}/Library/Application Support/Code/User
    - unless:
      - test -L {{ user.home }}/Library/Application Support/Code/User
  file.symlink:
    - name: {{ user.home }}/Library/Application Support/Code/User
    - target: {{ user.xdg.config }}/vscode
    - user: {{ user.name }}
    - group: {{ user.group }}
  {%- endif %}

VSCode uses XDG dirs during this salt run:
  environ.setenv:
    - value:
        VSCODE_EXTENSIONS: "{{ user.xdg.data }}/vscode/extensions"
    - prereq_in:
      - VSCode setup is completed

  {%- if user.get('persistenv') %}
VSCode knows about XDG location for user '{{ user.name }}':
  file.append:
    - name: {{ user.home }}/{{ user.persistenv }}
    - text: export VSCODE_EXTENSIONS="${XDG_DATA_HOME:-$HOME/.local/share}/vscode/extensions"
    - user: {{ user.name }}
    - group: {{ user.group }}
    - mode: '0600'
    - prereq_in:
      - VSCode setup is completed
  {%- endif %}
{%- endfor %}
