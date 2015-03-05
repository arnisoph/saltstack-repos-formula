#!jinja|yaml

{% set datamap = salt['formhelper.get_defaults']('repos', saltenv, ['yaml'])['yaml'] %}

# SLS includes/ excludes
include: {{ datamap.sls_include }}
extend: {{ datamap.sls_extend|default({}) }}
