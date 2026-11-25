# quassel-web — implementation plan
> Source: ./draft.md · Target: apps/quassel-web/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Pin master commit `019bfdc1e7c9cacdd76057072c0fa654b467439b` (committed 2023-11-10). Source: https://api.github.com/repos/magne4000/quassel-webserver/commits/master. Latest tag is `2.2.8` (commit `11e3f7b4906b5ec3039f2c7e0f33bbbe406d9aeb`, 2017-02-14), older than master. `package.json` says `version: 3.0.2` but there is no tag for it. Source: https://api.github.com/repos/magne4000/quassel-webserver/tags and .../contents/package.json. No GitHub releases (API 404). |
| Chart image | `ghcr.io/linuxserver/quassel-web:2021.12.16` (draft). The linuxserver docker repo is archived (`linuxserver-archive/docker-quassel-web`, last push 2024-12-26). Source: https://api.github.com/repos/linuxserver/docker-quassel-web |
| Renovate | `datasource=git-refs depName=https://github.com/magne4000/quassel-webserver currentValue=master` (same form as `apps/tvheadend`). |
| License | MIT (GitHub API `license.spdx_id` MIT; `package.json` `license` MIT). Source: https://api.github.com/repos/magne4000/quassel-webserver |
| Source URL | https://github.com/magne4000/quassel-webserver |
| Download | No binary. `https://github.com/magne4000/quassel-webserver/archive/${VERSION}.tar.gz` (the linuxserver Dockerfile uses this pattern with `QUASSELWEB_COMMIT`). No checksum published; the commit SHA is the pin. Source: https://api.github.com/repos/linuxserver/docker-quassel-web/contents/Dockerfile (decoded). |
| Build step | NONE. `package.json` scripts are `start: node app.js` and `dev: nodemon app.js -m http -p 64111`. The README install is `npm install --production`. The draft's "frontend build" is not supported by upstream. |
| Node | `engines.node >= 16`; README recommends v20. Node version in `python-node` UNVERIFIED. |
| Dependencies | `libquassel ^4.0.0`, `express ^4.18.2`, `ws ^8.14.2`, `less`, `less-middleware`, `pug`, `commander`, `morgan`, `serve-favicon`, `untildify`, `resolve-esm`, `body-parser`, `cookie-parser`; optional `@httptoolkit/httpolyglot`. Source: https://api.github.com/repos/magne4000/quassel-webserver/contents/package.json |
| Upstream Dockerfile reviewed | linuxserver/docker-quassel-web `Dockerfile`: `FROM ghcr.io/linuxserver/baseimage-alpine:3.20`; apk `npm`; `mkdir /app/quassel-web`; `curl` the master tarball; `tar xf --strip-components=1`; `cd /app/quassel-web && npm install`; `EXPOSE 64443`; `VOLUME /config`. |
| Upstream CLI | `app.js`: `-c, --config <value>`, `-s, --socket <path>`, `-l, --listen [0.0.0.0]`, `-p, --port [64080\|64443]`, `-m, --mode (http\|https) [https]`. Source: https://api.github.com/repos/magne4000/quassel-webserver/contents/app.js |
| Upstream config | `settings.cjs`: `webserver.socket: false`, `webserver.listen: null` (all IPs), `webserver.port: null` (64080 for http, 64443 for https), `webserver.mode: null` (default https), `default.host: ''`, `default.port: 4242`, `prefixpath: ''`. Source: https://api.github.com/repos/magne4000/quassel-webserver/contents/settings.cjs |
| linuxserver init | `init-quassel-web-config/run`: if `QUASSEL_CORE` and `QUASSEL_PORT` are both set, copies `settings.cjs` to `/app/quassel-web/settings-env.cjs` and `sed`s `host`, `port`, `prefixpath` (from `URL_BASE`) and mode/port (`QUASSEL_HTTPS` empty = `mode: 'http'`, `port: 64080`). Otherwise copies `settings.cjs` to `/config/settings-user.cjs` when missing and exits. Source: https://api.github.com/repos/linuxserver/docker-quassel-web/contents/root/etc/s6-overlay/s6-rc.d/init-quassel-web-config/run |
| linuxserver run | `svc-quassel-web/run`: `NODE_ENV=production`, `cd /app/quassel-web`, `node app.js --config <CONFIG>` with `CONFIG` = `settings-env.cjs` when `QUASSEL_CORE` is set, else `/config/settings-user.cjs`. Source: https://api.github.com/repos/linuxserver/docker-quassel-web/contents/root/etc/s6-overlay/s6-rc.d/svc-quassel-web/run |
| Env vars | Image level (linuxserver, not upstream): `QUASSEL_CORE`, `QUASSEL_PORT`, `QUASSEL_HTTPS`, `URL_BASE`. Upstream reads only `--config`. |
| Port | Upstream default 64080 (http) or 64443 (https). The draft's 8080 is NOT an upstream default. |
| Data paths | `/config` (settings). README: https mode uses `ssl/key.pem` and `ssl/cert.pem` created with openssl. Upstream writes to `ssl/` UNVERIFIED (README only). |
| Dependencies | A running Quassel core (quasselcore) reachable over the network. README: "requires a running quasselcore". Not a ContainerForge app in `apps/`. |
| Maintenance | README: "This project is not actively maintained". |
| arm64 | Architecture-neutral JS; no native npm modules listed. |

