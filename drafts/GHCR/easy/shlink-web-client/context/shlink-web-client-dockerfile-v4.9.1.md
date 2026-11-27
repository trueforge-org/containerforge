# shlink-web-client upstream Dockerfile (v4.9.1)

## Source URL(s) + date
- https://raw.githubusercontent.com/shlinkio/shlink-web-client/v4.9.1/Dockerfile (from blob URL in urls.txt)
- Fetched 2026-11-27

## Stages
- `FROM node:26.13-alpine AS node`: `RUN cd /shlink-web-client && npm ci && node --run build`
- `FROM nginx/nginx-unprivileged:1.31-alpine` (final)

## ARG / ENV
- stage 1: `ARG VERSION="latest"`, `ENV VERSION=${VERSION}`
- final: `ARG UID=101`

## Steps
- `COPY . /shlink-web-client` (build stage)
- final: `USER root`; `rm -r /usr/share/nginx/html && rm /etc/nginx/conf.d/default.conf`
- `COPY --from=node /shlink-web-client/build /usr/share/nginx/html`
- `COPY config/docker/nginx.conf /etc/nginx/conf.d/default.conf`
- `COPY scripts/docker/servers_from_env.sh /docker-entrypoint.d/30-shlink-servers-json.sh`
- `RUN echo '[]' > /usr/share/nginx/html/servers.json && chown $UID:0 /usr/share/nginx/html/servers.json`
- `USER $UID` (101)

## Runtime
- Entrypoint/CMD inherited from nginx base (`/docker-entrypoint.d/*` scripts run first).
- No EXPOSE, VOLUME, HEALTHCHECK, WORKDIR, ENTRYPOINT, CMD declared.

## Gotchas
- Upstream writes servers.json into the web root (`/usr/share/nginx/html`).
