# odoo/docker (Dockerfile 20.0 at pinned commit, entrypoint)

## Source URL(s) + date
- https://raw.githubusercontent.com/odoo/docker/0ea197eb3852ca500e38fd72074b314833ee7dc8/20.0/Dockerfile (fetched 2026-11-27)
- https://raw.githubusercontent.com/odoo/docker/master/20.0/entrypoint.sh (fetched 2026-11-27)
- https://github.com/odoo/docker/blob/0ea197eb.../20.0/Dockerfile: same file as raw.

## Dockerfile (20.0, pinned 0ea197e)
- `FROM ubuntu:noble`; LABEL maintainer Odoo S.A.
- `SHELL ["/bin/bash", "-xo", "pipefail", "-c"]`; `ENV LANG=en_US.UTF-8`.
- Apt deps: ca-certificates curl dirmngr fonts-noto-cjk gnupg libssl-dev node-less python3-magic python3-num2words python3-odf python3-pdfminer python3-pip python3-phonenumbers python3-pyldap python3-qrcode python3-renderpm python3-setuptools python3-slugify python3-vobject python3-watchdog python3-xlrd python3-xlwt xz-utils.
- wkhtmltopdf 0.12.6.1-3 (jammy .deb) from GitHub releases; SHA1-checked per arch: amd64, arm64, ppc64le (ppc64el package name).
- postgresql-client from apt.postgresql.org (noble-pgdg), key B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8.
- nodejs + npm install global `rtlcss`; npm purged after.
- Odoo: `ENV ODOO_VERSION=20.0`; `ARG ODOO_RELEASE=20261112`; `ARG ODOO_SHA=9b69ffe4ebf8a4412b312d1f71494112d8410e12`.
  - Downloads `http://nightly.odoo.com/20.0/nightly/deb/odoo_20.0.20261112_all.deb`, sha1 check, `apt-get install ./odoo.deb`.
- `COPY ./entrypoint.sh /`, `COPY ./odoo.conf /etc/odoo/`.
- `chown odoo /etc/odoo/odoo.conf`; `mkdir -p /mnt/extra-addons` owned by odoo.
- `VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]`.
- `EXPOSE 8069 8071 8072`.
- `ENV ODOO_RC=/etc/odoo/odoo.conf`.
- `COPY wait-for-psql.py /usr/local/bin/`.
- `USER odoo`. `ENTRYPOINT ["/entrypoint.sh"]`, `CMD ["odoo"]`.

## Entrypoint (20.0/entrypoint.sh)
- `set -e`; PASSWORD from `PASSWORD_FILE` if set.
- DB defaults: HOST = `DB_PORT_5432_TCP_ADDR` or `db`; PORT = `DB_PORT_5432_TCP_PORT` or 5432; USER = `DB_ENV_POSTGRES_USER` / `POSTGRES_USER` or `odoo`; PASSWORD = `DB_ENV_POSTGRES_PASSWORD` / `POSTGRES_PASSWORD` or `odoo`.
- Adds `--db_host/--db_port/--db_user/--db_password` only if not in `$ODOO_RC` and PG env var not set (PGHOST, PGPORT, PGUSER, PGPASSWORD).
- `odoo` or `-*` args: `wait-for-psql.py --timeout=30` then `exec odoo "$@"`; `scaffold` runs without wait; other args exec directly.

## Ports / volumes / user
- Ports 8069 (HTTP), 8071, 8072 (longpolling/livechat).
- Volumes `/var/lib/odoo` (filestore), `/mnt/extra-addons`.
- User `odoo`.

## Gotchas
- Pinned Dockerfile uses nightly deb build 20261112; Docker Hub `20.0` tags come from a later commit (ec04c28).
- Needs external PostgreSQL; entrypoint waits up to 30 s.
