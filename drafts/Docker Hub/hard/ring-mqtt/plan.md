# ring-mqtt — implementation plan
> Source: ./draft.md · Target: apps/ring-mqtt/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `v5.9.3` (GitHub release 2026-03-09); matches draft `5.9.3`. |
| Renovate | `datasource=github-releases depName=tsightler/ring-mqtt versioning=semver`. Second variable `GO2RTC_VERSION`: `datasource=github-releases depName=AlexxIT/go2rtc` (upstream pins v1.9.14; latest release seen is v1.9.15). |
| License | `LICENSE` file exists in the repo; type not displayed. UNVERIFIED: believed MIT, read the file before setting `LICENSE`. |
| Source URL | https://github.com/tsightler/ring-mqtt/ |
| Download URLs | The release has NO assets. Source: `https://github.com/tsightler/ring-mqtt/archive/refs/tags/v${VERSION}.tar.gz` (interpreted, same for both arches). go2rtc (upstream pinned v1.9.14): `https://github.com/AlexxIT/go2rtc/releases/download/v${GO2RTC_VERSION}/go2rtc_linux_amd64` and `.../go2rtc_linux_arm64` (names from the upstream Dockerfile). |
| Checksum source | None for the tarball. go2rtc: UNVERIFIED whether the release lists checksums (asset list not readable); otherwise pin sha256 `ARG`s. |
| Upstream Dockerfile | Reviewed `tsightler/ring-mqtt` v5.9.3: `FROM node:jod-alpine` (Node 22 LTS), apk `tar xz git bash curl jq tzdata mosquitto-clients`, s6-overlay 3.2.2.0, bashio 0.17.5, go2rtc to `/usr/local/bin/go2rtc`, app in `/app/ring-mqtt`, `npm install`, `/data` chmod 777, `ENTRYPOINT ["/init"]`, `EXPOSE 8554 55123`, no VOLUME. |
| Ports | 55123/tcp: web UI for Ring authentication (started when no refresh token exists). 8554/tcp: RTSP streaming from the embedded stream helper. go2rtc API 1984 is NOT in upstream EXPOSE; draft's 1984 is UNVERIFIED and left out. |
| Env | Docker wiki documents only `BRANCH` (pulls main/dev code at start; do not support, it would write to the app dir). Other settings live in `/data/config.json`. UNVERIFIED: older docs mention env shortcuts (`RINGTOKEN`, `MQTTHOST`, ...), not confirmed for 5.9.3, so not used. |
| config.json keys | Verified: `mqtt_url` (default `mqtt://localhost:1883`), `mqtt_options`, `livestream_user`, `livestream_pass`, `disarm_code`, `enable_cameras` (true), `enable_modes` (false), `enable_panic` (false), `location_ids`, `hass_topic` (`homeassistant/status`), `ring_topic` (`ring`). Docker page also uses `mqtt_user`, `mqtt_pass`. |
| Data | `/data` must be a persistent volume; holds `config.json` and `ring-state.json` (refresh token, system id, device settings). |

## 2. Target layout

```
apps/ring-mqtt/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/config.json    # copy of upstream config.json (mqtt_url etc.), seeded when missing
```
No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

Why: provides Node (UNVERIFIED: its Node major; upstream uses Node 22, check `node -v` in the base and that `engines` in `package.json` is met). Python is unused. If the Node version is wrong, use ubuntu 26.04 (`ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`) plus NodeSource, like `apps/mstream`. Closest siblings: `apps/mstream` (npm app on ubuntu), `apps/changedetection` (python-node).

## 4. Dockerfile

1. `FROM <python-node>`, `ARG VERSION`, `ARG GO2RTC_VERSION`, `ARG TARGETARCH`, `USER root`.
2. apt (check what the base already has; do not reinstall): `ffmpeg` (draft; UNVERIFIED that the embedded stream helper needs the system ffmpeg), `jq`, `mosquitto-clients` only if the init scripts use them (UNVERIFIED), `tzdata`.
3. App: download `v${VERSION}.tar.gz` (checksum pinned), extract to `/app/ring-mqtt` with `--strip-components=1`, `cd /app/ring-mqtt && npm install --omit=dev --cache /tmp/.npm` (upstream uses plain `npm install`; `--omit=dev` UNVERIFIED but safe if no build step needs dev deps), `chmod -R a+rX /app`. Remove `/app/ring-mqtt/bin` as upstream does.
4. go2rtc: map `TARGETARCH` (`amd64`, `arm64` map directly onto asset suffixes), `curl -fL -o /usr/local/bin/go2rtc https://github.com/AlexxIT/go2rtc/releases/download/v${GO2RTC_VERSION}/go2rtc_linux_${TARGETARCH}`, verify checksum, `chmod 0755`.
5. Skip s6-overlay and bashio entirely (UNVERIFIED that no upstream script needs bashio; read `init/s6/` and `scripts/` and port only the logic).
6. Compatibility: `ln -s /config /data` so the app finds `/data` (upstream hard-codes it; UNVERIFIED that no flag exists to move it).
7. Licence: `mkdir -p /usr/share/licenses/ring-mqtt && cp /app/ring-mqtt/LICENSE /usr/share/licenses/ring-mqtt/` and the go2rtc LICENSE (MIT, UNVERIFIED) fetched with the same release.
8. `ENV HOME=/config npm_config_cache=/tmp/.npm TMPDIR=/tmp XDG_CACHE_HOME=/tmp/.cache`.
9. cleanup: `rm -rf /tmp/* /var/lib/apt/lists/*`.
10. `USER apps`
11. `COPY --chmod=0755 . /`
12. `EXPOSE 55123 8554`, `VOLUME /config`, `WORKDIR /app/ring-mqtt`, `CMD ["/start.sh"]`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "ring-mqtt" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=tsightler/ring-mqtt versioning=semver
  default = "5.9.3"
}
variable "GO2RTC_VERSION" {
  // renovate: datasource=github-releases depName=AlexxIT/go2rtc versioning=semver
  default = "1.9.14"
}
variable "LICENSE" { default = "MIT" }   // UNVERIFIED, confirm from LICENSE
variable "SOURCE"  { default = "https://github.com/tsightler/ring-mqtt/" }
```
`image` target passes `VERSION` and `GO2RTC_VERSION` as args. Standard four targets and default group from `apps/adguardhome-sync`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/tsightler/ring-mqtt/"
ports:
  - port: 55123
    protocol: tcp
    required: false
  - port: 8554
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - mosquitto   # ✅ apps/mosquitto exists; any MQTT broker works, broker URL is set in config.json (mqtt_url)
```
Only `TZ` is declared because no other env var is verified for 5.9.3. `/data` is not listed: it is a symlink to `/config`. Note in the PR that `/data` mounts must move to `/config`.

