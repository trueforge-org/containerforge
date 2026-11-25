# valetudo-mapper — implementation plan
> Source: ./draft.md · Target: apps/valetudo-mapper/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | No releases or tags. `package.json` says `0.5.0`. Pin master commit `54aba3534e9e797b9a22c0e134fa2706effd2e9d` (2023-09-15, last push). Use `VERSION = "0.5.0"` and `VALETUDO_MAPPER_COMMIT` = that sha |
| Renovate | `datasource=git-refs depName=https://github.com/rand256/valetudo-mapper versioning=loose` on the commit variable |
| License | Apache-2.0 (GitHub API) |
| Source | https://github.com/rand256/valetudo-mapper |
| Download | `https://github.com/rand256/valetudo-mapper/archive/<commit>.tar.gz` (architecture independent) |
| Checksum | UNVERIFIED: none published; the commit URL is immutable |
| Dependencies | `jimp ^0.16.1`, `mqtt ^4.3.7`, `compression ^1.7.2`, `express ^4.18.1` (`package.json`); start script `node app.js`. No lockfile is listed in the repo (files: `.github .gitignore .travis.yml Dockerfile LICENSE README.md app.js assets lib package.json`), so `npm install` resolves fresh versions |
| Upstream Dockerfile | `FROM node:lts-alpine`, `npm install && touch config.json`, `COPY . /app`, `CMD ["npm","start"]` (reviewed). The README says to map the config at `/app/config.json` |

Behaviour (source of `app.js`, `lib/Configuration.js`, `lib/Webserver.js`): CLI `-f <path>` selects the config file, `-c` creates a custom config file; without `-f` it uses `../config.json` next to the app. If the file is missing it writes defaults (`persist()`), and it re-persists whenever the merged settings differ from the file, so the config location must be writable. The default config has an `mqtt` block (`broker_url: mqtt://user:pass@foobar.example`) and `webserver: {enabled: false, port: 3000}`. The web server starts only if `webserver.enabled === true`, serves `/api/map/image` and `/api/map/raw`, and calls `listen(port)` with no host (all interfaces). The app reads no environment variables.

## 2. Target layout

```
apps/valetudo-mapper/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  defaults/config.json
```
`defaults/config.json` is the seed for an empty `/config`: it is the upstream default config with `webserver.enabled` set to `true` (needed so port 3000 exists and can be probed). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image
`FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`

It is the repo's Node base (the draft names it as `ghcr.io/trueforge-org/python-node`); the Python part is unused. Closest sibling: `apps/budge` (python-node, `npm install` of a GitHub tarball, `start.sh` runs node). No native build is expected (jimp and mqtt are pure JavaScript), so no build packages.

## 4. Dockerfile
1. `ARG VERSION`, `ARG VALETUDO_MAPPER_COMMIT`, `USER root`, `ENV HOME=/tmp NPM_CONFIG_CACHE=/tmp/npm-cache NODE_ENV=production`.
2. `RUN mkdir -p /app/valetudo-mapper /usr/share/licenses/valetudo-mapper`; `curl -fsSL "https://github.com/rand256/valetudo-mapper/archive/${VALETUDO_MAPPER_COMMIT}.tar.gz" | tar xz -C /app/valetudo-mapper --strip-components=1`; `cd /app/valetudo-mapper && npm install --omit=dev`; copy `LICENSE` to `/usr/share/licenses/valetudo-mapper/`; `npm cache clean --force`; `rm -rf /tmp/*`.
3. `chown -R root:root /app/valetudo-mapper && chmod -R a+rX /app/valetudo-mapper`. The app and its `node_modules` stay read-only; the config moves to `/config` via `-f`.
4. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 3000`, `VOLUME /config`, `WORKDIR /config`.
No apt packages (the draft's `unzip` is unnecessary). If budge's note applies (npm 11 omitting optional peer deps, which it fixed by `npm install -g npm@10`), only add that if the install fails (UNVERIFIED for this app).

## 5. docker-bake.hcl
- `APP = "valetudo-mapper"`
- `VERSION = "0.5.0"`; `VALETUDO_MAPPER_COMMIT = "54aba3534e9e797b9a22c0e134fa2706effd2e9d"` with `// renovate: datasource=git-refs depName=https://github.com/rand256/valetudo-mapper versioning=loose` above it.
- `LICENSE = "Apache-2.0"`, `SOURCE = "https://github.com/rand256/valetudo-mapper"`
- Standard four targets and default group, `args` carries both. Validate with `docker buildx bake --print`.

