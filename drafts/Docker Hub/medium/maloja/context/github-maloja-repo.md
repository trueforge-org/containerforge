# GitHub: krateng/maloja (repo)

Source URL(s), fetched 2026-11-27:
- https://github.com/krateng/maloja

## What it is
- Self-hosted scrobble database for personal listening stats and charts. No social, radio or recommendation features.
- Status: security updates only; author building successor maloja-rs.
- Language: Python. Distributed on PyPI as `malojaserver`; pyproject.toml and requirements.txt in repo.
- License: GPL-3.0.
- Latest release tag: not shown on page.

## Install
- Docker or Podman recommended; bare metal discouraged and unsupported (venv may help).
- Docker image: `krateng/maloja` on Docker Hub. Repo has Containerfile and example-compose.yml.
- Non-container run command: `maloja run`.

## Run (container)
- Minimal: `docker run -p 42010:42010 -v $PWD/malojadata:/mljdata -e MALOJA_DATA_DIRECTORY=/mljdata krateng/maloja`
- Linux user mapping: `-e PUID=<id -u> -e PGID=<id -g>` (not needed for rootless Podman).

## Env vars
- MALOJA_SKIP_SETUP: non-interactive setup; required in containers.
- MALOJA_FORCE_PASSWORD: admin password, first run only.
- MALOJA_DATA_DIRECTORY: config and data location inside container; mount a volume there.
- Any setting via `MALOJA_`-prefixed env var.

## Port / network
- Default port 42010 (publish to host). IPv4 by default; reverse proxy should match IPv4/IPv6 setting.

## Non-container paths
- Settings `/etc/maloja/settings.ini`; rules `/etc/maloja/rules` (`rules.info`); images `/var/lib/maloja/images` (`images.info`).
- API keys: `apikeys.yml` in config folder or web UI.
- Import folder inside data directory. Imports: Last.fm, Spotify, ListenBrainz, Maloja export.

## Web pages / API
- /admin_setup, /admin_manual (manual scrobble), /api_explorer. Details in API.md.
- Image fetching needs free Last.fm and Spotify API keys.
- Reverse proxy recommended for SSL.
