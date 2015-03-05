repos:
  lookup:
    remove_popularitycontest: True
    repos:
      os:
        url: http://http.debian.net/debian/
        globalfile: True
      security:
        url: http://security.debian.org/
        dist: wheezy/updates
        globalfile: True
      backports:
        url: http://http.debian.net/debian/
        dist: wheezy-backports
        globalfile: True
      updates:
        url: http://http.debian.net/debian/
        dist: wheezy-updates
        globalfile: True
      os_ftp:
        ensure: absent
        url: http://ftp.debian.org:80/debian/
        comps:
          - non-free
          - contrib
          - main
      os_src_ftp:
        ensure: absent
        debtype: deb-src
        url: http://ftp.debian.org:80/debian/
        comps:
          - non-free
          - contrib
          - main
      security_src_ftp:
        ensure: absent
        debtype: deb-src
        url: http://security.debian.org/
        dist: wheezy/updates
        comps:
          - non-free
          - contrib
          - main
    configs:
      999custom:
        contents: |
          APT::Install-Recommends "0";
          APT::Install-Suggests "0";
    preferences:
      999custom:
        contents: |
          Package: python-requests python-zmq python-urllib3
          Pin: release a=wheezy-backports
          Pin-Priority: 1000