## 6. settings.yaml
Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/rand256/valetudo-mapper"`.
- ports: `3000` tcp (map image/raw API; `required: false`, it is only open when `webserver.enabled` is true in the config, which the seeded default does).
- env: `TZ` (`Etc/UTC`, `required: false`) only. The app reads no env vars; MQTT broker, robot identifier and map settings live in `/config/config.json`. State this in the PR rather than inventing env vars.
- volumes: `/config` (required true; `config.json`).
- opt_dependencies: `mosquitto` ✅ (`apps/mosquitto` exists; an MQTT broker is required at runtime, but any broker works, and the draft lists no hard dependency).

## 7. start.sh
```bash
#!/usr/bin/env bash
if [[ ! -f /config/config.json ]]; then
  cp /defaults/config.json /config/config.json
fi
cd /app/valetudo-mapper
exec node app.js -f /config/config.json
```
Idempotent, seeds only when missing, nothing written to `/app`. The app may rewrite `/config/config.json` to add new default keys; that is on the persistent volume, so it is fine. The seeded `broker_url` stays the upstream placeholder `mqtt://user:pass@foobar.example`, so users MUST edit it (log that fact in start.sh when the placeholder is still present). The web server listens on all interfaces (verified in source, confirm from outside during the run test).

## 8. container-test.yaml
```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 180
tcp:
- port: '3000'
filePaths:
- /app/valetudo-mapper/app.js
- /config/config.json
- /usr/share/licenses/valetudo-mapper/LICENSE
```
A TCP probe is used because `/api/map/image` has no map to return until a robot publishes one (its status code with no data is UNVERIFIED). The test runs with no env and an empty `/config`, so it covers the seeding path via `/config/config.json`. The MQTT broker is not reachable in the test; the app is expected to keep retrying and the web server to stay up (UNVERIFIED).

## 9. Rootless and read-only-rootfs adaptations
- Writes: `config.json` (created or re-persisted at its `-f` path) → `/config`; npm cache → `/tmp/npm-cache` at build, nothing at runtime; no other write found in `app.js`, `Configuration.js`, `Webserver.js` (`MqttClient.js`/`RRMapParser.js` were not fully read, UNVERIFIED).
- Draft expects UID 0 and writable rootfs (TrueCharts) while saying it can run as `apps`: here `USER apps`, read-only rootfs compatible, no extra persistence beyond `/config`. The upstream default of `/app/config.json` is dropped because `/app` is read-only.

## 10. Risks, caveats and open questions
- Needs an MQTT broker and a rooted robot running the "Valetudo" firmware (rand256 fork); the mapper reads `valetudo/<identifier>/map_data` from MQTT, not directly from the LAN, so the robot IP is not needed here (the draft says otherwise). Verify against the README's MQTT flow.
- MQTT reconnect behaviour with the placeholder broker host is UNVERIFIED; if the process exits, the container test and the no-config start would fail. Mitigation: catch it in the first run, do not weaken the probe.
- No lockfile, so `npm install` is not reproducible across rebuilds; `jimp` 0.16 and `mqtt` 4 are old but pure JS.
- Last upstream activity 2023-09-15, so Renovate rarely proposes updates.
- No blockers (no musl, GPU, privileged or arm64 issue).

## 11. Build and test steps
```sh
cd apps/valetudo-mapper
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name valetudo-mapper-probe --read-only --tmpfs /tmp -v valetudo-mapper-probe-config:/config valetudo-mapper:0.5.0
docker logs -f valetudo-mapper-probe   # expect "Loading configuration file: /config/config.json" (message verified in source) and the web server listening line
nc -z <container-ip> 3000
docker rm -f valetudo-mapper-probe; docker volume rm valetudo-mapper-probe-config
forgetool containers test --image valetudo-mapper:0.5.0 --config ./apps/valetudo-mapper/container-test.yaml
```
Readiness signal: the "Loading configuration file" line (the file exists on the second start; on the first start the seeded file is loaded the same way) and port 3000 open, with no crash from MQTT.

## 12. PR checklist
- Branch `feat/add-valetudo-mapper`, commit `feat(valetudo-mapper): add new container`, target `main`.
- Fill in the PR template, check only the true boxes.
- `🤖 This PR is AI generated.` in the Notes section.
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State untested: MQTT publishing with a real broker and robot, arm64, the `npm install` result without a lockfile, and the web server with a real map.
