# MeshCentral docker/Dockerfile (commit f436143527458d56da0336ea3047c006703fb4e4)

Source URL(s) + date:
- https://raw.githubusercontent.com/Ylianst/MeshCentral/f436143527458d56da0336ea3047c006703fb4e4/docker/Dockerfile (2026-11-27; raw variant of the blob URL in urls.txt, same commit)

## What it is
Upstream Docker build of MeshCentral 1.3.x; source copied from repo, npm deps installed, Node on Alpine.

## Build stages
| stage | base | what |
| --- | --- | --- |
| node-amd64 / node-arm64 | node:24.22.1-alpine3.24 | Alpine node |
| node-arm | alpine:3.24 | apk nodejs npm (node images not published for 32-bit ARM) |
| node-base | node-${TARGETARCH} | apk jq tzdata |
| mesh-compiler | node-base | COPY ./ to /opt/meshcentral/meshcentral; optional translate/extract/minify via ARGs DISABLE_EXTRACT/DISABLE_MINIFY/DISABLE_TRANSLATE (default "yes" = disabled); removes docker, node_modules, docs dirs |
| dep-compiler | node-base | apk bash gcc g++ make python3; jq adds deps modern-syslog 1.2.0 and telegram 2.26.22; `npm i --package-lock-only`; `npm ci --omit=dev` |
| finalizer | node-base | runtime; COPY dep-compiler output; optional preinstall/DB tool stages |

## Runtime
- ENTRYPOINT: `["/bin/bash", "/opt/meshcentral/entrypoint.sh"]` (entrypoint.sh not fetched)
- WORKDIR: /opt/meshcentral
- Installed in final: bash curl (apk), jq, tzdata
- Build args: PREINSTALL_LIBS, INCLUDE_MONGODB_TOOLS, INCLUDE_POSTGRESQL_TOOLS, INCLUDE_MARIADB_TOOLS (default false; accepted values yes/true/no/false)

## Env vars (finalizer ENV defaults)
| var | default |
| --- | --- |
| NODE_ENV | production |
| CONFIG_FILE | /opt/meshcentral/meshcentral-data/config.json |
| DYNAMIC_CONFIG | false |
| ALLOW_PLUGINS | false |
| ALLOW_NEW_ACCOUNTS | false |
| ALLOWED_ORIGIN | false |
| HOSTNAME | localhost |
| PORT | 443 |
| REDIR_PORT | 80 |
| INSTALL_STYLISHUI | false |
| IFRAME | false |
| LOCAL_SESSION_RECORDING | true |
| MINIFY | true |
| REVERSE_PROXY | "" |
| REVERSE_PROXY_TLS_PORT | 443 |
| REGEN_SESSIONKEY | false |
| STYLISHUI_FORCE_LATEST | false |
| WEBRTC | false |
| TRUSTED_PROXY | "" |
| ARGS | "" |
| USE_MONGODB / USE_POSTGRESQL / USE_MARIADB | false |
| MONGO_HOST, MONGO_PORT (27017), MONGO_USERNAME, MONGO_PASS, MONGO_URL | "" |
| PSQL_HOST, PSQL_PORT (5432), PSQL_USER, PSQL_PASS, PSQL_DATABASE | "" |
| MARIADB_HOST, MARIADB_PORT (3306), MARIADB_USER, MARIADB_PASS, MARIADB_DATABASE | "" |

## Ports
- EXPOSE ${PORT} (443) and ${REDIR_PORT} (80)

## Volumes/paths
- VOLUME /opt/meshcentral/meshcentral-data, meshcentral-files, meshcentral-web, meshcentral-backups
- config template: /opt/meshcentral/config.json.template

## Healthcheck
- none in Dockerfile

## Version/asset naming
- Source tree is the git repo; no release tarball used by upstream Dockerfile.

## Arch
- node-amd64, node-arm64 use official node alpine images; arm/v6 and arm/v7 use Alpine nodejs/npm packages.

## Gotchas
- Alpine (musl) base upstream; the plan uses a glibc base instead.
- Dockerfile copies `docker/entrypoint.sh` and `docker/config.json.template`; not fetched here.
