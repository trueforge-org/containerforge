# GitHub: pinry/pinry

## Source URL(s) + date
- https://api.github.com/repos/pinry/pinry/releases/latest
- https://raw.githubusercontent.com/pinry/pinry/a21b1e73c2f889499286339b8cc59c411e40b9b1/Dockerfile.autobuild
- Fetched 2026-11-27

## Latest release
- tag `v2.1.15`, name "v2.1.15 security release", published 2026-11-26T13:46:12Z.
- No release assets (source only).

## Upstream Dockerfile.autobuild (pinned commit a21b1e73c2f889499286339b8cc59c411e40b9b1)
### Stages
- `pnpm-build`: `FROM node:18-bookworm`, `WORKDIR pinry-spa`, `pnpm install`, `pnpm build`.
- `base`: `FROM python:3.9.12-slim-buster`; apt install gcc, default-libmysqlclient-dev (apt-utils on arm64/armhf); `pip install --user mysqlclient cx-Oracle`.
- final: `FROM python:3.9.12-slim-buster`, `WORKDIR pinry`.

### Final stage
- `mkdir /data && chown -R www-data:www-data /data`.
- UID/GID remap: `www-data` set to UID 1000 / GID 1000 (via groupadd/usermod).
- apt: nginx, pwgen, libopenjp2-7, libjpeg-turbo-progs, libjpeg62-turbo-dev, libtiff5-dev, libxcb1; apt-utils, libpq-dev, gcc on arm64/armhf.
- `pip install "rcssmin==1.0.6" --install-option="--without-c-extensions"`; `pip install -r requirements.txt`.
- COPY: `pinry-spa` package files, `requirements.txt`, `pinry-spa/dist` from pnpm-build to `/pinry/pinry-spa/dist`, `/root/.local` from base, `. .`.
- ADD `docker/nginx/nginx.conf` to `/etc/nginx/nginx.conf`; `docker/nginx/sites-enabled/default` to `/etc/nginx/sites-enabled/default`.
- `ENV PATH=/root/.local/bin:$PATH`, `ENV DJANGO_SETTINGS_MODULE pinry.settings.docker`.
- `EXPOSE 80`; `VOLUME ["/data"]`; no USER (runs as root); no ENTRYPOINT.
- `CMD ["/pinry/docker/scripts/start.sh"]` (script contents not fetched).

## Gotchas
- Upstream pins Python 3.9.12 (slim-buster, EOL) and node 18.
- nginx serves static files on port 80 in the upstream image.
- Secret key env name not in Dockerfile; comes from start script/settings (not fetched).
- Dockerfile at a fixed commit; release v2.1.15 has no assets.
