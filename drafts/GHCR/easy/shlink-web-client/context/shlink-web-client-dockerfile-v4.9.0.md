# shlink-web-client upstream Dockerfile (v4.9.0) - low confidence

## Source URL(s) + date
- https://raw.githubusercontent.com/shlinkio/shlink-web-client/v4.9.0/Dockerfile (from blob URL in urls.txt)
- Fetched 2026-11-27

## Reported facts
- `FROM node:26.12-alpine AS node` (stage alias `node`)
- `FROM nginxinc/nginx-unprivileged:1.31.7-alpine`
- ARG `VERSION="latest"` (stage 1); ARG `UID=101` (final)
- USER root (setup), then USER `$UID`
- No EXPOSE, ENTRYPOINT, CMD, HEALTHCHECK declared; base entrypoint runs `/docker-entrypoint.d/*`

## Confidence
- The fetch summary disagreed with the 4.9.1 Dockerfile on the base image path (`nginxinc/nginx-unprivileged:1.31.7` vs `nginx/nginx-unprivileged:1.31`) and node minor (26.12 vs 26.13). Treat as unverified; re-check the raw file before relying on it.
