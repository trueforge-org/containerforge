# Upstream Dockerfile: calibrain/shelfmark

Sources:
- Pinned commit 0d97110f0132d78147213d11902298c516c32f16: https://raw.githubusercontent.com/calibrain/shelfmark/0d97110f0132d78147213d11902298c516c32f16/Dockerfile (fetched 2026-11-27)
- main: https://raw.githubusercontent.com/calibrain/shelfmark/main/Dockerfile (fetched 2026-11-27; key lines only compared)

## Pinned commit (0d97110) stages
| Stage | Base | Notes |
| --- | --- | --- |
| frontend-builder | `node:24-alpine@sha256:ebfe2f9...` (platform BUILDPLATFORM) | `COPY src/frontend/package*.json`; `npm ci`; `COPY src/frontend/`; `npm run build` |
| uv | `ghcr.io/astral-sh/uv:0.13.7@sha256:96f40d...` | mounted into RUNs, not copied |
| base | `python:3.14.9-slim@sha256:35caba...` | apt: locales tzdata curl dumb-init zip iputils-ping gosu tor supervisor iptables wireguard-tools iproute2 procps ca-certificates; iptables-legacy alternatives; user `shelfmark` UID/GID 1000 (home /home/shelfmark); `uv sync --locked --no-default-groups`; removes system pip |
| shelfmark (full) | base | Chromium, xvfb, python3-tk, unrar-free; `uv sync --extra browser`; python-xlib 0.33 forced; chown seleniumbase drivers; `COPY . .`; `COPY --from=frontend-builder /frontend/dist /app/frontend-dist`; `rm -rf /app/src`; creates /config /books /var/log/shelfmark /tmp/shelfmark/seleniumbase/...; chown 1000:1000 |
| shelfmark-lite | base | `USING_EXTERNAL_BYPASSER=true`; no browser stack |

## Runtime (base stage)
- `ENV`: DEBIAN_FRONTEND=noninteractive, DOCKERMODE=true, UV_LINK_MODE=copy, PYTHONUNBUFFERED=1, PYTHONDONTWRITEBYTECODE=1, PYTHONIOENCODING=UTF-8, NAME=Shelfmark, PATH=/app/.venv/bin:$PATH, PYTHONPATH=/app, LANG/LANGUAGE/LC_ALL=en_US.UTF-8.
- `ENV FLASK_PORT=8084`.
- `WORKDIR /app`.
- `EXPOSE ${FLASK_PORT}`.
- `HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --start-interval=5s --retries=3 CMD curl -fsS http://localhost:${FLASK_PORT}/api/health`.
- `ENTRYPOINT ["/usr/bin/dumb-init", "--"]`.
- Final CMD: `["/app/entrypoint.sh"]` (both shelfmark and shelfmark-lite). No USER and no VOLUME in Dockerfile (upstream base runs as root and entrypoint drops privileges via PUID/PGID or gosu).
- `ARG BUILD_VERSION`, `ARG RELEASE_VERSION` exported as ENV.
- `chmod +x /app/entrypoint.sh /app/tor.sh /app/wireguard.sh /app/genDebug.sh`.

## Main vs pinned differences (key lines)
| Item | Pinned 0d97110 | main |
| --- | --- | --- |
| node frontend | node:24-alpine sha ebfe2f90... | node:24-alpine sha 116b800c... |
| uv | 0.13.7 | 0.13.9 |
| python base | 3.14.9-slim | 3.14.10-slim |
| EXPOSE / FLASK_PORT / healthcheck | 8084 | 8084 (same) |

## Gotchas
- Chromium stack: Debian chromium; SeleniumBase driver cache needs write by UID 1000.
- /app/src removed after build; frontend dist served from /app/frontend-dist.
