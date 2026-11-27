# FlareSolverr Dockerfile

Source URL: https://raw.githubusercontent.com/FlareSolverr/FlareSolverr/93125d6ea6956906c8dfa29e169b2dc67d993dc3/Dockerfile (commit 93125d6, fetched 2026-11-27)

## Stages
1. `FROM python:3.11-slim-bookworm AS builder`: equivs dummy packages `libgl1-mesa-dri` 99.0.0 and `adwaita-icon-theme` 99.0.0 (to skip them), built to /libgl1-mesa-dri.deb and /adwaita-icon-theme.deb
2. `FROM python:3.11-slim-bookworm` (runtime)

## Runtime build steps
- COPY dummy debs from builder; WORKDIR /app
- `dpkg -i` both dummy debs
- apt: `chromium chromium-common chromium-driver xvfb dumb-init procps curl vim xauth` (--no-install-recommends); rm apt lists
- rm `/usr/lib/x86_64-linux-gnu/libmfxhw*` and `/usr/lib/x86_64-linux-gnu/mfx/*` (hardware decoding libs)
- `useradd --home-dir /app --shell /bin/sh flaresolverr`; `mv /usr/bin/chromedriver chromedriver` (into /app)
- `chown -R flaresolverr:flaresolverr .`; `mkdir /config` and chown
- `VOLUME /config`
- `COPY requirements.txt .`; `pip install -r requirements.txt`; rm /root/.cache
- `USER flaresolverr`
- `RUN mkdir -p "/app/.config/chromium/Crash Reports/pending"`
- `COPY src .`; `COPY package.json ../`

## Ports / entry
- EXPOSE 8191, EXPOSE 8192 (8192 purpose not stated in file)
- `ENTRYPOINT ["/usr/bin/dumb-init", "--"]`
- `CMD ["/usr/local/bin/python", "-u", "/app/flaresolverr.py"]`

## ENV / ARG
- None declared.

## User
- `flaresolverr` user, home /app, shell /bin/sh (created by useradd, no fixed UID in file)

## Other
- Test hint in comments: `xvfb-run -s "-screen 0 1600x1200x24" chromium --no-sandbox`; error "stack smashing detected" noted.
- Local build comments reference `ngosang/flaresolverr:3.5.2`; multi-arch build for linux/386, amd64, arm/v7, arm64/v8 (comment only).

## Gotchas
- Chromium and chromedriver come from Debian bookworm apt; Debian-specific.
- Python 3.11 base in upstream.