## 2. Target layout

- `apps/quassel-web/Dockerfile`
- `apps/quassel-web/docker-bake.hcl`
- `apps/quassel-web/settings.yaml`
- `apps/quassel-web/container-test.yaml`
- `apps/quassel-web/start.sh` (seeds `/config/settings-user.cjs`, applies env, `exec node app.js`)

No `defaults/`, `etc/`, `health/` needed. `settings-user.cjs` is seeded from the upstream `settings.cjs` in `/app/quassel-web` at start time. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

Why: the app needs Node at runtime (`node app.js`), and `python-node` is the ContainerForge base that provides it. The draft named it too. Closest sibling: `apps/changedetection` and `apps/budge` (python-node with a Node app). The Node version inside the image is UNVERIFIED: check `node --version` on the first build and confirm `>= 16`.

## 4. Dockerfile

1. `ARG VERSION` (commit SHA), aligned with the bake file.
2. Single stage on `python-node`. The app is plain JS with no build step, so a build stage would copy the same files. (Use a build stage only if a native module appears.)
3. Install the app:
   - `ENV HOME=/tmp NPM_CONFIG_CACHE=/tmp/npm-cache NPM_CONFIG_UPDATE_NOTIFIER=false`
   - `RUN mkdir -p /app/quassel-web && curl -fL "https://github.com/magne4000/quassel-webserver/archive/${VERSION}.tar.gz" -o /tmp/quassel-web.tar.gz && tar xzf /tmp/quassel-web.tar.gz -C /app/quassel-web --strip-components=1 && rm /tmp/quassel-web.tar.gz`
   - `RUN cd /app/quassel-web && npm install --omit=dev` (README uses `--production`; `--omit=dev` is the same and current). Use `npm ci --omit=dev` if the tarball contains a `package-lock.json` (UNVERIFIED; check).
   - `RUN chmod -R 755 /app/quassel-web && rm -rf /tmp/npm-cache`
4. License: `RUN mkdir -p /usr/share/licenses/quassel-web && cp /app/quassel-web/LICENSE-MIT /usr/share/licenses/quassel-web/LICENSE` (file name from `package.json` `licenses[0].url`; `LICENSE-MIT` is the link target; confirm the file exists in the tarball).
5. Copy local files and set user:

```dockerfile
USER root
COPY --chmod=0755 . /
USER apps
ENV TZ=Etc/UTC
EXPOSE 64080
VOLUME /config
CMD ["/start.sh"]
```

