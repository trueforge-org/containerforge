# linuxserver/docker-audacity README (master)

Source URL(s) + date: https://raw.githubusercontent.com/linuxserver/docker-audacity/master/README.md (fetched 2026-11-27)

## What it is
- Audacity: easy-to-use multi-track audio editor and recorder (open source, volunteer-developed).
- Image is built on Docker Baseimage Selkies: streams the desktop to a browser (HTTPS).

## Ports
- `3001` HTTPS web UI (self-signed cert by default). Example: `-p 3001:3001`, open `https://localhost:3001`.
- Port 3001 serves HTTPS directly; HTTP port exists only for reverse proxy use.

## Env vars (named in README)
| Var | Purpose |
| --- | --- |
| CUSTOM_USER / PASSWORD | enable HTTP basic auth (no auth by default) |
| LC_ALL | session language, e.g. `ja_JP.UTF-8` |
| AUTO_GPU | set `false` to disable GPU auto-config |
| PUID / PGID | user / group mapping (README intro) |
| SELKIES_* | full stream/UI settings in Selkies docs (not expanded here) |

## Run requirements
- `--shm-size=1gb` in examples.
- Optional GPU: `--device /dev/dri`; NVIDIA needs host driver 580+ (595.80+ noted for some setups).

## Volumes/paths
- `/config` (Dockerfile VOLUME); README does not document a path inside it.

## Healthcheck
- Not documented.

## Gotchas
- Default: no authentication; the web terminal has passwordless sudo. README warns to put behind a reverse proxy for internet use.
- README links Selkies docs for full configuration.
