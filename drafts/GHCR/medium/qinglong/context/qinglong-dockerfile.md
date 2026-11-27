# Upstream Dockerfile: whyour/qinglong (docker/Dockerfile)

Source URL: https://raw.githubusercontent.com/whyour/qinglong/6e26899a235a955713edfb490f6ae538d0baf612/docker/Dockerfile (fetched 2026-11-27, pinned commit)

## Stages
| Stage | Base | Purpose |
| --- | --- | --- |
| builder | `--platform=$BUILDPLATFORM node:24.18.1-alpine3.24` | `apk add git`; `npm i -g pnpm@8.3.1 pm2 ts-node typescript@5`; `pnpm install --prod --frozen-lockfile --side-effects-cache=false` in /tmp/build using package.json, .npmrc, pnpm-lock.yaml. Cross-compiles npm via env `npm_config_target_arch` / `npm_config_target_libc` (musl, musl-armv6, musl-armv7). |
| node-runtime-amd64 | `--platform=linux/amd64 node:24.18.1-alpine3.24@sha256:f70403e8...` | Only supplies node binary (bind-mounted, copied to /usr/local/bin/node on amd64). |
| final | `python:3.11-alpine3.24` | Runtime. |

## Final stage install/build
- Alpine packages: bash coreutils git curl wget tzdata perl openssl nodejs jq openssh procps netcat-openbsd unzip npm.
- Timezone: Asia/Shanghai (symlink + /etc/timezone).
- Git global config: user `qinglong`, postBuffer 524288000.
- `git clone --depth=1 -b ${QL_BRANCH} ${QL_URL} ${QL_DIR}`; QL_DIR=/ql; QL_BRANCH default `develop`; QL_URL=https://github.com/whyour/qinglong.git. Optional SOURCE_COMMIT → fetch and reset to it.
- `cp -f .env.example .env`; chmod 777 shell/*.sh and docker/*.sh.
- `COPY static/ /ql/static/` (CI-provided, from build-static job); COPY docker/verify-build.cjs, docker/build-manifest.cjs to /tmp/.
- `node /tmp/verify-build.cjs /tmp/dependency-lock.yaml` and `node shell/node-runtime-probe.cjs` (armv6 uses `QEMU_CPU=arm1176 node --jitless`).
- `pip3 install --prefix ${PYTHON_HOME} requests`.
- `COPY --from=builder /tmp/build/node_modules/. /ql/node_modules/`.
- Symlinks: /usr/local/bin/task → shell/task.sh; /usr/local/bin/ql → shell/update.sh.

## Runtime deps
- node 24.x (checked by `node --version | grep -E '^v24\.'`), python 3.11, pip `requests`, pm2, git, curl, openssh.

## Entrypoint / flags
- `WORKDIR /ql`; `ENTRYPOINT ["./docker/docker-entrypoint.sh"]`; no CMD; no USER (runs as root).

## Env vars (set in image)
| Var | Value |
| --- | --- |
| QL_DIR | /ql |
| QL_BRANCH | develop (build ARG) |
| QL_CONTAINER | true |
| LANG | C.UTF-8 |
| SHELL | /bin/bash |
| HOME | /root |
| PNPM_HOME | /ql/data/dep_cache/node |
| PYTHON_HOME | /ql/data/dep_cache/python3 |
| PYTHONUSERBASE | /ql/data/dep_cache/python3 |
| PIP_CACHE_DIR | ${PYTHON_HOME}/pip |
| NODE_PATH | /usr/local/bin:/usr/local/lib/node_modules |
| PATH | adds PNPM_HOME, PYTHON_HOME/bin, HOME/bin |

## Ports
- EXPOSE 5700. Healthcheck targets `http://localhost:${QlPort:-5700}/api/health`.

## Volumes/paths
- `VOLUME /ql/data`. Dep cache lives under /ql/data/dep_cache.

## Healthcheck
- `--interval=5s --timeout=2s --retries=20` `curl -sf --noproxy '*' http://localhost:${QlPort:-5700}/api/health`.

## Gotchas
- Node runtime on amd64 is the upstream musl binary (comment: native URL parser crashes with APK node). Image is alpine/musl.
- Build depends on CI-supplied `static/` directory.
- Labels: org.opencontainers.image.revision from SOURCE_COMMIT.
