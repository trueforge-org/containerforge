# grafana-image-renderer Dockerfile (pinned commit)

Source URL: https://github.com/grafana/grafana-image-renderer/blob/76ca73f6e1f00b46ee91524bbd91718545ea5943/Dockerfile
Fetched via: https://raw.githubusercontent.com/grafana/grafana-image-renderer/76ca73f6e1f00b46ee91524bbd91718545ea5943/Dockerfile
Date fetched: 2026-11-26

## What it is
Two-stage build. Stage 1 builds a static Go binary. Stage 2 is a Debian runtime with Chromium.

## Stages
| Stage | Base (pinned digest) | Notes |
| --- | --- | --- |
| app | golang:1.26.11-alpine@sha256:ae52b5bc6ed045a9ed26ab03dc19327a802a9cc9aa8b27ed57f5c6b60579b0bb | `apk add git`; `CGO_ENABLED=0 go build -o grafana-image-renderer -buildvcs -ldflags '-s -w -extldflags "-static"' .` |
| output_image | debian:trixie-20261104@sha256:9c6e381421d0f48d1b8133e573f33c185ee16cbf505eda9c4a8a4791b25ea8a6 | runtime |

## Build steps and deps (output_image)
- ARG `CHROMIUM_VERSION=156.0.8078.79` (renovate depName=chromium)
- `apt-get update && apt-get upgrade -y`, with a cachebuster echo line dated 2026-11-10
- apt install: fonts-ipaexfont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-khmeros fonts-kacst-one fonts-freefont-ttf libxss1 unifont fonts-open-sans fonts-roboto fonts-inter fonts-recommended bash util-linux openssl tini ca-certificates locales libnss3-tools
- `apt-get satisfy`: chromium, chromium-driver, chromium-shell, chromium-sandbox all `>=${CHROMIUM_VERSION}`
- Removes `-dev`/`-headers` packages, autoremove, apt clean
- Locale: en_US.UTF-8 generated; `fc-cache -fr`; `update-ca-certificates --fresh`

## Runtime
| Item | Value |
| --- | --- |
| Binary | /usr/bin/grafana-image-renderer (copied from app stage) |
| ENV | CHROME_BIN=/usr/bin/chromium, LANG=en_US.UTF-8, LC_ALL=en_US.UTF-8 |
| ENTRYPOINT | `["tini", "--", "/usr/bin/grafana-image-renderer"]` |
| CMD | `["server"]` |
| WORKDIR | /home/nonroot |

## Entrypoint/flags
- `server` runs the HTTP service. `healthcheck` subcommand is used by HEALTHCHECK.

## Ports
- EXPOSE 8081

## Volumes/paths
- No VOLUME. `/home/nonroot` is owned by group 0 with g=u (writable by root group).

## User/UID
- USER 65532 (user `nonroot`, group `nonroot`, created with --system)

## Healthcheck
- `--interval=10s --retries=3 --timeout=3s --start-interval=250ms --start-period=30s`
- CMD `["/usr/bin/grafana-image-renderer", "healthcheck"]`

## Version/asset naming
- Chromium pin: CHROMIUM_VERSION ARG (apt-based, not a download).
- Go builder: golang 1.26.11 alpine (digest pinned).

## Arch
- Not restricted in Dockerfile. Static Go binary, Debian packages.

## Gotchas
- Chromium version comes from Debian repos via `apt-get satisfy` with a minimum version, so the apt index must provide it.
- Cachebuster line must be bumped manually to refresh chromium packages.
- Runs as UID 65532, not root.
