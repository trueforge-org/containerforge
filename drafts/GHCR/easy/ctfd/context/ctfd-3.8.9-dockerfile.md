# CTFd 3.8.9 Dockerfile

## Source URL(s) + date
- https://raw.githubusercontent.com/CTFd/CTFd/3.8.9/Dockerfile (fetched 2026-11-27)
- https://raw.githubusercontent.com/CTFd/CTFd/5f345fbaa424e6a22b51addf7f27430927879ae2/Dockerfile (the commit blob in urls.txt; byte-identical to 3.8.9)

## Build (multi-stage)
- Stage `build`: `FROM python:3.11-slim-bookworm AS build`, WORKDIR `/opt/CTFd`.
  - apt: `build-essential libffi-dev libssl-dev git`, then clean lists.
  - `python -m pip uninstall -y pip`; `python -m venv /opt/venv`; `PATH=/opt/venv/bin:$PATH`.
  - Installs pip 26.2.2 wheel from files.pythonhosted.org (pinned by URL and sha256).
  - `COPY . /opt/CTFd`; `pip install --no-cache-dir -r requirements.txt`; loops `CTFd/plugins/*` and installs each `requirements.txt` if present.
- Stage `release`: `FROM python:3.11-slim-bookworm AS release`, WORKDIR `/opt/CTFd`.
  - apt: `libffi8 libssl3` only.
  - `python -m pip uninstall -y pip` (system pip removed).
  - `COPY --chown=1001:1001 . /opt/CTFd`.
  - `useradd --no-log-init --shell /bin/bash -u 1001 ctfd`; `mkdir -p /var/log/CTFd /var/uploads`; chown `1001:1001` on those and `/opt/CTFd`; `chmod +x /opt/CTFd/docker-entrypoint.sh`.
  - `COPY --chown=1001:1001 --from=build /opt/venv /opt/venv`; `PATH=/opt/venv/bin:$PATH`.
  - `USER 1001`; `EXPOSE 8000`; `ENTRYPOINT ["/opt/CTFd/docker-entrypoint.sh"]`. No CMD, no VOLUME, no HEALTHCHECK.

## Runtime deps
- libffi8, libssl3 (release stage).

## Gotchas
- The build stage uses a 3.11 base. The release image uses the same 3.11 base and copies `/opt/venv`.
- Upstream's `/opt/venv` is built at build time (not runtime). The chart and plan use a different base.
