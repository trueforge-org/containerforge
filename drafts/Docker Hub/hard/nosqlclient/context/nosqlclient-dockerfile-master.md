# nosqlclient/nosqlclient Dockerfile (master)

**Source:** https://raw.githubusercontent.com/nosqlclient/nosqlclient/master/Dockerfile (fetched 2026-11-26; blob URL in urls.txt is the same file)

## Base / stages
- FROM `debian:jessie` (EOL distro); single stage; no ARG instructions.

## ENV (defaults)
| Name | Default |
|---|---|
| NODE_VERSION | 12.16.1 |
| GOSU_VERSION | 1.10 |
| ROOT_URL | http://localhost |
| PORT | 3000 |
| INSTALL_MONGO | true |
| MONGOCLIENT_DEFAULT_CONNECTION_URL | "" |
| MONGOCLIENT_CONNECTIONS_FILE_PATH | /opt/meteor/dist/predefined_connections.json |
| APP_SOURCE_DIR | /opt/meteor/src |
| APP_BUNDLE_DIR | /opt/meteor/dist |
| BUILD_SCRIPTS_DIR | /opt/build_scripts |

## Node / packages
- Node 12.16.1 via `install-node.sh` (download URL and SHA not in Dockerfile; script not fetched).
- apt packages via `install-deps.sh` (not fetched).
- Build delegated to scripts.

## Build sequence
1. RUN (build scripts dir): `install-deps.sh`, `install-node.sh`, `install-mongo.sh`, `post-install-cleanup.sh`
2. RUN (in $APP_SOURCE_DIR): `install-meteor.sh`, `build-meteor.sh`, `post-build-cleanup.sh`
3. RUN: copy `tunnel-ssh` from bundle `programs/server/npm/node_modules/` to `meteor/modules-runtime/node_modules/` (missing-module fix)
- `.docker` copied to /opt/build_scripts; full build context copied to /opt/meteor/src.

## Users
- group `node` GID 1000, user `node` UID 1000 (home created). Build scripts dir chmod -R 770.
- Runtime user: node.

## Runtime
| Item | Value |
|---|---|
| EXPOSE | 3000 |
| VOLUME | none |
| WORKDIR | /opt/meteor/dist/bundle |
| ENTRYPOINT | ["./entrypoint.sh"] |
| CMD | ["node", "main.js"] |
| HEALTHCHECK | none |

## Gotchas
- debian:jessie and Node 12 are both EOL.
- GOSU_VERSION 1.10 declared, used by entrypoint (not verified).
