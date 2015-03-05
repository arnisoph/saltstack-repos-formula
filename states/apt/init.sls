#!jinja|yaml

{% set datamap = salt['formhelper.get_defaults']('repos', saltenv, ['yaml'])['yaml'] %}

{% for k, v in datamap.preferences|default({})|dictsort %}
aptpref_{{ k }}:
  file:
    - managed
    - name: {{ datamap.conf_dir|default('/etc/apt/preferences.d') }}/{{ k }}
    - mode: 644
    - user: root
    - group: root
    - contents_pillar: repos:lookup:preferences:{{ k }}:contents
    - order: 1000
{% endfor %}

{% for k, v in datamap.configs|default({})|dictsort %}
aptconf_{{ k }}:
  file:
    - managed
    - name: {{ datamap.conf_dir|default('/etc/apt/apt.conf.d') }}/{{ k }}
    - mode: 644
    - user: root
    - group: root
    - contents_pillar: repos:lookup:configs:{{ k }}:contents
    - order: 1000
{% endfor %}

{% if datamap.remove_popularitycontest|default(False) %}
debian_pkg_popularity_contest:
  pkg:
    - name: popularity-contest
    - purged
{% endif %}

{% if datamap.pkgs|length > 0 %}
aptpkgs:
  pkg:
    - installed
    - pkgs: {{ datamap.pkgs }}
    - order: 1500
{% endif %}

{% for id, r in datamap.repos|default({})|dictsort %}
aptrepo_{{ r.name|default(id) }}:
  pkgrepo:
    - {{ r.ensure|default('managed') }}
    - name: {{ r.debtype|default('deb') }} {{ r.url }} {{ r.dist|default(salt['grains.get']('oscodename')) }}{% for c in r.comps|default(['main', 'contrib', 'non-free']) %} {{ c }}{% endfor %}
  {% if not r.globalfile|default(False) %}
    - file: {{ datamap.sources_dir|default('/etc/apt/sources.list.d') }}/{{ r.name|default(id) }}.list
  {% endif %}
  {% if 'keyuri' in r %}
    - key_url: {{ r.keyuri }}
  {% endif %}
    - order: 2000
{% endfor %}
