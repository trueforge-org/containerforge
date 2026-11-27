# speedtest-exporter upstream Dockerfile (v3.5.4)

## Source URL(s) + date
- https://raw.githubusercontent.com/MiguelNdeCarvalho/speedtest-exporter/v3.5.4/Dockerfile (from blob URL in urls.txt)
- Fetched 2026-11-27

## Base / ARG
- `FROM python:3.11.0-alpine3.15`
- `ARG SPEEDTEST_VERSION=1.2.0`
- No ENV declared; HEALTHCHECK uses `${SPEEDTEST_PORT:=9798}`

## Steps
- `RUN adduser -D speedtest` (UID not set; chart uses 1000)
- WORKDIR `/app`
- COPY `src/requirements.txt .`, COPY `src/. .`
- One RUN: `pip install --no-cache-dir -r requirements.txt`; detect `uname -m` (armv7l → armhf); `wget` `https://install.speedtest.net/app/cli/ookla-speedtest-${SPEEDTEST_VERSION}-linux-${ARCHITECTURE}.tgz` to /tmp; `tar zxvf` to /tmp; `cp /tmp/speedtest /usr/local/bin`; `chown -R speedtest:speedtest /app`; `rm -rf /tmp/* /app/requirements`
- No apt/apk package installs.

## Runtime
- USER `speedtest`
- CMD `["python", "-u", "exporter.py"]`
- HEALTHCHECK `--timeout=10s CMD wget --no-verbose --tries=1 --spider http://localhost:${SPEEDTEST_PORT:=9798}/`
- No VOLUME, no EXPOSE, no ENTRYPOINT.
