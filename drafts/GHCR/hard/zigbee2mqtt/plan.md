# zigbee2mqtt — implementation plan
> Source: ./draft.md · Target: apps/zigbee2mqtt/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Latest stable | 2.14.3, published 2026-11-01, not prerelease (draft matches) | https://api.github.com/repos/Koenkk/zigbee2mqtt/releases/tags/2.14.3 |
| Renovate | datasource=github-releases depName=Koenkk/zigbee2mqtt versioning=semver (renovate config not checked; confirm) | UNVERIFIED: renovate config not fetched |
| License | GPL-3.0 | https://api.github.com/repos/Koenkk/zigbee2mqtt |
| Release assets | none; only the source archive https://github.com/Koenkk/zigbee2mqtt/archive/refs/tags/2.14.3.tar.gz | GitHub API |
| Checksum source | UNVERIFIED: no published checksum for the source archive seen | — |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/Koenkk/zigbee2mqtt/2.14.3/docker/Dockerfile | fetched |

Upstream Dockerfile summary:
- Base `alpine:3.24`, with stages `base`, `deps`, `release`.
- Base apk: tzdata, eudev, tini, nodejs. Build-only in `deps`: make, gcc, g++, python3, linux-headers, npm, jq.
- Deps: pnpm version from `package.json` `packageManager`; `pnpm install --frozen-lockfile --prod --no-optional`; rebuilds `@serialport/bindings-cpp` from source.
- Release stage copies `node_modules`, `dist`, `package.json`, `LICENSE`, `index.js`, `data/configuration.example.yaml`, and `docker/docker-entrypoint.sh` to `/usr/local/bin/`.
- `ENV NODE_ENV=production`, `WORKDIR /app`, `mkdir /app/data`.
- `ENTRYPOINT ["docker-entrypoint.sh"]`, `CMD ["/sbin/tini","--","node","index.js"]`.
- `EXPOSE 8080`. No VOLUME, no USER (root).

Ports: 8080 is confirmed. The draft's 8080 frontend note is consistent. Real env vars: only `NODE_ENV` is confirmed on the Dockerfile. Config and data path beyond `/app/data`: UNVERIFIED.

## 2. Target layout

Files in `apps/zigbee2mqtt/`:
- `Dockerfile`: required.
- `docker-bake.hcl`: required.
- `settings.yaml`: required.
- `container-test.yaml`: required.
- `start.sh`: required, to seed `/config/configuration.yaml` and `exec` the app.
- `defaults/configuration.example.yaml`: needed, because the upstream example is the seed source. Reason: no seed exists in the image otherwise.
- Not used: `root/`. No `DOWNSTREAM_CHANGES.md`; not a `FROM` base.

## 3. Base image

- `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`, as the draft proposes. Node is needed; the python part is unused.
- Closest sibling: `apps/changedetection` or `apps/budge`.
- Open question: the Node major in `python-node` must satisfy zigbee2mqtt 2.14.3 `engines`. UNVERIFIED: `package.json` engines not fetched. Check before the first build.

## 4. Dockerfile

Build from source in a build stage, then copy into the ubuntu runtime. The release has no binary, so we build it ourselves.

1. `FROM <python-node digest> AS build`. Install pnpm via `npm install -g pnpm@<version from packageManager>`, where the version is read from the source tree. Do not use a floating version.
2. `ARG VERSION` and `ARG TARGETARCH`. Download `https://github.com/Koenkk/zigbee2mqtt/archive/refs/tags/${VERSION}.tar.gz` with curl to `/tmp`, verify the checksum (UNVERIFIED: no published checksum, so record the sha256 of the tarball in the Dockerfile after the first download and note it as self-computed), extract to `/tmp/src`.
3. In `/tmp/src`: `pnpm install --frozen-lockfile --prod` then build `dist` as upstream CI does (UNVERIFIED: build script name; check `package.json` scripts).
4. Final stage `FROM <ubuntu digest>` only if the python-node base is not used. Otherwise, stay on python-node and copy `/tmp/src` to `/app`.
   - Preferred: keep the python-node base, so Node is present. Then the runtime copy is `COPY --from=build --chown=apps:apps /tmp/src /app`. Because `/app` is read-only at runtime, do this as `USER root`, then `USER apps`.
5. Ship the LICENSE to `/usr/share/licenses/zigbee2mqtt/`.
6. `ENV HOME=/config` and `ENV TMPDIR=/tmp`.
7. `USER apps`, then `COPY --chmod=0755 . /`.
8. `EXPOSE 8080`, `VOLUME /config`, final `USER apps`.

Do not compile Go here, since none is needed. Do not run `chown -R` on `/app` beyond what the copy needs.

## 5. docker-bake.hcl

