# Upstream README: almarklein/timetagger

Source URL(s) + date: https://raw.githubusercontent.com/almarklein/timetagger/master/README.md (fetched 2026-11-27)

## What it is
- TimeTagger: web-based time tracker (individuals/freelancers). Python server (uvicorn + asgineer), SQLite via itemdb, client written in Python compiled with PScript.
- License GPL-3.0. Contributions require CLA (CLA.md).

## Install / run
- `pip install -U timetagger`; `python -m timetagger` (single-user mode on localhost).
- Docker images: GitHub Container Registry (ghcr.io/almarklein/timetagger). Two variants: root image, and nonroot variant running as UID 1000.
- Example compose files: deploy/docker-compose.yml and deploy/docker-compose.nonroot.yml.

## Runtime deps
- Python 3.6+ (per README); uvicorn, uvloop, httptools optional (speed).
- SQLite (bundled in itemdb).

## Entrypoint/flags
- `python -m timetagger`
- CLI: `--credentials=<user>:<bcrypt hash>`, `--proxy_auth_enabled`, `--proxy_auth_trusted`, `--proxy_auth_header`.

## Env vars
| Env | Purpose |
| --- | --- |
| TIMETAGGER_CREDENTIALS | `<username>:<bcrypt hash>` for multi-user auth |
| TIMETAGGER_PROXY_AUTH_ENABLED | enable reverse-proxy header auth (e.g. True) |
| TIMETAGGER_PROXY_AUTH_TRUSTED | trusted proxy IP (e.g. 127.0.0.1) |
| TIMETAGGER_PROXY_AUTH_HEADER | header carrying username (e.g. X-Remote-User) |

Not documented in README: TIMETAGGER_BIND (used by chart).

## Ports
- Not stated in README (chart uses 10286).

## Volumes/paths
- Not stated in README (data stored in SQLite).

## Gotchas
- Credentials use BCrypt hash; generate via https://timetagger.app/cred.
- Hosted version at timetagger.app; sponsorship/subscription suggested.