`USER root` is only needed if the `cp` and `chmod` above run as root; keep them before `USER apps`. No `chown` is needed for `/app`, which is read-only at runtime.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "quassel-web"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/magne4000/quassel-webserver currentValue=master
  default = "019bfdc1e7c9cacdd76057072c0fa654b467439b"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/magne4000/quassel-webserver"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = { VERSION = "${VERSION}" }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = ["linux/amd64", "linux/arm64"]
}
```

`VERSION` is a commit SHA, so validate with `docker buildx bake --print`. The `LICENSE` is MIT, matching the upstream `package.json`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/magne4000/quassel-webserver"
ports:
  - port: 64080
    protocol: tcp
    required: false
env:
  - name: QUASSEL_CORE
    default: ""
    required: false
  - name: QUASSEL_PORT
    default: "4242"
    required: false
  - name: QUASSEL_HTTPS
    default: ""
    required: false
  - name: URL_BASE
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

- `ports` lists 64080 only: the http default that the container opens when `QUASSEL_HTTPS` is empty. If the user sets `QUASSEL_HTTPS`, the app listens on 64443 (not listed, see section 10).
- `QUASSEL_CORE` and `QUASSEL_PORT` are read by `start.sh` (the draft's `quasselcore` host and port). The `default: "4242"` matches the upstream `default.port`.
- `dependencies: []`: the Quassel core is external; the app does not need a ContainerForge container.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

CONFIG=/config/settings-user.cjs
RUN_CONFIG="${CONFIG}"

# Seed the user config once; never overwrite user state.
if [ ! -f "${CONFIG}" ]; then
  cp -p /app/quassel-web/settings.cjs "${CONFIG}"
fi

# Env injection writes a copy to /tmp, not /app (read-only at runtime).
if [ -n "${QUASSEL_CORE:-}" ]; then
  RUN_CONFIG=/tmp/quassel-web/settings-env.cjs
  mkdir -p /tmp/quassel-web
  cp -p /app/quassel-web/settings.cjs "${RUN_CONFIG}"
  sed -i \
    -e "s#host:.*//#host: '${QUASSEL_CORE}', //#g" \
    -e "s#port:.*,// quasselcore#port: ${QUASSEL_PORT:-4242}, // quasselcore#g" \
    "${RUN_CONFIG}"
  if [ -n "${URL_BASE:-}" ]; then
    sed -i "s#prefixpath:.*//#prefixpath: '${URL_BASE}', //#g" "${RUN_CONFIG}"
  fi
  if [ -z "${QUASSEL_HTTPS:-}" ]; then
    sed -i \
      -e "s#mode:.*// can be 'http'#mode: 'http', // can be 'http'#g" \
      -e "s#port:.*// Port on which to listen#port: 64080, // Port on which to listen#g" \
      "${RUN_CONFIG}"
  fi
fi

cd /app/quassel-web
export NODE_ENV=production
exec node app.js --config "${RUN_CONFIG}"
```

- Without `QUASSEL_CORE`, the app uses `/config/settings-user.cjs`, which the user edits.
- The `sed` patterns follow the linuxserver init (fetched). Do not use the linuxserver `sed` on untrusted values without quoting: `QUASSEL_CORE` and `URL_BASE` go into JS. Validate them (hostname/IP and path characters only) and fail fast; the draft said "values from the environment end up in code, so do not break on special characters" (instruction rule). Add that validation to `start.sh` before the `sed`.
- Idempotent: the seed happens only when `/config/settings-user.cjs` is missing. Env injection rewrites only `/tmp`.
- `exec node` gives the app PID 1 signal handling.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
tcp:
- port: '64080'
http:
- port: '64080'
  path: /