- `variable "APP" { default = "zigbee2mqtt" }`
- `variable "VERSION"` with `// renovate: datasource=github-releases depName=Koenkk/zigbee2mqtt versioning=semver` and `default = "2.14.3"`.
- `variable "LICENSE" { default = "GPL-3.0-only" }`. The repo reports `GPL-3.0`, so use the SPDX id the repo reports, `GPL-3.0`, and confirm.
- `variable "SOURCE" { default = "https://github.com/Koenkk/zigbee2mqtt" }`
- Standard targets: `docker-metadata-action`, `image`, `image-local`, `image-all`, `group "default"`.
- Validate with `docker buildx bake --print`.

## 6. settings.yaml

- Schema header and `schema_version: 1`, `upstream_env_url: "https://github.com/Koenkk/zigbee2mqtt"`.
- `ports`: 8080/tcp, `required: false`.
- `env`: `TZ` default `Etc/UTC`. Add `NODE_ENV` only if `start.sh` sets it explicitly. Config-path env var: UNVERIFIED, do not add until the upstream docs are fetched.
- `volumes`: `/config`, `required: true`.
- `dependencies`: none in the image. The MQTT broker is an external service, not a ContainerForge dependency here, unless a sibling mosquitto app exists (check `apps/`).

## 7. start.sh

- Seed `/config/configuration.yaml` from `/app/data/configuration.example.yaml` only when missing: `[ -f /config/configuration.yaml ] || cp /defaults/configuration.yaml /config/configuration.yaml`.
- Point the app's data directory at `/config` through the upstream config key `data` or the `ZIGBEE2MQTT_DATA` variable. UNVERIFIED: the exact variable name; confirm in the upstream docs before writing it.
- Never write to `/app`. Caches go to `/tmp`.
- `cd /app` then `exec node index.js` (or `exec tini -- node index.js` if tini is available). Keep signals working.
- Bind the frontend to `0.0.0.0`. Check the upstream `frontend.host` default; set it in the seeded config only when missing.

## 8. container-test.yaml

- forgetool schema header.
- `tcp: - port: '8080'` with `timeoutSeconds` from a node sibling.
- `filePaths`: `/app/index.js`, and `/config/configuration.yaml` after seeding, if the schema allows.
- Runs with no env vars and no serial device. The app must start and stay up without a coordinator; the serial error path needs checking in the protocol run. Put the serial-path code path in `filePaths` only if the schema supports it.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root. We run as `apps`.
- The Zigbee USB coordinator is hardware: the device must be passed in and readable by `apps`. Use `--group-add` with the host device group and document this in the chart. Not solvable inside the image.
- Writes: `/config` for the database (`database.db`) and logs; `/tmp` for caches. Confirm the log directory location upstream (UNVERIFIED).
- Probe with `--read-only --tmpfs /tmp` and a fresh `/config`.
- Draft's security expectations (root, no read-only, common `/data` persistence): the chart's `/data` is a chart path. Map it to `/config` in our image. Reconcile the expectation in the chart, not the image.

## 10. Risks, caveats and open questions

- Blocker: USB serial coordinator passthrough and permissions (hardware, deployment-level).
- Build reproduction: the upstream image is built on alpine from CI artifacts; we rebuild from the source tarball, so the dist and dependency tree may differ. Verify `dist` exists after the build.
- Native `@serialport/bindings-cpp` built on Ubuntu: confirm the build tools exist in the build stage (they do not in python-node by default; install under root in the build stage only).
- Node version compatibility: UNVERIFIED (see section 3).
- No checksum for the source tarball: self-compute and document.
- Port 8080 frontend and `/app/data` path confirmed on the Dockerfile; other paths UNVERIFIED.
- Renovate config not checked.

## 11. Build and test steps

From `apps/zigbee2mqtt/`, per the build-test protocol:
1. `docker buildx bake --print`.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker run --rm -d --name zigbee2mqtt-probe --read-only --tmpfs /tmp -v zigbee2mqtt-probe-config:/config zigbee2mqtt:2.14.3`, then `docker logs -f zigbee2mqtt-probe`. Expected readiness: a frontend "listening" line on 8080, and the process running. Confirm the exact line after the first run.
4. `forgetool containers test --image zigbee2mqtt:2.14.3 --config ./container-test.yaml`.
5. Clean up: `docker rm -f zigbee2mqtt-probe; docker volume rm zigbee2mqtt-probe-config`.
6. arm64 build only if the amd64 build fails for an arm64 reason.

## 12. PR checklist

- Branch `feat/add-zigbee2mqtt`, commit `feat(zigbee2mqtt): add new container`, target `main`.
- Title: `feat(zigbee2mqtt): add new container`.
- PR description from `.github/PULL_REQUEST_TEMPLATE.md`, keeping sections and checkboxes. Check only the boxes that apply.
- Notes: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- Untested list: build, probe and test steps not run; coordinator passthrough; the config-path variable; arm64 build.
