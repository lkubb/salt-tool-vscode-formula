{%- from 'tool-vscode/map.jinja' import vscode -%}

VSCode is installed:
  pkg.installed:
    - name: {{ vscode.package }}

VSCode setup is completed:
  test.nop:
    - name: VSCode setup has finished, this state exists for technical reasons.
    - require:
      - pkg: {{ vscode.package }}
