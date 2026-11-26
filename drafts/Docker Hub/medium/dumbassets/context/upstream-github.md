# DumbWareio/DumbAssets (upstream, GitHub)

## Source URL(s) + date
- https://raw.githubusercontent.com/DumbWareio/DumbAssets/2bacca1e2c4ff8e60d562c8dc300a8dbe91083c3/Dockerfile (fetched 2026-11-26)
- https://raw.githubusercontent.com/DumbWareio/DumbAssets/2bacca1e2c4ff8e60d562c8dc300a8dbe91083c3/README.md
- https://api.github.com/repos/DumbWareio/DumbAssets/releases/latest

## What it is
Self-hosted asset tracker: Node.js web app with JSON data files, PIN auth, optional Apprise notifications (Apprise is a Python tool).

## Install/build steps (upstream Dockerfile)
- `FROM node:20-alpine`, `WORKDIR /app`
- `COPY package*.json ./`, `RUN npm ci`
- `RUN apk add --no-cache python3 py3-pip && python3 -m venv /opt/venv && rm -rf /var/cache/apk/*`
- `RUN . /opt/venv/bin/activate && pip install --no-cache-dir apprise && find /opt/venv -name __pycache__ -exec rm -r {} +`
- `ENV PATH="/opt/venv/bin:$PATH"`
- `COPY . .`, `RUN mkdir -p data`

## Runtime deps
- Node 20 (alpine upstream), npm packages from package-lock.json, Python 3 + `apprise` (pip, in `/opt/venv`).

## Entrypoint/flags
- No ENTRYPOINT. `CMD ["npm", "start"]`.

## Env vars (README table, plus plan-listed code reads)
| Variable | Default | Description |
| --- | --- | --- |
| PORT | 3000 | Server port |
| DUMBASSETS_PIN | None | PIN protection (4+ digits) |
| APPRISE_URL | None | Apprise URL for notifications |
| TZ | America/Chicago | Container timezone |
| BASE_URL | http://localhost | Base URL for the app |
| SITE_TITLE | DumbAssets | Browser tab and header title |
| ALLOWED_ORIGINS | '*' | Origins allowed (README; code read not verified here) |
| DEMO_MODE | false | Read-only mode |
| CURRENCY_CODE | USD | ISO 4217 code |
| CURRENCY_LOCALE | en-US | Locale for currency formatting |

Also in README compose example: NODE_ENV (default production in compose example, `${DUMBASSETS_NODE_ENV:-production}`).

## Ports
- 3000 (`EXPOSE 3000`). Compose example maps `${DUMBASSETS_PORT:-3000}:3000`.

## Volumes/paths
- `/app/data` (README run: `-v ./data:/app/data`). Dockerfile `RUN mkdir -p data` in `/app`.
- Compose example: `${DUMBASSETS_DATA_PATH:-./data}:/app/data`.

## User/UID
- Upstream: root (no USER).

## Config files
- None documented beyond env vars and data dir.

## Healthcheck
- None upstream.

## Version/asset naming
- Latest GitHub release (API): tag `v1.0.11`, name "v1.0.11 Quantities, Direct Links, Multi Currency, Events Filtering and More!", published 2025-06-12T20:57:47Z, **no release assets** (assets: []).
- Source tarball pattern: `https://github.com/DumbWareio/DumbAssets/archive/refs/tags/v<version>.tar.gz`.

## Docker Hub (dumbwareio/dumbassets:latest, tags API)
- amd64 and arm64 images, last pushed 2025-07-20T17:23:15Z.

## Arch
- Upstream image: amd64 and arm64 (Docker Hub).

## Gotchas
- Upstream Node 20 alpine; apprise installed into a venv in the image.
- Release has no binary/zip assets; use source tarball.
- Compose README example mounts `/app/data`.
