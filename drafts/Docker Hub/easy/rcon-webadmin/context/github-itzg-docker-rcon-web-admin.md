# itzg/docker-rcon-web-admin (GitHub, Docker wrapper)

Source URL(s) + fetch date (2026-11-26):
- https://github.com/itzg/docker-rcon-web-admin/blob/484fba3/Dockerfile (fetched as raw at commit 484fba3)

## Dockerfile (upstream wrapper, commit 484fba3)
```
FROM node:12
ARG RCON_WEB_ADMIN_VERSION=0.14.1
ADD https://github.com/rcon-web-admin/rcon-web-admin/archive/${RCON_WEB_ADMIN_VERSION}.tar.gz /tmp/rcon-web-admin.tgz
RUN tar -C /opt -xf /tmp/rcon-web-admin.tgz && \
    rm /tmp/rcon-web-admin.tgz && \
    ln -s /opt/rcon-web-admin-${RCON_WEB_ADMIN_VERSION} /opt/rcon-web-admin
WORKDIR /opt/rcon-web-admin
RUN npm install && \
    node src/main.js install-core-widgets && \
    chmod 0755 -R startscripts *
# 4326: web UI
# 4327: websocket
EXPOSE 4326 4327
VOLUME ["/opt/rcon-web-admin/db"]
ENV RWA_ENV=TRUE
ENTRYPOINT ["/usr/local/bin/node", "src/main.js", "start"]
```

## Build/runtime facts
- Single stage, base `node:12` (EOL Node major; upstream choice).
- Version pinned by ARG `RCON_WEB_ADMIN_VERSION=0.14.1`; tarball downloaded with ADD from GitHub archive (direct download pattern: `archive/${RCON_WEB_ADMIN_VERSION}.tar.gz`, not an app-owned artifact). Extracted into `/opt`, symlinked to `/opt/rcon-web-admin`.
- No COPY, USER, HEALTHCHECK or CMD.
- ENV `RWA_ENV=TRUE` so env vars are read.
- Entry: `/usr/local/bin/node src/main.js start`.
- Volume: `/opt/rcon-web-admin/db`.
- Ports: 4326 (web UI), 4327 (websocket).
