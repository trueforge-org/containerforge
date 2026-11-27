# linuxserver/docker-pixapop README (master)

Source URL(s) + date: https://raw.githubusercontent.com/linuxserver/docker-pixapop/master/README.md (fetched 2026-11-27)

## DEPRECATION
- "This image is deprecated. We will not offer support for this image and it will not be updated."
- Version history: 14.10.22 deprecate; 17.12.20 move to main linuxserver repo; 18.03.19 build deps updated.

## What it is
- "Pixapop is an open-source single page application to view your photos in the easiest way possible." Upstream: github.com/bierdok/pixapop.

## Architectures (README table)
| Arch | Tag prefix |
| --- | --- |
| x86-64 | amd64-<version> |
| arm64 | arm64v8-<version> |
| armhf | arm32v7-<version> |

## Environment variables
| Var | Purpose |
| --- | --- |
| PUID | UserID (example 1000) |
| PGID | GroupID (example 1000) |
| TZ | timezone (example Europe/London) |
| APP_USERNAME | optional; enables authentication |
| APP_PASSWORD | optional; password for authentication |
| UMASK | optional umask override |
| FILE__<VAR> | read env var value from file (Docker secrets) |

## Ports
- `80` (WebUI), example `80:80`.

## Volumes/paths
- `/config`: config and logs (nginx base). Settings persist here.
- `/photos`: photo folder; photos shown as galleries split by month.

## User/UID
- PUID/PGID mapping via linuxserver s6 base (default example 1000:1000).

## Healthcheck
- Not documented in README.

## Gotchas
- Image on lscr.io/linuxserver/pixapop; build example uses `docker build -t lscr.io/linuxserver/pixapop:latest .`.
- Docker Mods exist for this image (mod name `pixapop`) per README badges.
