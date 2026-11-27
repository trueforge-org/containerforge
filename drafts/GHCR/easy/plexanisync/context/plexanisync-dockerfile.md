# RickDB PlexAniSync Dockerfile (v1.4.4)

## Source URL(s) + date
- https://raw.githubusercontent.com/RickDB/PlexAniSync/v1.4.4/Docker/PlexAniSync/Dockerfile (fetched 2026-11-27)
- Also referenced: https://github.com/RickDB/PlexAniSync/blob/v1.4.4/Docker/PlexAniSync/Dockerfile (same content, not fetched separately)

## Build steps
- Stage 1 `FROM python:3.12 AS builder`: apt install `build-essential`, `apt-get clean`, `rm -rf /var/lib/apt/lists/*`; `pip install --upgrade pip`; `COPY Docker/PlexAniSync/pip.conf /etc/pip.conf`; `COPY requirements.txt .`; `pip install --user --no-warn-script-location -r requirements.txt`
- Stage 2 `FROM python:3.12-slim`: `WORKDIR /plexanisync`; `COPY --from=builder /root/.local /root/.local`; `chmod -R a+rX /root`
- Copies: `PlexAniSync.py requirements.txt custom_mappings_schema.json Docker/PlexAniSync/run/.` to `/plexanisync/`; `plexanisync/` dir to `/plexanisync/plexanisync`
- Build deps: Python 3.12 (no digest pin in Dockerfile), pip.conf, requirements.txt

## Runtime
- `ENV PATH=/root/.local:$PATH`, `PYTHONPATH=/root/.local/lib/python3.12/site-packages`
- `CMD ["/plexanisync/runsync.sh"]`
- LABEL documentation: https://github.com/RickDB/PlexAniSync/blob/master/Docker/PlexAniSync/README.md

## Env (Dockerfile defaults)
| Name | Default |
| --- | --- |
| PLEX_SECTION | Anime |
| PLEX_URL | http://127.0.0.1:32400 |
| PLEX_TOKEN | '' |
| ANI_USERNAME | '' |
| ANI_TOKEN | '' |
| INTERVAL | 3600 |

## User/UID
- No USER directive: runs as root (image default). Builder writes under /root/.local.

## Ports / Healthcheck
- None exposed, no HEALTHCHECK.

## Volumes/paths
- Workdir /plexanisync; settings at /plexanisync/settings.ini; custom mappings /plexanisync/custom_mappings.yaml (docs mount)

## Gotchas
- Python dependencies are installed under `/root/.local` (root home), not a non-root user home.
- Python 3.12 base tags are unpinned (floating).
