# node-red upstream Dockerfile.debian, npm metadata and license

Source URL(s) + date: https://raw.githubusercontent.com/node-red/node-red-docker/master/.docker/Dockerfile.debian ; https://registry.npmjs.org/node-red/latest ; License per npm and LICENSE (Apache-2.0) (fetched 2026-11-27)

## npm package
- node-red version 5.0.10, license Apache-2.0, engines node >=22.9.
- bin: node-red -> red.js, node-red-pi -> bin/node-red-pi. main: lib/red.js.

## Stages
| Stage | Base | Notes |
| --- | --- | --- |
| base | node:${NODE_VERSION}-${OS} | apt: bash, tzdata, curl, nano, wget, git, openssl, openssh-client, ca-certificates, iputils-ping |
| build | base | apt build-essential python3 python-is-python3; `npm install --unsafe-perm --no-update-notifier --no-fund --only=production`; `npm uninstall node-red-node-gpio`; copies to prod_node_modules |
| release | base | apt build-essential python3-dev python3; copies prod_node_modules to ./node_modules; `npm config set cache /data/.npm --global` |

- ARG defaults: NODE_VERSION=24, OS=trixie-slim.
- Release-only ARGs without defaults: BUILD_DATE, BUILD_VERSION, BUILD_REF, NODE_RED_VERSION, ARCH, TAG_SUFFIX.

## Final image (release)
- WORKDIR /usr/src/node-red; dirs /usr/src/node-red and /data created.
- ENV NODE_RED_VERSION=$NODE_RED_VERSION; NODE_PATH=/usr/src/node-red/node_modules:/data/node_modules; PATH=/usr/src/node-red/node_modules/.bin:$PATH; FLOWS=flows.json.
- Commented out ENV: NODE_RED_ENABLE_SAFE_MODE=true, NODE_RED_ENABLE_PROJECTS=true.
- COPY `.docker/scripts/*.sh` -> /tmp/; `.docker/healthcheck.js` -> /; `package.json` -> .; `flows.json` -> /data; `.docker/scripts/entrypoint.sh` -> .
- ENTRYPOINT ["./entrypoint.sh"]; CMD none.
- EXPOSE 1880. No VOLUME.
- HEALTHCHECK CMD `node /healthcheck.js` (default 30s interval).
- USER node-red. `useradd --home-dir /usr/src/node-red --uid 1000 node-red` (no GID given); `deluser --remove-home node`.
- chown -R node-red:root and chmod -R g+rwX on /data and /usr/src/node-red.
- SSH: `echo "PubkeyAcceptedKeyTypes +ssh-rsa" >> /etc/ssh/ssh_config`; known_hosts.sh run then removed.
- release: `rm -r /tmp/*`.
- LABELs: license Apache-2.0, name Node-RED, url https://nodered.org, source https://github.com/node-red/node-red-docker.

## Runtime / user / paths
- UID 1000 (node-red), no GID set. Writable: /data, /usr/src/node-red.
- Read-only rootfs note: /data/.npm cache and /data (flows, creds) must be writable.

## Env vars (defaults)
| Name | Default | Note |
| --- | --- | --- |
| FLOWS | flows.json | flow file; "" uses flowFile from settings.js |
| NODE_RED_ENABLE_SAFE_MODE | false | start in safe mode |
| NODE_RED_ENABLE_PROJECTS | false | enable projects |
| NODE_OPTIONS | (unset) | node runtime args, e.g. --max_old_space_size=128 |
| NODE_RED_CREDENTIAL_SECRET | (user-defined) | credential key, used in settings.js |
| TZ | (unset) | timezone |

## Arch
- Multi-arch via ARCH/TAG_SUFFIX build args; NODE_VERSION controls Node base.

## Gotchas
- Image is GHCR-published for chart; Docker Hub name nodered/node-red per docs.
- Dockerfile HEALTHCHECK runs `node /healthcheck.js`.
- Chart sets no securityContext; image runs as UID 1000 by default.
