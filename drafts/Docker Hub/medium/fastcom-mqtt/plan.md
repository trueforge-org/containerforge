# fastcom-mqtt — implementation plan
> Source: ./draft.md · Target: apps/fastcom-mqtt/ · Difficulty: medium (arm64 blocked, see section 10) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

**Edition differs from the draft.** The draft copies `simonjenny/fastcom-mqtt` (a 2021 Docker image: Node 14, `google-chrome-stable`, `npm i puppeteer`, `npm i fast-cli`, a `run` bash loop). That repo has **no tags, no releases and no LICENSE file** (the raw `LICENSE` returned 404), so it cannot supply a version or a license. This plan rebuilds the same behaviour on the current stack: it versions the image by the **`fast-cli` npm package, `6.0.0`** (the tool that does the measuring, MIT, requires Node `>=22.12.0`), and ships a new `start.sh` modelled on the upstream `run` script (commit `ce67907`, still repo HEAD). The user-visible contract (env vars `SLEEP`, `MQTT_SERVER`, `MQTT_DOWN`, `MQTT_UP`, `MQTT_USER`, `MQTT_PASS`) is kept.

| Item | Value |
| --- | --- |
| Version | `6.0.0` (npm `fast-cli`; tag `v6.0.0` also exists on `sindresorhus/fast-cli`) |
| Renovate | `datasource=npm depName=fast-cli` |
| License | MIT (`fast-cli` npm metadata). Bundled: `puppeteer` (Apache-2.0). The wrapper script is new work in this repo. SPDX for the image: `MIT`. UNVERIFIED: the licenses of the dependencies of `fast-cli` (`ink`, `meow`, `react`, ...), which were not audited. |
| Source | https://github.com/sindresorhus/fast-cli (tool) and https://github.com/simonjenny/fastcom-mqtt (wrapper that the draft names) |
| Download | npm: `npm install fast-cli@6.0.0` (registry tarball https://registry.npmjs.org/fast-cli/-/fast-cli-6.0.0.tgz). Chrome: downloaded by puppeteer's installer into `PUPPETEER_CACHE_DIR` at install time (amd64 Chrome for Testing). |
| Checksum | npm verifies the registry integrity hash (sha512 listed in the registry metadata). No separate checksum for Chrome; puppeteer's installer downloads it over HTTPS. |
| Upstream Dockerfile reviewed | https://github.com/simonjenny/fastcom-mqtt/blob/ce67907/Dockerfile (`node:14-slim`, installs `wget gnupg mosquitto-clients`, adds Google's apt repo `[arch=amd64]` for `google-chrome-stable libxss1`, `npm i puppeteer`, `npm i fast-cli`, `COPY run`, `CMD /usr/src/app/run`). The `run` script and README were also read. |

Facts read from `fast-cli` 6.0.0 (`readme.md`, `distribution/api.js` on unpkg):

- Flags: `--upload/-u`, `--single-line`, `--json`, `--verbose`. `--json` prints `downloadSpeed`, `uploadSpeed`, `downloadUnit`, `uploadUnit`, `downloaded`, `uploaded`, `latency`, `bufferBloat`, `userLocation`, `serverLocations` (speeds in Mbps per the README example).
- It launches Chrome with `--no-sandbox --disable-setuid-sandbox --disable-dev-shm-usage --ignore-certificate-errors`, headless. If no browser exists in the puppeteer cache, it installs Chrome on demand.
- Dependencies: `puppeteer ^25.12.0`, `@puppeteer/browsers ^3.2.3`, `ink`, `meow`, `react`.

Upstream `run` behaviour: loop forever; run `fast --upload --single-line`, parse the 5th and 9th fields with `cut`, publish with `mosquitto_pub` to `MQTT_DOWN` and `MQTT_UP` (with `-u/-P` only when `MQTT_PASS` is set), `sleep $SLEEP`. The README example has a typo (`MQTT_SERVER_`); the script itself reads `MQTT_SERVER`.

## 2. Target layout

```
apps/fastcom-mqtt/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

No `defaults/`. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

The draft chose python-node for the Node runtime; Python itself is not used. UNVERIFIED: whether plain `ghcr.io/trueforge-org/ubuntu` already carries Node (its Dockerfile has a `NODE_VERSION` install step); if it does, ubuntu is the leaner choice. `fast-cli` 6.0.0 needs Node `>=22.12.0`; confirm `node --version` in the build. Closest sibling: `apps/budge` (python-node, `npm install` into `/app`).

## 4. Dockerfile

1. `FROM` from section 3, `ARG VERSION`, `ARG TARGETARCH`.
2. `USER root`.
3. `ENV HOME=/tmp NPM_CONFIG_CACHE=/tmp/.npm PUPPETEER_CACHE_DIR=/app/puppeteer`. (Chrome is installed into `/app`, which is read-only at runtime; the profile and crash dirs go to `/tmp`.)
4. One `RUN` layer:
   - `apt-get update && apt-get install -y --no-install-recommends mosquitto-clients jq ca-certificates` plus the shared libraries Chrome needs. Candidate set for Ubuntu 26.04 (names UNVERIFIED, resolve with `ldd` on the downloaded `chrome` binary): `libnss3 libatk1.0-0t64 libatk-bridge2.0-0t64 libcups2t64 libdrm2 libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 libgbm1 libasound2t64 libpango-1.0-0 libcairo2 libx11-xcb1 libxss1 fonts-liberation`. Skip any the base already provides. `mosquitto-clients` is a tool, not the tagged software, so it is not pinned to `VERSION`; note this in a comment. `jq` is already in the ubuntu base (check before installing).
   - `mkdir -p /app/fastcom /usr/share/licenses/fastcom-mqtt`
   - `cd /app/fastcom && npm install --omit=dev --no-audit --no-fund "fast-cli@${VERSION}"` (this also runs puppeteer's postinstall, which downloads Chrome into `PUPPETEER_CACHE_DIR`). Do not skip the download on amd64.
   - Licenses: `cp node_modules/fast-cli/license /usr/share/licenses/fastcom-mqtt/LICENSE` and `cp node_modules/puppeteer/LICENSE /usr/share/licenses/fastcom-mqtt/puppeteer-LICENSE` (filenames UNVERIFIED, adjust to the installed package).
   - `chown -R apps:apps /app && chmod -R 755 /app`, `npm cache clean --force`, `apt-get clean`, `rm -rf /var/lib/apt/lists/* /tmp/*`
5. `USER apps`
6. `COPY --chmod=0755 . /`
7. `WORKDIR /app/fastcom`. No `EXPOSE` (the app has no listening port). `VOLUME /config` is optional: nothing is persisted; keep it for consistency only if maintainers want it, else omit it and the `volumes` entry.

arm64: on `linux/arm64` the puppeteer download has no Chrome for Testing build (UNVERIFIED, see section 10). Do not claim arm64 support until a run proves it.

## 5. docker-bake.hcl

```hcl
variable "APP" {
  default = "fastcom-mqtt"
}

variable "VERSION" {
  // renovate: datasource=npm depName=fast-cli
  default = "6.0.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/simonjenny/fastcom-mqtt"
}
```

Plus `docker-metadata-action`, `image`, `image-local` (tag `${APP}:${VERSION}`), `image-all` and the default group, copied from `apps/adguardhome-sync/docker-bake.hcl`. If arm64 does not work, set `image-all` platforms to `linux/amd64` only, with a comment saying why. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/simonjenny/fastcom-mqtt"
ports: []
env:
  - name: MQTT_SERVER
    default: ""
    required: false
  - name: MQTT_PORT
    default: "1883"
    required: false
  - name: MQTT_DOWN
    default: "fastcom/download"
    required: false
  - name: MQTT_UP
    default: "fastcom/upload"
    required: false
  - name: MQTT_USER
    default: ""
    required: false
  - name: MQTT_PASS
    default: ""
    required: false
  - name: SLEEP
    default: "3600"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes: []
opt_dependencies:
  - name: mosquitto
```

`MQTT_SERVER`, `MQTT_DOWN`, `MQTT_UP`, `MQTT_USER`, `MQTT_PASS` and `SLEEP` are the upstream variable names. The topic defaults (`fastcom/download`, `fastcom/upload`) and `MQTT_PORT` are new in this port (upstream has no defaults and no port setting; its README example uses `edge/down` and `edge/up`). `MQTT_SERVER` is `required: false` with an empty default because the test harness starts the image with no env; `start.sh` idles with a clear message when it is empty. The broker is an external dependency, optional in the sense of the schema; `apps/mosquitto` exists ✅.

There are no ports, so there is nothing to probe with tcp/http.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

: "${SLEEP:=3600}" "${MQTT_PORT:=1883}"
: "${MQTT_DOWN:=fastcom/download}" "${MQTT_UP:=fastcom/upload}"
export HOME=/tmp
export PUPPETEER_CACHE_DIR=/app/puppeteer

# Keep the MQTT password out of the process list: pass credentials through an options file in /tmp.
opts=/tmp/mosquitto-pub.opts
umask 077
: > "$opts"
[ -n "${MQTT_USER:-}" ] && printf -- '-u %s\n' "$MQTT_USER" >> "$opts"
[ -n "${MQTT_PASS:-}" ] && printf -- '-P %s\n' "$MQTT_PASS" >> "$opts"

touch /tmp/fastcom-mqtt.ready

if [ -z "${MQTT_SERVER:-}" ]; then
  echo "[start.sh] MQTT_SERVER is not set; nothing to publish to. Idling." >&2
fi

while true; do
  if [ -n "${MQTT_SERVER:-}" ]; then
    echo "Running bandwidth test..."
    if json="$(/app/fastcom/node_modules/.bin/fast --upload --json)"; then
      down="$(jq -r 'if .downloadUnit=="Gbps" then .downloadSpeed*1000 elif .downloadUnit=="Kbps" then .downloadSpeed/1000 else .downloadSpeed end' <<<"$json")"
      up="$(jq -r 'if .uploadUnit=="Gbps" then .uploadSpeed*1000 elif .uploadUnit=="Kbps" then .uploadSpeed/1000 else .uploadSpeed end' <<<"$json")"
      echo "down=${down} Mbps up=${up} Mbps; sending to MQTT (${MQTT_SERVER}:${MQTT_PORT})"
      mosquitto_pub -o "$opts" -h "$MQTT_SERVER" -p "$MQTT_PORT" -t "$MQTT_DOWN" -m "$down" || echo "publish of download value failed" >&2
      mosquitto_pub -o "$opts" -h "$MQTT_SERVER" -p "$MQTT_PORT" -t "$MQTT_UP" -m "$up" || echo "publish of upload value failed" >&2
    else
      echo "bandwidth test failed; retrying after ${SLEEP}s" >&2
    fi
  fi
  echo "Waiting for ${SLEEP} seconds..."
  sleep "$SLEEP"
done
```

- A deliberate change from the upstream `run`: results are parsed from `--json` with `jq` instead of `cut` on the single-line output (the output format changed since 2021, and field positions are fragile), and `fast` is invoked from the npm install path. Speeds are published in Mbps as before.
- UNVERIFIED: that the `mosquitto_pub` shipped in Ubuntu 26.04 accepts `-o <file>` (options file). If not, fall back to the environment-based `MOSQUITTO_*` mechanism if it exists, else accept the password on the command line and document the exposure.
- Idempotent and stateless; no writes to `/app` or `/config`. Chrome's profile and caches use `HOME=/tmp`.
- Failure of a single test or publish does not exit the loop (upstream never exits either).
- No listening socket, so there is no bind address to set. The script is the final long-running process and is started by the base entrypoint via tini; the `while` loop is the process, and `sleep` is a child, so SIGTERM stops it between runs (add `trap 'exit 0' TERM INT` if shutdown is slow).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

healthCommands:
- command: test -f /tmp/fastcom-mqtt.ready
- command: mosquitto_pub --help
  expectedExitCode: 0
- command: /app/fastcom/node_modules/.bin/fast --help

filePaths:
- /app/fastcom/node_modules/.bin/fast
- /usr/bin/mosquitto_pub
- /usr/bin/jq
- /usr/share/licenses/fastcom-mqtt/LICENSE
```

- `settings.yaml` lists no ports, so no tcp/http probe is required; the checks above prove the entry script is running (`/tmp/fastcom-mqtt.ready` is created by `start.sh`) and that every tool exists.
- UNVERIFIED: whether `mosquitto_pub --help` returns exit code 0 (some builds return 1); adjust `expectedExitCode` to the observed value rather than dropping the check. Also whether `fast --help` exits 0.
- The test sets no env vars and has no network assumptions, so the real speed test and MQTT publish path are not exercised here and must be run by hand (section 11).
- No DB dependency, so no narrowing.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/tmp/fastlog` (`run` script) | Not used; the JSON output stays in a shell variable. |
| `/home/pptruser`, `/home/pptruser/Downloads` (upstream chown for puppeteer) | `HOME=/tmp`. |
| Chrome user-data dir, crash dumps, shared memory | `/tmp` (fast-cli passes `--disable-dev-shm-usage`). If Chrome complains, add `--tmpfs /tmp` size or `--shm-size`. |
| Puppeteer's Chrome download | At image build time into `/app/puppeteer` (read-only at runtime). If `/app/puppeteer` is missing at runtime fast-cli would try to download into it and fail, so the build must succeed on the Chrome install. |
| npm cache | `/tmp/.npm`. |
| MQTT credentials | Options file in `/tmp`, mode 0600, regenerated every start. |
| Chart runs as root with writable rootfs | Runs as `apps`, read-only rootfs. The `--no-sandbox` Chrome flag is already set by fast-cli, so no root or user-namespace privilege is required. |

No extra persistence (the draft expects none), so `/config` is unused.

## 10. Risks, caveats and open questions

- **arm64 is likely blocked.** Google Chrome packages and Chrome for Testing are x86-64 Linux; upstream's own Dockerfile adds the Google apt repo with `[arch=amd64]` only. Puppeteer's installer may have no linux-arm64 Chrome (UNVERIFIED). Options: ship amd64 only, or find a Chromium build for arm64 (Ubuntu's `chromium` is a snap transitional package, UNVERIFIED, likely unusable in a container). Decide before the PR; the draft claims arm64 `yes`, and this plan does not confirm it.
- **Not a straight port.** Upstream is Node 14 with unpinned `npm i puppeteer`/`fast-cli`. With Node 22+ and `fast-cli` 6.0.0 the CLI output format and Chrome behaviour differ, so the wrapper uses `--json`. Behaviour against fast.com's current page is untested.
- **License gap.** The `simonjenny/fastcom-mqtt` repo has no LICENSE; the script here is new code written for this repo, so the image license is that of `fast-cli` (MIT). Dependency licenses (`puppeteer` Apache-2.0, others) were not fully audited.
- **Image size.** Chrome plus its libraries adds several hundred MB. Verify the final size.
- The speed test needs outbound internet and a reachable MQTT broker (user supplied; `apps/mosquitto` can be one). Neither is available in the test suite.
- Draft caveat (Chrome needs `/tmp` profiles and a non-root user) is addressed by `HOME=/tmp` and the existing `--no-sandbox` flag; UNVERIFIED until a real run.
- Renovate tracks the npm package only. Puppeteer's pinned Chrome build changes with `fast-cli` bumps, so each bump needs a rebuild test.
- `jq` and `mosquitto-clients` versions are unpinned (tools, not the tagged software).

## 11. Build and test steps

```sh
cd apps/fastcom-mqtt
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker run --rm -d --name fastcom-mqtt-probe --read-only --tmpfs /tmp \
  -v fastcom-mqtt-probe-config:/config fastcom-mqtt:6.0.0
docker logs -f fastcom-mqtt-probe

# from the repo root
forgetool containers test \
  --image fastcom-mqtt:6.0.0 \
  --config ./apps/fastcom-mqtt/container-test.yaml

docker rm -f fastcom-mqtt-probe; docker volume rm fastcom-mqtt-probe-config
```

Readiness signal with no env: `MQTT_SERVER is not set ... Idling.` and `Waiting for 3600 seconds...`, the container stays running. Functional run (by hand, not covered by forgetool): start a `apps/mosquitto` container on a Docker network, run this image with `-e MQTT_SERVER=<broker> -e SLEEP=60` on `--read-only --tmpfs /tmp`, expect `Running bandwidth test...`, a `down=... up=...` line, and the two values on `mosquitto_sub -t 'fastcom/#'`. Also run once with `MQTT_USER` and `MQTT_PASS` to check the options-file path.

## 12. PR checklist

- Branch `feat/add-fastcom-mqtt`, commit and PR title `feat(fastcom-mqtt): add new container`, target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, check only what applies.
- Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it. The `license/cla` check shows the status.
- Say in the PR that the version tracks `fast-cli` (npm), that the wrapper script is new, and which platforms were verified.
- Pre-completion: bake `--print` exits 0, `ARG VERSION` equals the bake default, final `USER apps`, `COPY --chmod=0755 . /`, start on `--read-only --tmpfs /tmp` with an empty `/config`.
- Untested until run: the build (Chrome install and shared library set), an actual speed test, MQTT publishing with and without credentials, `mosquitto_pub -o`, arm64, and the forgetool run. State this in the PR; leave "Built container locally" unchecked if not done.
