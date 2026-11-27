# linuxserver/docker-calibre README (master)

Source URL(s) + date: https://raw.githubusercontent.com/linuxserver/docker-calibre/master/README.md (fetched 2026-11-27)

## What it is
- Calibre e-book manager, GUI streamed via Selkies base over HTTPS.

## Ports
| Port | Use |
| --- | --- |
| 8080 | Calibre desktop GUI HTTP (reverse-proxy use only) |
| 8181 | Calibre desktop GUI HTTPS (direct access; self-signed cert) |
| 8081 | Calibre built-in webserver (must be enabled in Calibre Preferences > Sharing over the net; keep port 8081) |

## Env vars
| Var | Purpose |
| --- | --- |
| PUID / PGID | UserID / GroupID (example 1000) |
| TZ | timezone |
| PASSWORD | optional GUI password (HTTP basic auth) |
| CLI_ARGS | optional CLI start args passed to calibre |
| UMASK | optional umask |
| FILE__<VAR> | read var from file |
| LC_ALL | session language |
| AUTO_GPU | set `false` to disable GPU auto-config |
| SELKIES_* | full stream/UI settings in Selkies docs |

## Volumes/paths
- `/config`: "Where calibre should store its database and library."
- Wizard: use default library location `/config/Calibre Library` (support not given otherwise).

## Runtime
- `--shm-size=1gb` in examples; `--security-opt seccomp=unconfined` optional for Docker Engine.
- `--device /dev/dri` optional (Intel vaapi). Nvidia path per Selkies docs.

## Security
- No auth by default. Web terminal has passwordless sudo. HTTPS required (WebCodecs).

## Healthcheck
- Not documented.
