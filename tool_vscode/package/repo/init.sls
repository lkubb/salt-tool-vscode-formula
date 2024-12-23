# vim: ft=sls

{#-
    This state will install the configured Visual Studio Code repository.
    This works for apt/dnf/yum/zypper-based distributions only by default.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as vscode with context %}

include:
{%- if vscode.lookup.pkg.manager in ["apt", "dnf", "yum", "zypper"] %}
  - {{ slsdotpath }}.install
{%- elif salt["state.sls_exists"](slsdotpath ~ "." ~ vscode.lookup.pkg.manager) %}
  - {{ slsdotpath }}.{{ vscode.lookup.pkg.manager }}
{%- else %}
  []
{%- endif %}
