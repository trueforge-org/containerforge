# zwavejs2mqtt — implementation plan
> Source: ./draft.md · Target: apps/zwavejs2mqtt/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Latest stable | v11.27.0, published 2026-11-16, not prerelease (draft matches) | https://api.github.com/repos/zwave-js/zwave-js-ui/releases/tags/v11.27.0 |
| Renovate | datasource=github-releases depName=zwave-js/zwave-js-ui versioning=loose (tag has a `v` prefix; not checked against renovate config, so confirm) | UNVERIFIED: renovate config not fetched |
| License | MIT | https://api.github.com/repos/zwave-js/zwave-js-ui |
| amd64 binary | https://github.com/zwave-js/zwave-js-ui/releases/download/v11.27.0/zwave-js-ui-v11.27.0-linux.zip, sha256 `edac9b12c233d8aaa5234d636e53c313c414ec3990dd4b91e14a16444e69dca9` | GitHub release asset digest |
| arm64 binary | https://github.com/zwave-js/zwave-js-ui/releases/download/v11.27.0/zwave-js-ui-v11.27.0-linux-arm64.zip, sha256 `2acfc40bb67a64e4233cda5602d0c378194cee9abc4d7b21fcff33d4dae78ba8` | GitHub release asset digest |
| Checksum source | GitHub release asset digest (sha256) | api.github.com release URL above |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/zwave-js/zwave-js-ui/6aba3da40be776f8ee845de144477098978d3b74/docker/Dockerfile | fetched |

Upstream Dockerfile summary (for reference only; we use the prebuilt zips, not its build):
- Base `alpine:3.23`, Node `node:24.22.1-alpine3.23`. arm/v7 uses Alpine's packaged Node because Node 24 ships no 32-bit ARM binaries.
- Runtime apk: openssl, libusb, tzdata, eudev. WORKDIR `/usr/src/app`.
- `ENV NODE_ENV=production`, `ENV TAG_NAME=${image}`.
- `EXPOSE 8091`, `CMD ["node", "server/bin/www"]`. No VOLUME, no USER (root).

Env vars confirmed from upstream `docs/guide/env-vars.md`: `PORT` (8091), `HOST`, `STORE_DIR`, `BACKUPS_DIR`, `ZWAVEJS_EXTERNAL_CONFIG` (default `<store_dir>/.config-db`), `ZWAVE_PORT`. The Dockerfile itself only sets `NODE_ENV` and `TAG_NAME`; upstream image `WORKDIR` is `/usr/src/app`. The draft's `/usr/src/app/store` is the chart path and the port 3000 websocket server is UNVERIFIED.

## 2. Target layout

Files in `apps/zwavejs2mqtt/`:
- `Dockerfile`: required.
- `docker-bake.hcl`: required.
- `settings.yaml`: required.
- `container-test.yaml`: required.
- `start.sh`: required, to create `/config/store` on first run and `exec` the app.
- `defaults/`: only if a seed config is needed. Not expected here.
- Not used: `root/`, which is reserved. No `DOWNSTREAM_CHANGES.md`, since this app is not a `FROM` base.

## 3. Base image

- `FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`, as the draft proposes.
- Why: it provides Node for the prebuilt zip, and we keep the ubuntu-based runtime rules. The python part is unused.
- Open question: the Node major on python-node must be at least the upstream's Node 24 runtime, which we do not reproduce. Confirm the node version in the base before the first build.
- Closest sibling: any `python-node` app, such as `apps/changedetection` or `apps/budge`.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, then `USER root`.
2. Map TARGETARCH to the zip name: `amd64` gives `zwave-js-ui-v${VERSION}-linux.zip`, `arm64` gives `zwave-js-ui-v${VERSION}-linux-arm64.zip`. Fail the build on any other arch.
3. Download with curl to `/tmp`, verify with `echo "<sha256>  <file>" | sha256sum -c -`. Pick the sha256 by arch, so the digests from section 1 are hard-coded in the Dockerfile.
4. Extract with `unzip` to `/app` (install `unzip` with apt under root only if the base lacks it, and check that first).
5. Ship license: copy the LICENSE from the zip if present, else from the source repo, to `/usr/share/licenses/zwavejs2mqtt/`. UNVERIFIED: zip contents not inspected.
6. `ENV HOME=/config`, `ENV TMPDIR=/tmp`, `ENV STORE_DIR=/config/store`, `ENV NODE_ENV=production`.
7. `rm` the downloaded zip from `/tmp`.
8. `USER apps`, then `COPY --chmod=0755 . /`.
9. `EXPOSE 8091` and `EXPOSE 3000` (3000 only if confirmed, see section 10), `VOLUME /config`.
10. Final `USER apps`.

Do not run `chown -R` on `/app` if the zip already gives correct ownership. Check the extracted modes.

## 5. docker-bake.hcl

