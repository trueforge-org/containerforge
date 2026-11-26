# Dockerfile (outline @ f1f5fd364842916af8c4996c75ee3bed3b30aad4)

Source URL: https://github.com/outline/outline/blob/f1f5fd364842916af8c4996c75ee3bed3b30aad4/Dockerfile (fetched via raw.githubusercontent.com, pinned commit)

## Build args
| Arg | Default |
| --- | --- |
| APP_PATH | /opt/outline |
| BASE_IMAGE | outlinewiki/outline-base |

## Stages
- `base`: FROM ${BASE_IMAGE}; WORKDIR ${APP_PATH}. No build commands; used only as artifact source.
- `runner`: FROM node:26.13.1-slim

## runner stage
- LABEL org.opencontainers.image.source = outline GitHub repo
- WORKDIR $APP_PATH
- ENV NODE_ENV=production, MALLOC_ARENA_MAX=2, FILE_STORAGE_LOCAL_ROOT_DIR=/var/lib/outline/data
- groupadd nodejs gid 1001; useradd nodejs uid 1001
- mkdir /var/lib/outline; chown nodejs:nodejs on it and $APP_PATH
- COPY --from=base (chown nodejs:nodejs): build, server, public, .sequelizerc, node_modules, package.json
- apt-get update && install wget (used by healthcheck); clear apt lists
- mkdir file storage dir; chown nodejs; chmod 1777
- VOLUME /var/lib/outline/data
- USER nodejs
- EXPOSE 3000
- HEALTHCHECK every 1m: wget http://localhost:${PORT:-3000}/_health, grep "OK", exit 1 on failure
- CMD ["node", "build/server/index.js"]
- No ENTRYPOINT

## Runtime deps
- Node.js 26 (node:26.13.1-slim); wget (apt); node_modules pre-built in base image.

## Gotchas
- Base image outlinewiki/outline-base must exist for the requested tag (BASE_IMAGE arg).
- Dockerfile itself installs no build toolchain; all compilation happens in the base image.