## 7. start.sh

- `set -euo pipefail`. `mkdir -p /config`.
- Seed `/config/config.json` from `/defaults/config.json` only if missing (`cp -n`), never overwrite. Do not write secrets or env-derived values into it (no verified env mapping).
- Start go2rtc in the background (`/usr/local/bin/go2rtc -config /tmp/go2rtc.yaml`) with a config generated into `/tmp` that listens on `0.0.0.0:8554` and keeps the API on `127.0.0.1:1984` (UNVERIFIED: upstream may configure and launch go2rtc itself from `scripts/start-ring-mqtt.sh`; read it and reproduce exactly, preferring upstream's own launcher).
- `trap 'kill 0' TERM INT` so go2rtc stops with the app.
- `cd /app/ring-mqtt && exec node ring-mqtt.js` (confirm entry file name; present in the repo listing). Without a token the app starts its auth web service on 55123 (verified in docs), so an empty `/config` start works and stays alive.
- Listens on all interfaces: verify 55123 is reachable from another container (UNVERIFIED binding).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '55123'
- port: '8554'
filePaths:
- /start.sh
- /app/ring-mqtt/ring-mqtt.js
- /usr/local/bin/go2rtc
- /usr/share/licenses/ring-mqtt
```
Both ports have a tcp probe. The tests run with no env and an empty `/config`, which is exactly the token-less path that opens 55123. Port 8554 depends on go2rtc starting unconditionally in `start.sh`; if upstream only opens it lazily, adjust the launcher (or move that port to `required: false` without a probe is NOT allowed, so fix the launcher instead). The Ring login and MQTT path cannot be tested without an account and a broker: run it manually.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
|---|---|
| `/data` (config.json, ring-state.json) chmod 777 | symlink `/data` to `/config`; seed config in start.sh |
| `npm install` at build | done at build into `/app/ring-mqtt`, read-only afterwards |
| `BRANCH` env (git pulls code at start into `/app`) | not supported, would write to `/app` |
| s6-overlay, bashio, `/run` chmod 777 | removed; plain bash start script |
| go2rtc config and state | `/tmp/go2rtc.yaml`; go2rtc caches in `/tmp` |
| npm cache | `/tmp/.npm` |

Draft expected UID 0 and writable rootfs; this plan uses UID `apps` and a read-only rootfs. Extra persistence `/data` PVC plus `/data/config.json` configmap: remap to `/config` and a seeded file that users may replace by mounting over `/config/config.json`.

## 10. Risks, caveats and open questions

- First start needs a Ring login with 2FA via the 55123 web UI, or `init-ring-mqtt.js`; the token is stored in `/config/ring-state.json`. Cannot be exercised in CI.
- The upstream s6 scripts were not readable (404 on `init/s6/...`, `scripts/start-ring-mqtt.sh` paths guessed). Read the actual v5.9.3 tree before writing start.sh.
- No env-based MQTT configuration is verified, so users must edit `/config/config.json`. Consider adding documented env mapping only after reading the scripts.
- Streaming needs 8554 reachable; go2rtc 1984 API stays internal. Draft listed 1984; not exposed here.
- Node version of python-node base not checked. License type not checked. go2rtc newer than upstream pin (1.9.15 vs 1.9.14).
- No arm64 blocker (Node + go2rtc arm64 binary exists per upstream Dockerfile).
- UNVERIFIED count: 9.

## 11. Build and test steps

```sh
cd apps/ring-mqtt
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create ring-mqtt-probe-config
docker run --rm -d --name ring-mqtt-probe --read-only --tmpfs /tmp \
  -v ring-mqtt-probe-config:/config ring-mqtt:<version>
docker logs -f ring-mqtt-probe   # expect the token-less web authentication message on port 55123, no crash loop
docker rm -f ring-mqtt-probe; docker volume rm ring-mqtt-probe-config
forgetool containers test --image ring-mqtt:<version> --config ./apps/ring-mqtt/container-test.yaml
```
Manual: with a real Ring account and an `apps/mosquitto` broker on the same network, set `mqtt_url` in `/config/config.json`, complete the login, and watch `mosquitto_sub -t 'ring/#'`.

## 12. PR checklist

- Branch `feat/add-ring-mqtt`; commit and PR title `feat(ring-mqtt): add new container`; target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State what was not tested: anything not actually run, in particular the Ring login, MQTT publishing, camera streaming through go2rtc, arm64, and the `/data` to `/config` migration.
