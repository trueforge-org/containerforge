# Upstream Dockerfile and nginx.conf: alam00000/bentopdf (v2.8.12)

**Source URL(s):** https://raw.githubusercontent.com/alam00000/bentopdf/v2.8.12/Dockerfile; https://raw.githubusercontent.com/alam00000/bentopdf/v2.8.12/nginx.conf (blob URL in urls.txt is the same file; fetched 2026-11-27)

## Build stage
- `FROM mirror.gcr.io/library/node:26-alpine AS builder`, `WORKDIR /app`.
- `COPY package*.json`, `COPY vendor ./vendor`, `ENV HUSKY=0`; npm fetch retries/timeouts configured; `npm ci`.
- `COPY . .`
- Build args (ENV-mapped): `SIMPLE_MODE=false`, `DISABLE_GITHUB_STARS=false`, `COMPRESSION_MODE=o`, `BASE_URL` (default empty), `VITE_WASM_PYMUPDF_URL`, `VITE_WASM_GS_URL`, `VITE_WASM_CPDF_URL`, `VITE_TESSERACT_WORKER_URL`, `VITE_TESSERACT_CORE_URL`, `VITE_TESSERACT_LANG_URL`, `VITE_TESSERACT_AVAILABLE_LANGUAGES`, `VITE_OCR_FONT_BASE_URL`, `VITE_DEFAULT_LANGUAGE`, `VITE_BRAND_NAME`, `VITE_BRAND_LOGO`, `VITE_FOOTER_TEXT`, `DISABLE_TOOLS`, `SITE_URL=https://www.bentopdf.com`, `ALLOW_INDEXING=false`.
- `ENV NODE_OPTIONS="--max-old-space-size=3072"`.
- `RUN` with secrets `VITE_CORS_PROXY_URL`, `VITE_CORS_PROXY_SECRET` (optional) then `npm run build:with-docs`.

## Final stage
- `FROM quay.io/nginx/nginx-unprivileged:alpine-slim`
- LABEL `org.opencontainers.image.source=https://github.com/alam00000/bentopdf`.
- `ARG BASE_URL`; `ENV DISABLE_IPV6=false`, `ENV PORT=8080`.
- `USER root`; `RUN apk upgrade --no-cache`; `USER nginx`.
- COPY `/app/dist` -> `/usr/share/nginx/html${BASE_URL%/}` (chown nginx).
- COPY `nginx.conf` -> `/etc/nginx/nginx.conf`; `security-headers.conf`, `security-headers-docs.conf` from builder -> `/etc/nginx/`.
- COPY `nginx-ipv6.sh` -> `/docker-entrypoint.d/99-disable-ipv6.sh`; `nginx-noindex.sh` -> `/docker-entrypoint.d/98-noindex.sh` (chmod 755).
- `RUN mkdir -p /etc/nginx/tmp && chown -R nginx:nginx /etc/nginx/tmp`
- `EXPOSE 8080`, `CMD ["nginx", "-g", "daemon off;"]`

## nginx.conf (full, key points)
- `pid /etc/nginx/tmp/nginx.pid;` ; `worker_connections 1024`.
- `gzip_static on; gzip on;` with types list.
- server `listen 8080; listen [::]:8080; server_name localhost; root /usr/share/nginx/html; index index.html; absolute_redirect off;`
- includes `/etc/nginx/security-headers.conf` and `/etc/nginx/tmp/noindex*.conf` (server level; docs location uses `security-headers-docs.conf`).
- Many 301 redirect rules (legacy paths, locale prefixes, `/tools/*`, `/docs/*.html`).
- `error_page 404 /404.html`; SPA-style `try_files $uri $uri.html $uri/index.html =404` (not index.html fallback for `/`).
- Docs: `location = /docs` and `^~ /docs/` fall back to `/docs/index.html`.
- No `client_body_temp_path` / `proxy_temp_path` etc. set in the file (nginx defaults under `/var/cache/nginx` apply).

## Env vars
| Var | Scope | Note |
| --- | --- | --- |
| PORT | image ENV 8080 | not read by nginx.conf |
| DISABLE_IPV6 | image ENV false | read by `nginx-ipv6.sh` (script not fetched) |
| BASE_URL, SIMPLE_MODE, SITE_URL, ALLOW_INDEXING, DISABLE_TOOLS, DISABLE_GITHUB_STARS, COMPRESSION_MODE, VITE_* | build args | build-time only |

## Ports
- 8080 (nginx listen, EXPOSE)

## Volumes/paths
- Static files: `/usr/share/nginx/html`. nginx pid: `/etc/nginx/tmp/nginx.pid`. No VOLUME.

## User/UID
- `nginx` user (unprivileged base image); `USER nginx` set.

## Gotchas
- Final stage needs `/etc/nginx/tmp` writable.