filePaths:
- /app/quassel-web/app.js
- /app/quassel-web/settings.cjs
- /app/quassel-web/node_modules/libquassel/package.json
- /usr/share/licenses/quassel-web/LICENSE
```

- The test runs with no env vars, so the `QUASSEL_CORE` path is not exercised. `/tmp/quassel-web/settings-env.cjs` is written at runtime and cannot be a `filePaths` entry. Run the env path by hand (section 11) and say so in the PR.
- `http` probe on `/` must return 200 with no Quassel core running. UNVERIFIED: the page may show the login form (200) or fail to connect to a core in the background. Check on the first run.

## 9. Rootless and read-only-rootfs adaptations

| Upstream / linuxserver write path | ContainerForge remap |
| --- | --- |
| `/app/quassel-web/settings-env.cjs` (env injection, writes into app folder) | `/tmp/quassel-web/settings-env.cjs` (`/app` is read-only). |
| `/config/settings-user.cjs` | Same path; the persistent user config. |
| `/app/quassel-web/public` chown (linuxserver `chownfiles`) | Not needed; `/app` is read-only and owned by root, readable by `apps`. |
| `ssl/key.pem`, `ssl/cert.pem` (README, https mode) | Out of scope for the first version (section 10). |
| npm cache | `/tmp/npm-cache`, removed at build. |
| `/root` (linuxserver cleanup) | Not used. |

- Ports: 64080 is unprivileged, so no port remap is needed (the draft's 8080 is dropped because it is not the upstream default).
- Chart: `runAsUser: 0` is replaced by `USER apps`. `readOnlyRootFilesystem: false` is compatible with `--read-only --tmpfs /tmp`.
- Privileged: no. Extra persistence: none beyond `/config`.

## 10. Risks, caveats and open questions

- HTTPS mode is not included in the first version: it needs cert files in a writable place. Option: `/config/ssl/` plus `QUASSEL_HTTPS` handling in `start.sh`, with ports 64443 added to `settings.yaml` at that time. Not in this plan.
- Port: the draft's 8080 is not an upstream default. The plan uses 64080 (http default). linuxserver's `EXPOSE 64443` is the https default.
- Draft's "frontend build" claim is wrong: there is no build script. The npm step is `install` only.
- Node version in `python-node` is UNVERIFIED against `engines >= 16`.
- The upstream project is not actively maintained (README). The pinned master commit is from 2023-11-10. The linuxserver chart image is from 2021 and the docker repo is archived.
- Input validation: `QUASSEL_CORE`, `QUASSEL_PORT`, `URL_BASE` end up in JavaScript. Validate them in `start.sh` (hostname/IP characters, digits, path characters) and fail on anything else.
- Blockers: none. The app needs a reachable Quassel core, which is an external dependency to state in the PR.

## 11. Build and test steps

```sh
cd apps/quassel-web
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name quassel-web-probe --read-only --tmpfs /tmp \
  -v quassel-web-probe-config:/config quassel-web:019bfdc1e7c9cacdd76057072c0fa654b467439b
docker logs -f quassel-web-probe
forgetool containers test --image quassel-web:019bfdc1e7c9cacdd76057072c0fa654b467439b --config ./apps/quassel-web/container-test.yaml
docker rm -f quassel-web-probe; docker volume rm quassel-web-probe-config
```

- Env path: run once with `-e QUASSEL_CORE=<reachable host> -e QUASSEL_PORT=4242` and a fresh `/config`, confirm `/tmp/quassel-web/settings-env.cjs` is written and the app starts. Record that run in the PR, because the forgetool test does not cover it.
- Readiness signal: UNVERIFIED exact log line; read `app.js` on the first run for its listen message, then fill it in here. Confirm HTTP 200 on `/` from inside and from the host (`-p 64080:64080`).
- Confirm `/config/settings-user.cjs` exists after the first start and survives a restart.

## 12. PR checklist

- Branch `feat/add-quassel-web`, commit and PR title `feat(quassel-web): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Say in the PR: the upstream is not maintained, the external Quassel core is required, HTTPS mode is not included, and the untested items (Node version, the env path run, the probe status code, arm64).
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; no assertion weakened.
