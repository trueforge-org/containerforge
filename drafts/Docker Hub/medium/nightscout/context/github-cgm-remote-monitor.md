# GitHub: nightscout/cgm-remote-monitor (upstream)

## Source URL(s) + date
- https://raw.githubusercontent.com/nightscout/cgm-remote-monitor/master/Dockerfile (2026-11-26)
- https://raw.githubusercontent.com/nightscout/cgm-remote-monitor/master/README.md (2026-11-26)
- https://github.com/nightscout/cgm-remote-monitor/releases/tag/v15.0.9 (2026-11-26, HTML, tag confirmed)
- https://api.github.com/repos/nightscout/cgm-remote-monitor/releases/latest: 403 (failed, see README)

## What it is
Node.js web app (Nightscout CGM remote monitor). Latest tag seen: **v15.0.9**.

## Dockerfile (master) - multi-stage
- Stage `builder`: `FROM node:22-alpine`. Copies package.json, package-lock.json, .babelrc, bundle/, webpack/, bin/generateRandomString.js, lib/, static/, views/, translations/, server.js. Runs `npm ci --cache /tmp/empty-cache --omit=optional --force`, then `npm prune --omit=dev --omit=optional`, `rm -rf /tmp/*`.
- Stage `runtime`: `FROM node:22-alpine`, `ENV NODE_ENV=production`, `WORKDIR /opt/app`.
- Copies package*.json, lib/, static/, views/, translations/, server.js (`--chown=node:node`) and node_modules `--from=builder`.
- `USER node`, `EXPOSE 1337`, `CMD ["node", "lib/server/server.js"]`.
- No ENTRYPOINT script; no HEALTHCHECK.

## Install/build deps
- Node 22 (Alpine). README: Node v20 LTS or later supported (v22, v24 also supported).
- Build-time: bundle/webpack via postinstall (run during `npm ci`).

## Runtime deps
- MongoDB (MONGO_CONNECTION). README: MongoDB 4.4 deprecated, to be removed.

## Env vars (README, selected)
| Var | Default | Notes |
| --- | --- | --- |
| API_SECRET | none (required) | min 12 chars; or API_SECRET_FILE path |
| MONGO_CONNECTION | none | required |
| PORT | 1337 | listen port |
| NIGHTSCOUT_HOSTNAME | unset (all interfaces) | 0.0.0.0 for container; HOSTNAME accepted but discouraged |
| ENABLE | - | space-separated plugins, e.g. `careportal rawbg iob` |
| AUTH_DEFAULT_ROLES | `readable` | roles for anonymous visitors (denied, readable, careportal, ...) |
| TREATMENTS_AUTH | `on` | deprecated; `off` appends careportal to AUTH_DEFAULT_ROLES |
| INSECURE_USE_HTTP | - | used by chart |
| SECURE_HSTS_HEADER | `true` | HSTS header |
| SECURE_CSP_REPORT_ONLY | `false` | |
| MONGO_TREATMENTS_COLLECTION | `treatments` | |
| SHOW_FORECAST | `ar2` | |
| IMPORT_CONFIG | - | URL to JSON settings |
| TRUST_PROXY | - | direct-only, hop-count, trust-every-hop or IP/CIDR |
| UUID_HANDLING | `true` | |
| WEBHOOK_PORT | `3000` | webhook plugin |
| DBSIZE_MAX | - | dbsize plugin |

## Ports
- 1337/tcp (EXPOSE and default PORT).

## Volumes/paths
- App at `/opt/app`. No volumes declared in Dockerfile.

## User/UID
- `node` user (node:22-alpine default, uid 1000). Set via `USER node`.

## Config files
- Settings via env vars only in README; IMPORT_CONFIG can load JSON from a URL.

## Healthcheck
- None in Dockerfile.

## Version/asset naming
- Tag form `vX.Y.Z`; latest tag seen v15.0.9. API latest release call returned 403.

## Gotchas
- README: nightscout serves with node `lib/server/server.js` as CMD (path is relative to /opt/app).
- Upstream image is built with `npm ci --force`; NODE_ENV=production set in runtime stage.
- Chart and Docker Hub image are not from this repo's Dockerfile.