- `variable "APP" { default = "zwavejs2mqtt" }`
- `variable "VERSION"` with `// renovate: datasource=github-releases depName=zwave-js/zwave-js-ui versioning=loose` and `default = "11.27.0"`. Use the `v`-less form, matching the other apps, and strip the `v` in the download URL if needed.
- `variable "LICENSE" { default = "MIT" }`
- `variable "SOURCE" { default = "https://github.com/zwave-js/zwave-js-ui" }`
- Standard targets: `docker-metadata-action`, `image`, `image-local`, `image-all`, and `group "default"` with `image-local`.
- Validate with `docker buildx bake --print` in `apps/zwavejs2mqtt`.

## 6. settings.yaml

- Schema header and `schema_version: 1`.
- `upstream_env_url: "https://github.com/zwave-js/zwave-js-ui"`.
- `ports`: 8091/tcp, `required: false`.
- `env`: only variables the app reads. `TZ` default `Etc/UTC`, plus the documented `PORT` (default `8091`), `STORE_DIR` (default `/config/store`) and optionally `HOST` (empty). Do not add others without checking upstream `docs/guide/env-vars.md`.
- `volumes`: `/config`, `required: true`.
- `dependencies`: none.
- Note: the draft's device passthrough is not a settings field. Document it in the plan, not in settings.

## 7. start.sh

- `mkdir -p /config/store` only when missing, and do not touch existing files.
- Point the app's store to `/config/store` with `STORE_DIR=/config/store` (documented in upstream `docs/guide/env-vars.md`: absolute path, default `<zui dir>/store`; `BACKUPS_DIR` defaults to `<store_dir>/backups`).
- `cd /app` (read-only at runtime) and `exec node /app/server/bin/www` or the zip's real entry point. UNVERIFIED: the zip layout. Confirm after the first extraction.
- `HOST` empty (default) binds all interfaces; `PORT` default 8091 (upstream env-vars doc). Do not set `HOST` to localhost.

## 8. container-test.yaml

- forgetool schema header.
- `tcp: - port: '8091'` with a `timeoutSeconds` taken from a node sibling.
- Add a `tcp` probe for 3000 only if it is confirmed.
- `filePaths`: `/app` entry point and `/config/store` after first run, if the schema allows it.
- The test runs with no env vars and the USB serial device absent, so the app must start without a controller. Verify this in the protocol run, not only in the test.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root. We run as `apps` (UID from the base).
- Serial device: the controller needs `/dev/ttyACM*` or `/dev/serial/by-id/*` access. Rootless `apps` needs the device group added at run time (`--group-add`) or a udev rule on the host. This cannot be solved inside the image; it is a deployment requirement. Document it in the chart.
- Writes: store and logs go to `/config`, caches to `/tmp`. The `/app` tree must not be written at runtime.
- Read-only rootfs: run the probe with `--read-only --tmpfs /tmp` and a fresh `/config` volume, per the protocol.
- Draft's "possibly non-root and read-only" expectations are confirmed as achievable only if the app writes nothing outside `/config` and `/tmp`. UNVERIFIED until the probe.

## 10. Risks, caveats and open questions

- Blocker: USB Z-Wave controller passthrough and serial permissions (hardware, not image-only).
- Store data: losing `/config/store` means re-pairing all Z-Wave devices. Document the backup requirement.
- Upstream Dockerfile runs as root and uses alpine; our Ubuntu base differs. Test that the zip's binaries run on glibc (they are Node JS, so should be fine; verify native `@serialport` bindings are present in the zip).
- Port 3000 (websocket) comes from the draft only (UNVERIFIED). The draft's `/usr/src/app/store` is the chart path; this image uses `STORE_DIR=/config/store` instead, so existing users must move their data.
- Node version in `python-node` may not match Node 24 expectations of the zip. Verify at first run.
- Renovate config not checked.

## 11. Build and test steps

From `apps/zwavejs2mqtt/`, per `.github/instructions/build-test-protocol.instructions.md`:
1. `docker buildx bake --print`.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker run --rm -d --name zwavejs2mqtt-probe --read-only --tmpfs /tmp -v zwavejs2mqtt-probe-config:/config zwavejs2mqtt:11.27.0`, then `docker logs -f zwavejs2mqtt-probe`. Expected readiness signal: a "listening" or "server started" line on the web UI, and the process still running. Confirm the exact line after the first run.
4. `forgetool containers test --image zwavejs2mqtt:11.27.0 --config ./container-test.yaml`.
5. Clean up: `docker rm -f zwavejs2mqtt-probe; docker volume rm zwavejs2mqtt-probe-config`.
6. arm64 build only if the amd64 build fails for an arm64 reason.

## 12. PR checklist

- Branch `feat/add-zwavejs2mqtt`, commit `feat(zwavejs2mqtt): add new container`, target `main`.
- Title: `feat(zwavejs2mqtt): add new container`.
- PR description from `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes. Check only the boxes that apply.
- Notes: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it. The `license/cla` check shows status.
- Untested list: any build or probe not run; the serial device path; the store path; the port 3000 probe; the arm64 build.
