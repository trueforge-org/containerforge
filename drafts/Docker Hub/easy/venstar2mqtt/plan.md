# venstar2mqtt — implementation plan
> Source: ./draft.md · Target: apps/venstar2mqtt/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Upstream | https://github.com/terafin/mqtt-venstar-bridge (Node MQTT bridge for Venstar thermostats) |
| Releases / tags | None. `git ls-remote --tags` returns nothing, so the only stable reference is a commit. master HEAD on 2026-11-23: `423f9bd613619e92e4799135cf080c1de05d13dc` (the same commit the draft's Dockerfile link points at) |
| Version to use | The full commit SHA above. `package.json` says `1.0.0` but never changes, so it is not usable as a tag |
| Renovate | `datasource=git-refs depName=https://github.com/terafin/mqtt-venstar-bridge currentValue=master` (same shape as `apps/tvheadend/docker-bake.hcl`) |
| Second pinned dependency | `homeautomation-js-lib` is installed from `https://github.com/terafin/homeautomation-js-lib.git` (unpinned in `package.json`). HEAD on 2026-11-23: `f506c726e4b1faaee52291498be9ba9ff8ff1199`. It also has no tags, and its own deps are all `latest` |
| License | MIT (`package.json` and `LICENSE`, "Copyright (c) 2018 terafin"); `homeautomation-js-lib` is MIT too (2017 terafin) |
| Source tarball | `https://github.com/terafin/mqtt-venstar-bridge/archive/<sha>.tar.gz` (same for all arches, pure JavaScript) |
| Checksum source | None published. Integrity comes from pinning the commit SHA |
| Upstream Dockerfile | Reviewed: `FROM node:lts-alpine`, `apk add git tzdata`, `COPY . /usr/node_app`, `npm install --production`, `CMD ["npm","start"]` (`node index.js`). No `EXPOSE`, no `USER` |
| Ports | None by default. The app is an MQTT client plus an HTTP client for the thermostat. `homeautomation-js-lib/health.js` starts an optional health server on `0.0.0.0:$HEALTH_CHECK_PORT`, but only when `HEALTH_CHECK_PORT`, `HEALTH_CHECK_TIME` and `HEALTH_CHECK_URL` are all set |
| Env vars (read in code) | `TOPIC_PREFIX` (required, else `process.abort()`), `MQTT_HOST` (required, else `process.abort()`, `mqtt://host` style URL), `VENSTAR_HOST` (required, else `process.abort()`), `VENSTAR_QUERY_INTERVAL` (seconds, default 15), `MQTT_USER`, `MQTT_PASS`, `MQTT_RETAIN` (default true), `MQTT_NAME`, `LOGGING_NAME`, `MQTT_STATUS_TOPIC_PREFIX` (default `/status/`), `LOG_LEVEL` (default INFO), `HEALTH_CHECK_PORT`, `HEALTH_CHECK_TIME`, `HEALTH_CHECK_URL`, `TZ` |
| Data / config paths | None. The app keeps no state on disk |
| Draft corrections | The draft says "no ports" (correct) and "writes only to /config" (it writes nothing at all). The chart forces `runAsUser 0`, which is not needed |

## 2. Target layout

```
apps/venstar2mqtt/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

- No `defaults/`, `etc/`, `scripts/` or `health/`: there is no config file to seed.
- `root/` is never used. No `DOWNSTREAM_CHANGES.md`: nothing builds `FROM` this image.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

- Why: the draft names `python-node`, and it is the repo's Node-capable base (it provides `node` and `npm`, as used by `apps/budge`, `apps/thelounge` and `apps/wikijs`). Python is unused but harmless.
- Closest siblings: `apps/thelounge` (npm app, state in `/config`) and `apps/budge`.
- UNVERIFIED: the Node major in `python-node`. `mqtt@^4`, `got@^11` and `cron@^1` run on current Node LTS, but confirm with `docker run --rm --entrypoint node <image> -v` while building.

## 4. Dockerfile

1. `ARG VERSION` (commit SHA), `ARG HAJL_COMMIT` (library commit, default `f506c726e4b1faaee52291498be9ba9ff8ff1199`), `ARG TARGETARCH` (unused, JS only, so not needed; omit if hadolint complains).
2. `USER root`.
3. `ENV NODE_ENV=production NPM_CONFIG_CACHE=/tmp/npm-cache NPM_CONFIG_UPDATE_NOTIFIER=false HOME=/config` so npm caches never land in `/config` or `/app`.
4. One `RUN`:
   - `mkdir -p /app/venstar2mqtt /usr/share/licenses/venstar2mqtt`
   - `curl -fsSL -o /tmp/app.tar.gz "https://github.com/terafin/mqtt-venstar-bridge/archive/${VERSION}.tar.gz"` then `tar xzf /tmp/app.tar.gz -C /app/venstar2mqtt --strip-components=1`
   - `cd /app/venstar2mqtt && npm install --omit=dev --no-audit --no-fund` (replaces the deprecated `--production`)
   - Pin the git dependency: `npm install --omit=dev --no-audit --no-fund "github:terafin/homeautomation-js-lib#${HAJL_COMMIT}"`. `git` is already in the ubuntu base, so no apt install is needed.
   - Copy licenses: `cp LICENSE /usr/share/licenses/venstar2mqtt/LICENSE` and `cp node_modules/homeautomation-js-lib/LICENSE /usr/share/licenses/venstar2mqtt/LICENSE.homeautomation-js-lib`
   - `chown -R apps:apps /app && chmod -R u=rwX,go=rX /app`
   - `npm cache clean --force; rm -rf /tmp/* /app/venstar2mqtt/.git`
5. `USER apps`
6. `COPY --chmod=0755 . /`
7. No `EXPOSE` (no port). `VOLUME /config` (kept for consistency, as nothing is written). `WORKDIR /app/venstar2mqtt`.
8. No apt packages: `git`, `curl`, `tar` and `ca-certificates` are already in the ubuntu base. No build tools are needed (all deps are pure JS).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" { default = "venstar2mqtt" }

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/terafin/mqtt-venstar-bridge currentValue=master
  default = "423f9bd613619e92e4799135cf080c1de05d13dc"
}

variable "HAJL_COMMIT" {
  // renovate: datasource=git-refs depName=https://github.com/terafin/homeautomation-js-lib currentValue=master
  default = "f506c726e4b1faaee52291498be9ba9ff8ff1199"
}

variable "LICENSE" { default = "MIT" }
variable "SOURCE"  { default = "https://github.com/terafin/mqtt-venstar-bridge" }
```

- `target "image"` sets `args = { VERSION = "${VERSION}", HAJL_COMMIT = "${HAJL_COMMIT}" }` plus the two OCI labels; `image-local` (`output=["type=docker"]`, `tags=["${APP}:${VERSION}"]`), `image-all` (amd64 and arm64) and `group "default" { targets = ["image-local"] }` copied from `apps/adguardhome-sync/docker-bake.hcl`.
- Image tag is the 40-char SHA, same as `apps/tvheadend`. Check that this tag is acceptable to the publishing workflow; if not, use the first 8 characters for the tag only.
- Run `docker buildx bake --print` from `apps/venstar2mqtt`.

## 6. settings.yaml

- Header `# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json`, `schema_version: 1`, `upstream_env_url: "https://github.com/terafin/mqtt-venstar-bridge"`.
- `ports:` omitted or empty, with a comment "none: MQTT client only". Do not list the optional health port.
- `env` (name / default / required):
  - `TZ` / `Etc/UTC` / false
  - `MQTT_HOST` / `""` / false (functionally required, see section 7 for why it is not `required: true`)
  - `VENSTAR_HOST` / `""` / false (same)
  - `TOPIC_PREFIX` / `/venstar` / false (start.sh default)
  - `VENSTAR_QUERY_INTERVAL` / `15` / false
  - `MQTT_USER` / `""` / false, `MQTT_PASS` / `""` / false
  - `MQTT_RETAIN` / `true` / false
  - `LOG_LEVEL` / `INFO` / false
  - `LOGGING_NAME` / `venstar2mqtt` / false
- `volumes: - path: /config  required: false` (nothing is persisted).
- `dependencies:` none. A reachable MQTT broker and a Venstar thermostat on the LAN are external, not ContainerForge apps.

## 7. start.sh

`#!/usr/bin/env bash`, no `set -e` surprises. Idempotent and writes nothing.

1. Defaults: `export TOPIC_PREFIX="${TOPIC_PREFIX:-/venstar}" LOGGING_NAME="${LOGGING_NAME:-venstar2mqtt}"`. Leave `MQTT_RETAIN`, `VENSTAR_QUERY_INTERVAL` and `LOG_LEVEL` to the app's own defaults.
2. Required-input guard. The app calls `process.abort()` (SIGABRT with a core dump) when `MQTT_HOST` or `VENSTAR_HOST` is missing, and the container test runs with no env. So:
   - if `MQTT_HOST` or `VENSTAR_HOST` is empty, print a clear message (`MQTT_HOST and VENSTAR_HOST must be set; idling`) to stderr and `exec sleep infinity` (tini is PID 1 in the base, so signals still work).
   - otherwise continue.
3. `cd /app/venstar2mqtt && exec node index.js` (do not use `npm start`, which adds a wrapper process and swallows signals).
4. Never write the MQTT password to a file or the command line; it is passed only through the environment.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
filePaths:
- /app/venstar2mqtt/index.js
- /app/venstar2mqtt/node_modules/homeautomation-js-lib/mqtt_helpers.js
- /start.sh
```

- No `tcp`/`http` probe: `settings.yaml` lists no port. The test runs without env vars, so the real code path (MQTT connect) cannot be tested; it must be run by hand (section 11).
- This is not the database exception; there is simply no listening port.

## 9. Rootless and read-only-rootfs adaptations

| Upstream behaviour | Remap |
| --- | --- |
| Chart runs as UID 0 | Run as `apps` (UID 568); nothing needs root |
| Chart sets `readOnlyRootFilesystem: false` | App writes nothing; npm cache is at `/tmp/npm-cache`, `HOME=/config` |
| App dir `/usr/node_app` | `/app/venstar2mqtt`, read-only at runtime, owned by `apps` |
| `log4js` / `graphite` in the lib | Log to stdout. The lib may open a graphite connection only if configured (UNVERIFIED: not read in detail) |
| `/config` | Not used; declared as a volume for consistency |

Draft expectations (non-root possible, read-only possible, not privileged, no extra persistence) all hold.

## 10. Risks, caveats and open questions

- Non-reproducible upstream: no tags, and `homeautomation-js-lib` pulls `latest` of `graphite`, `js-yaml`, `lodash`, `log4js`, `mqtt`, `path`, `url`, `chokidar`. Pinning both commits helps, but transitive npm deps still float. There is no lockfile upstream (UNVERIFIED: `package-lock.json` was not found). Consider committing nothing and accepting the drift, or ask the maintainers whether a generated lockfile may live in `apps/venstar2mqtt/`.
- `path` and `url` are npm packages that shadow Node built-ins; they install fine but are an upstream smell.
- The app aborts without `MQTT_HOST`/`VENSTAR_HOST`/`TOPIC_PREFIX`. The idle-with-message choice in start.sh is deliberate so the image test passes; confirm maintainers prefer idling to a crash loop.
- `MQTT_HOST` must be a URL such as `mqtt://broker:1883` (passed to `mqtt.connect`).
- Needs a Venstar thermostat with its local API enabled and an MQTT broker, neither of which is provided. No `mosquitto` app was checked as a dependency.
- No arm64 blocker: pure JavaScript.
- Renovate `git-refs` PRs will propose a new SHA for every upstream commit.

## 11. Build and test steps

```sh
cd apps/venstar2mqtt
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create venstar2mqtt-probe-config
docker run --rm -d --name venstar2mqtt-probe --read-only --tmpfs /tmp \
  -v venstar2mqtt-probe-config:/config venstar2mqtt:423f9bd613619e92e4799135cf080c1de05d13dc
docker logs venstar2mqtt-probe        # expect the idle message, container still running
forgetool containers test --image venstar2mqtt:423f9bd613619e92e4799135cf080c1de05d13dc --config ./apps/venstar2mqtt/container-test.yaml
docker rm -f venstar2mqtt-probe; docker volume rm venstar2mqtt-probe-config
```

- Second manual run with `-e MQTT_HOST=mqtt://<broker> -e VENSTAR_HOST=<ip> -e TOPIC_PREFIX=/venstar/test`: expect `MQTT Connected` and `Connected, subscribing` in the logs and the process still running (a missing thermostat only produces query errors, not an exit).
- Expected readiness signal in the idle run: the guard message, process alive. In the full run: `MQTT Connected`.

## 12. PR checklist

- Branch `feat/add-venstar2mqtt`; commit and PR title `feat(venstar2mqtt): add new container`; target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keep all sections, check only the boxes that apply.
- Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it; the `license/cla` check shows the status.
- State honestly what was not tested: arm64 build, the MQTT/thermostat path against real hardware (unless done), and Node version compatibility if not checked.
- Pre-completion: `bake --print` ok, image-local builds, empty-`/config` read-only run is clean, forgetool test passes, no assertion weakened.
