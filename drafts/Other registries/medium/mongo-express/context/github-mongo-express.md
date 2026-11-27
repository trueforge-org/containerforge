# mongo-express/mongo-express v1.1.0-rc-4 (Dockerfile + README env reference)

## Source URL(s) + date
- https://raw.githubusercontent.com/mongo-express/mongo-express/v1.1.0-rc-4/Dockerfile (fetched 2026-11-27)
- https://raw.githubusercontent.com/mongo-express/mongo-express/v1.1.0-rc-4/README.md (fetched 2026-11-27)
- https://github.com/mongo-express/mongo-express/releases/tag/v1.1.0-rc-4 (alternative for failed API; fetched 2026-11-27, assets not loaded)

## Dockerfile (v1.1.0-rc-4)
- Stage build: `FROM node:18-alpine3.16`; `COPY . .`; `yarn install && yarn build && rm -rf lib/scripts`.
- Final: `FROM node:18-alpine3.16`.
- ENV: `ME_CONFIG_MONGODB_URL=mongodb://mongo:27017`, `ME_CONFIG_MONGODB_ENABLE_ADMIN=true`, `VCAP_APP_HOST=0.0.0.0`.
- WORKDIR `/opt/mongo-express`; copies build, public, lib, app.js, config.default.js, *.json, .yarn, yarn.lock, .yarnrc.yml, .npmignore.
- `apk add bash=5.1.16-r2 tini=0.19.0-r0`; `yarn workspaces focus --production`.
- `EXPOSE 8081`.
- `CMD ["/sbin/tini", "--", "yarn", "start"]`.
- No USER directive (runs as root by default).

## Env reference (README, selected)
| Env | Default | Note |
| --- | --- | --- |
| ME_CONFIG_MONGODB_URL | `mongodb://admin:pass@localhost:27017/db?ssl=false` | connection string (Dockerfile overrides default) |
| ME_CONFIG_MONGODB_ENABLE_ADMIN | false | "true"/"false" strings |
| ME_CONFIG_MONGODB_AUTH_USERNAME / _PASSWORD | admin / pass | only when ENABLE_ADMIN false |
| ME_CONFIG_MONGODB_TLS, _TLS_ALLOW_CERTS, _TLS_CA_FILE, _TLS_CERT_KEY_FILE | false, true, "", "" | TLS |
| ME_CONFIG_MONGODB_URL_FILE | "" | file version |
| ME_CONFIG_BASICAUTH_ENABLED | false | enables web basic auth |
| ME_CONFIG_BASICAUTH_USERNAME / _PASSWORD | "" (defaults admin / pass) | web login; `_FILE` variants exist |
| ME_CONFIG_OIDCAUTH_* | false / "" | OIDC auth options |
| ME_CONFIG_HEALTH_CHECK_PATH | /status | healthcheck path |
| ME_CONFIG_SITE_BASEURL | / | subdirectory mount |
| ME_CONFIG_SITE_COOKIESECRET / _SESSIONSECRET | cookiesecret / sessionsecret | set real values |
| ME_CONFIG_REQUEST_SIZE | 100kb | body size |
| ME_CONFIG_OPTIONS_READONLY, _NO_DELETE, _NO_EXPORT, _CONFIRM_DELETE | false | UI restrictions |
| ME_CONFIG_SITE_SSL_ENABLED / _SSL_CRT_PATH / _SSL_KEY_PATH | false | built-in SSL |
| ME_CONFIG_BASICAUTH (deprecated) | false | use _ENABLED |

- Listen port: `--port`/`-p`, default 8081.
- Docker example: `docker run -it --rm -p 8081:8081 --network some-network mongo-express` (needs MongoDB reachable as `mongo`).

## Release
- Tag v1.1.0-rc-4 is a pre-release (npm `latest` dist-tag currently points at this version; see npm-mongo-express.md).

## Failures
- https://api.github.com/repos/mongo-express/mongo-express/releases/tags/v1.1.0-rc-4: 403 rate limit. Alternative HTML release page fetched; no asset list rendered (JS "Loading").

## Gotchas
- Dockerfile sets Node 18 alpine 3.16 base; pinned apk package versions.
