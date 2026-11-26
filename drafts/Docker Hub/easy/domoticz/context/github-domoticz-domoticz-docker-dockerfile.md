# domoticz/domoticz-docker Dockerfile (master)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/domoticz/domoticz-docker/master/Dockerfile (from the draft's blob link on master) · 2026-11-26

## Stages
- ARG `PYTHON_VERSION=3.13`, `DEBIAN_VERSION=trixie`, `DEBIAN_FRONTEND=noninteractive`, `APP_VERSION`, `APP_HASH`, `BUILD_DATE`, `STABLE`.
- `compiler`: `FROM python:${PYTHON_VERSION}-slim`. `ENV PYTHONUNBUFFERED=1`. `python -m venv /opt/venv && /opt/venv/bin/pip install -U setuptools requests pyserial charset-normalizer==2.1.1`.
- `application`: `FROM debian:${DEBIAN_VERSION}-slim`. WORKDIR `/opt/domoticz`.
  - `rm /bin/sh && ln -s /bin/bash /bin/sh`.
  - apt (after `rm /var/lib/dpkg/info/libc-bin.*`): `ca-certificates libc-bin tzdata rsync unzip less vim git jq libmosquitto1 libudev1 libusb-0.1-4 libsqlite3-0 curl libcurl4-gnutls-dev libpython${PYTHON_VERSION}-dev`, then `ldconfig`, clean lists.
  - Download: `OS=$(uname -s|lower)`, `MACH=$(uname -m)` (armv6l mapped to armv7l); `archive_file="domoticz_${OS}_${MACH}.tgz"`; from `https://releases.domoticz.com/beta/` or `/release/` (if STABLE set); `tar xfz domoticz.tgz`; `mkdir -p /opt/domoticz/userdata`.
  - `chmod +x /usr/local/bin/docker-entrypoint.sh`, symlink `/docker-entrypoint.sh`.
  - COPY `--from=compiler /opt/venv /opt/venv` and `/usr/local/bin/python`; `COPY docker-entrypoint.sh /usr/local/bin/`; `COPY customstart.sh /opt/domoticz/customstart.sh`.
  - ENV: `LOG_PATH=`, `DATABASE_PATH=`, `WWW_PORT=8080`, `SSL_PORT=443`, `EXTRA_CMD_ARG=`, `PATH=/opt/venv/bin:$PATH`, `TZ=Europe/Amsterdam`.
  - `EXPOSE 8080`, `EXPOSE 443`, `VOLUME /opt/domoticz/userdata`, `ENTRYPOINT ["docker-entrypoint.sh"]`, `CMD ["/opt/domoticz/domoticz"]`.
- No USER, no HEALTHCHECK.

## Notes vs plan.md
- Matches plan.md section 1 (trixie slim, apt list, `libpython3.13-dev`, EXPOSE 8080 443, VOLUME, WWW_PORT/SSL_PORT/EXTRA_CMD_ARG, TZ value, venv packages).
- Upstream downloads from `releases.domoticz.com` (plan uses GitHub asset instead, as the plan says).
- Upstream runs as root (no USER; entrypoint chowns userdata to 1000:1000).
