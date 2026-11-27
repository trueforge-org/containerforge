# PhotoStructure for Docker docs

**Source URL(s):** https://photostructure.com/server/photostructure-for-docker (main, 2 chunks) · fetched 2026-11-27

## What it is
Reference for running PhotoStructure in Docker (linux/amd64 and linux/arm64). Recommends the Docker Compose Wizard on the site.

## Requirements
- At least 2GB RAM during imports (1GB gives ENOMEM).
- x64 image needs SSE4/AVX CPU.
- arm64 runs on Raspberry Pi 4+.

## Run (minimal)
```
docker run --name photostructure --restart unless-stopped --publish 1787:1787 \
  -e PUID=$(id -u) -e PGID=$(id -g) -e TZ=UTC \
  -v /path/to/library:/ps/library photostructure/server:stable
```

## Ports
- 1787 (web UI; /welcome/tools to reset codec consent)

## Volumes/paths
| path | purpose | required |
| --- | --- | --- |
| /ps/library | library DB and previews; must be RW | yes |
| /ps/originals | originals (PLUS: copy-to-library target) | no |
| /ps/tmp | local cache, 16-32 GB, must be local disk | only if library is network |
| /ps/logs | logs (auto-pruned after 1 week) | no |
| /ps/config | system settings, codec consent, FFmpeg install | no |
| /ps/host/machine-id | ro host machine-id (license ID) | no |
| /ps/no-import | mounts below this are not imported | no |
| /photos (any) | extra import dirs, use `:ro` | no |

Fallbacks: missing /ps/tmp -> /ps/library/.photostructure/cache; missing /ps/logs -> .../logs; config -> PS_CONFIG_DIR, else /ps/config, else /ps/library/.photostructure/docker-config.

## Env vars (documented)
| var | note |
| --- | --- |
| PUID / PGID | non-root IDs; unset -> derived, missing/root paths -> 0 |
| PS_LIBRARY_DIR | library path inside container (aliases PS_LIBRARY_PATH, PS_LIBRARY) |
| PS_CONFIG_DIR | system settings dir |
| PS_LOG_LEVEL | default `error` in TrueCharts; info/debug |
| PS_HTTP_PORT | web port (Dockerfile healthcheck uses it) |
| PIXI_HOME | relocate pixi/ffmpeg install |
| TZ | timezone |

## User/UID
- Single user `photostructure`; entrypoint sets its uid/gid to PUID/PGID. Older images used `node`.
- Root allowed by setting PUID=0 PGID=0.

## Install/runtime deps
- FFmpeg (via conda-forge with pixi) fetched on first run after consent, ~700 MB under `pixi/linux-<arch>` in config dir. Not bundled.
- Works with no-new-privileges (TrueNAS SCALE).

## Gotchas
- Mounted imports should be read-only only with a manually created `.uuid` file.
- Do not bind-mount over /etc, /bin, /opt, /usr.
- /ps/library and /ps/originals must be writable.
- Docker Desktop: reduced I/O; omit machine-id mount there.
