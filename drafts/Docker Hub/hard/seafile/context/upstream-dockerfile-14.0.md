# haiwen/seafile-docker image/seafile_14.0/Dockerfile

Source URL(s): https://github.com/haiwen/seafile-docker/blob/7880bf3/image/seafile_14.0/Dockerfile (= full sha 7880bf35bc8e66ee82237b6f6052ebe9803eeace). Fetched via raw.githubusercontent.com, 2026-11-26.

## What it is
- Upstream Docker image build for Seafile 14.0 (Ubuntu 24.04 + phusion baseimage).
- Build context needs: `base_scripts/`, `scripts_14.0/`, `services/`, and `seafile-server-${SEAFILE_VERSION}/` (local dir, not fetched from network).

## Base / init
- `FROM ubuntu:24.04`, `ARG server_version=`, `ENV SEAFILE_SERVER=seafile-server SEAFILE_VERSION=$server_version`
- phusion baseimage prep: `/bd_build/prepare.sh`, `system_services.sh`, `utilities.sh`, `cleanup.sh`
- ENV: `DEBIAN_FRONTEND=teletype LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8`
- `ENV MARIADB_TLS_DISABLE_PEER_VERIFICATION=1`

## apt packages (explicit)
- nginx (from nginx.org apt repo, key via curl)
- utilities: vim htop net-tools psmisc wget curl git unzip
- tzdata, libmysqlclient-dev, libmemcached11, libmemcached-dev, fuse, poppler-utils
- ldap-utils, libldap2-dev, ca-certificates, dnsutils, pkg-config, exiftool
- python3, python3-pip, python3-setuptools, python3-ldap (then `rm /usr/lib/python3.12/EXTERNALLY-MANAGED`, `/usr/bin/python -> python3`)
- python3-jwt 2.15.1-1 `.deb` fetched from deb.debian.org pool (pyjwt fix)

## pip (system-wide, `--ignore-installed`, `--no-cache-dir`)
- base: pip wheel setuptools pyasn1 pyjwt cryptography
- pinned: sqlalchemy==2.0.* pymysql==1.1.* django==5.2.* cffi==2.0.* future==1.0.* mysqlclient==2.2.* captcha==0.7.* django_simple_captcha==0.6.* pyjwt==2.15.* djangosaml2==1.11.* pysaml2==7.5.* pycryptodome==3.23.* python-ldap==3.4.* pillow==13.0.* pillow-heif==1.2.* cairosvg==2.9.*
- unpinned: click termcolor colorlog pytz jinja2 django-pylibmc pylibmc psd-tools lxml

## Layout / files
- `COPY scripts_14.0 /scripts`, `COPY services /services`
- `/etc/my_init.d/01_create_data_links.sh` <- `/scripts/create_data_links.sh`
- nginx: `/etc/nginx/nginx.conf` <- services/nginx.conf; `/etc/service/nginx/run` <- services/nginx.sh; `/etc/nginx/sites-enabled/seafile.nginx.conf`; default sites/conf.d removed
- LDAP: `/etc/ldap/ldap.conf` gets `TLS_REQCERT allow`, `TLS_CACERT /etc/ssl/certs/ca-certificates.crt`
- `chmod u+x /scripts/*`; `rm /scripts/cluster*`

## Seafile server
- `WORKDIR /opt/seafile`
- `COPY --chmod=777 seafile-server-${SEAFILE_VERSION} /opt/seafile/seafile-server-${SEAFILE_VERSION}`

## Entrypoint / ports
- `EXPOSE 80`
- `CMD ["/sbin/my_init", "--", "/scripts/enterpoint.sh"]` (note: script name spelled `enterpoint.sh`)

## Gotchas
- Upstream runs as root under my_init (phusion); nginx listens on 80.
- `/opt/seafile` is world-writable (777) in upstream.
- Needs `SEAFILE_VERSION` build arg to match the tarball dir name.
