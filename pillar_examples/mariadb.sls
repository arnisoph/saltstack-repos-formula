repos:
  lookup:
    repos:
      mariadb:
{% if salt['grains.get']('os_family') == 'Debian' %}
        url: http://mirror.netcologne.de/mariadb/repo/5.5/debian
        keyserver: keyserver.ubuntu.com
        #keyuri:
        keyid: 1BB943DB
        dist: wheezy
        comps:
          - main
        globalfile: True
{% elif salt['grains.get']('os_family') == 'RedHat' %}
        url: http://yum.mariadb.org/10.0/centos7-amd64
        keyuri: https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
{% endif %}
