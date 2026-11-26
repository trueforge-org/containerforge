# Docker Hub: edgd1er/webnut

Source URL(s) + fetch date: https://hub.docker.com/r/edgd1er/webnut · fetched 2026-11-26

## What it is
- Dockerized webNUT (web UI for NUT UPS servers), maintained by edgd1er, based on teknologist's version. 100K+ pulls, 34.9 MB image. Build and publish actions in the repo.

## Architectures
- amd64, armv6, armv7, arm64.

## Run
- `docker run` with env vars set and port 6543 published (the example has a stray `-e` before the image name).
- Compose (version 3.5): image `edgd1er/webnut:latest`, `restart: always`, four variables, `6543:6543`.
- Pull: `docker pull edgd1er/webnut`.

## Env vars (defaults)
| Name | Default | Notes |
| --- | --- | --- |
| `UPS_HOST` | 127.0.0.1 | NUT server host |
| `UPS_PORT` | 3493 | NUT server port |
| `UPS_USER` | monuser | NUT username |
| `UPS_PASSWORD` | secret | NUT password |

## Ports
- 6543 (container).

## Volumes
- None documented on the page (the Dockerfile declares `/config`).

## Version/release info
- Only `latest` tag shown (digest `sha256:bb41f38d...`), last updated about 7 months before capture.

## Gotchas
- The wrapper default password `secret` is a weak default. plan.md drops it (empty means no auth).
