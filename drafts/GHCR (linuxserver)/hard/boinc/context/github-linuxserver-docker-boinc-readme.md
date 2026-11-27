# linuxserver/docker-boinc README (master)

Source URL(s) + date: https://raw.githubusercontent.com/linuxserver/docker-boinc/master/README.md (fetched 2026-11-27)

## What it is
- BOINC: platform for volunteer and grid computing; desktop GUI served via Selkies (HTTPS on 8181).

## Ports
| Port | Use |
| --- | --- |
| 8080 | GUI HTTP (reverse-proxy use only) |
| 8181 | GUI HTTPS (direct access; self-signed cert) |

## Env vars
| Var | Purpose |
| --- | --- |
| PUID / PGID | UserID / GroupID (example 1000) |
| TZ | timezone (example Etc/UTC) |
| PASSWORD | optional GUI password; enables HTTP basic auth (CUSTOM_USER also named) |
| FILE__<VAR> | read var from file (Docker secrets) |
| UMASK | optional umask |
| AUTO_GPU | set `false` to disable GPU auto-config |
| LC_ALL | session language |
| SELKIES_* | full stream/UI settings in Selkies docs |

## Volumes/paths
- `/config`: "Where BOINC should store its database and config."

## Devices/runtime
- `--device /dev/dri` optional (Intel vaapi). Nvidia: nvidia-container-toolkit, `--runtime=nvidia`, `NVIDIA_VISIBLE_DEVICES=all`. Driver 580+ noted.
- `--shm-size=1gb` in examples.

## Security
- No auth by default. Web terminal has passwordless sudo. Use reverse proxy for internet exposure.
- HTTPS required (WebCodecs).

## Healthcheck
- Not documented.

## Versions (README log, latest entries)
- 03.04.23: rebase to KasmVNC base; add bzip2 and xz-utils.
- 23.03.21: rebase to rdesktop-web; `GUAC_USER`/`GUAC_PASS` deprecated, use `PASSWORD`.
