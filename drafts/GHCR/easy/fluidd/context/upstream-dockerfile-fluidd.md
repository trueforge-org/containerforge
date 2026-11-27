# Upstream Dockerfile and nginx template: fluidd

Source URL(s):
- https://raw.githubusercontent.com/fluidd-core/fluidd/8823798fbd0e8dda5e1353b6beabef6024940717/Dockerfile (fetched 2026-11-27; pinned commit, same content as the blob URL)
- https://raw.githubusercontent.com/fluidd-core/fluidd/master/server/nginx/default.conf.template (fetched 2026-11-27)

## What it is
- Upstream image: nginx serving the built dist. Dockerfile copies static files, no compile step.

## Build steps
```
ARG BASE_IMAGE=nginx:alpine-slim
FROM $BASE_IMAGE
ARG PORT=80
ENV PORT=${PORT}
COPY /dist /usr/share/nginx/html
COPY /server/nginx /etc/nginx/templates
HEALTHCHECK --interval=10s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -q -O /dev/null -T 2 "http://127.0.0.1:${PORT}/healthz" || exit 1
```

## Runtime deps
- nginx (base image). Alpine-slim upstream (musl). `wget` used by the healthcheck.

## Entrypoint/flags
- No ENTRYPOINT or CMD in the Dockerfile; nginx base image entrypoint runs the template renderer.

## Env vars
| Name | Default | Note |
| --- | --- | --- |
| PORT | 80 | used by the nginx template (`listen ${PORT}`) and the healthcheck |

## Ports
- Listens on `${PORT}` (80) in IPv4 and IPv6, default_server.

## Volumes/paths
- Static root `/usr/share/nginx/html` (from `/dist`).
- Templates `/etc/nginx/templates` (from `/server/nginx`). Rendered into nginx conf by the base image.
- Logs: `/var/log/nginx/access.log`, `/var/log/nginx/error.log`.

## nginx template (default.conf.template)
- `root /usr/share/nginx/html; index index.html; server_name _;`
- `client_max_body_size 0; proxy_request_buffering off;`
- gzip on (text, css, js, json, xml types).
- `location / { try_files $uri $uri/ /index.html; }` (SPA fallback).
- `location = /index.html { Cache-Control "no-store, no-cache, must-revalidate" }`.
- `location = /healthz { return 200 "ok\n"; }`.

## User/UID
- Upstream: none set (runs as the nginx base user).

## Gotchas
- Upstream base is `nginx:alpine-slim` (musl). A glibc base is needed for ContainerForge.
- Healthcheck endpoint `/healthz` returns `ok`.
- `/healthz` returns 200 for any request, not a real application health check.
