# deconz — implementation plan
> Source: ./draft.md · Target: apps/deconz/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v2.33.2, published 2026-07-17. Matches the draft's chart tag `ghcr.io/deconz-community/deconz-docker:2.33.2`. Source: https://github.com/dresden-elektronik/deconz-rest-plugin/releases/tag/v2.33.2 |
| Renovate | `datasource=github-releases depName=dresden-elektronik/deconz-rest-plugin versioning=semver`. Caveat: the vendor .deb is not confirmed as a GitHub release asset (UNVERIFIED). |
| License | BSD-3-Clause for `deconz-rest-plugin` (https://api.github.com/repos/dresden-elektronik/deconz-rest-plugin). The gateway .deb is vendor software; its own license is UNVERIFIED (the vendor page returned no license text). Set `LICENSE` to the value confirmed for the shipped .deb before merging. |
| Source URL | https://github.com/dresden-elektronik/deconz-rest-plugin (draft links the vendor page https://www.dresden-elektronik.de/funk/software/deconz.html, which gave no version data) |
| Download amd64 | http://deconz.dresden-elektronik.de/ubuntu/stable/deconz-2.33.2-qt5.deb (HTTP 200 on curl HEAD, 2026-11-25) |
| Download arm64 | http://deconz.dresden-elektronik.de/debian/stable/deconz_2.33.2-debian-buster-stable_arm64.deb (HTTP 200 on curl HEAD, 2026-11-25). Debian buster build. |
| URL pattern | From upstream `download-deconz.sh` (https://raw.githubusercontent.com/deconz-community/deconz-docker/f23db7e09be257f35e3e753e69fda7494ea94d52/docker/download-deconz.sh): amd64 `ubuntu/${CHANNEL}/deconz-${VERSION}-qt5.deb`, arm64 `debian/${CHANNEL}/deconz_${VERSION}-debian-buster-${CHANNEL}_arm64.deb`. Plain HTTP only. |
| Checksum source | None. Upstream script downloads with curl and does not verify. We must compute and pin the sha256 ourselves in the Dockerfile (UNVERIFIED that the vendor publishes one elsewhere). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/deconz-community/deconz-docker/f23db7e09be257f35e3e753e69fda7494ea94d52/docker/Dockerfile: `FROM debian:12-slim`, Qt5 libs, curl, sqlite3, gosu, TigerVNC, noVNC, websockify, openbox, `dpkg -i /deconz.deb`, `setcap CAP_NET_BIND_SERVICE` on the binary, `VOLUME ["/opt/deCONZ"]`, `ENTRYPOINT ["/start.sh"]`, no `USER` (root unless `start.sh` drops privileges via `NON_ROOT`). |
| Ports (upstream) | `EXPOSE ${DECONZ_WEB_PORT} ${DECONZ_WS_PORT} ${DECONZ_VNC_PORT} ${DECONZ_NOVNC_PORT}`: web 80, websocket 443, VNC 5900, noVNC 6080. The draft's 80, 443, 8080 are partly inferred; use upstream values. |
| Env vars (upstream, confirmed by name) | `DEBIAN_FRONTEND=noninteractive`, `DECONZ_APPDATA_DIR=/opt/deCONZ`, `DECONZ_VNC_PASSWORD=changeme`, `DECONZ_UPNP=1`, `DECONZ_WEB_PORT`, `DECONZ_WS_PORT`, `DECONZ_VNC_PORT`, `DECONZ_NOVNC_PORT`, `NON_ROOT`, `DECONZ_UID`/`DECONZ_GID` (1000/1000). Exact numeric defaults for the port vars are UNVERIFIED (summary cut off). |
| Data path | `/opt/deCONZ` (VOLUME, `DECONZ_APPDATA_DIR`). |
| Health | Upstream HEALTHCHECK: `curl -I 127.0.0.1:${DECONZ_WEB_PORT}` every 10s. |
| Dependencies | None. Gateway state is local (UNVERIFIED for every sqlite/file path). |

## 2. Target layout

- `apps/deconz/Dockerfile`
- `apps/deconz/docker-bake.hcl`
- `apps/deconz/settings.yaml`
- `apps/deconz/container-test.yaml`
- `apps/deconz/start.sh`
- `apps/deconz/root/` is not used (reserved; do not touch). Upstream `root/` files are replaced by `start.sh` in the app folder.

No `defaults/`, `etc/`, `health/` needed. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base; check with `grep -r "FROM .*deconz" apps/` before merging).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for the final stage. The draft's reason (vendor .deb on ubuntu) fits the amd64 build, which is an Ubuntu qt5 package. Ubuntu 26.04 availability of the qt5 runtime libraries the .deb depends on is UNVERIFIED; check with `apt-cache policy` inside the base before relying on it. Closest siblings: an app that installs a vendor .deb onto ubuntu (search `apps/*/Dockerfile` for `dpkg -i` or `.deb`).

## 4. Dockerfile

1. Single stage is enough (no compile). `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Map arch: `amd64` -> `ubuntu/stable/deconz-${VERSION}-qt5.deb`, `arm64` -> `debian/stable/deconz_${VERSION}-debian-buster-stable_arm64.deb`. Fail the build on any other arch.
3. Install runtime deps: `apt-get install -y --no-install-recommends curl sqlite3 libqt5core5a libqt5network5 libqt5serialport5 libqt5websockets5 libqt5sql5 libqt5gui5` (exact list is UNVERIFIED: derive it from `apt-get install -f` / `dpkg -I` on the amd64 deb; do not install packages the base already has). Skip gosu, TigerVNC, noVNC, websockify, openbox (not needed for the gateway; VNC/noVNC are out of scope for this app).
4. Download the .deb with `curl -fL` to `/tmp/deconz.deb`, verify `sha256sum -c` against a pinned hash per arch (`ARG DECONZ_SHA256_AMD64`, `ARG DECONZ_SHA256_ARM64`). Compute the hashes from the downloaded files during implementation and record them with a comment; mark as own pin.
5. `apt-get install -y /tmp/deconz.deb` (lets apt resolve deps), then `rm -f /tmp/deconz.deb`, clean apt lists.
6. No `setcap`: `USER apps` must not bind ports below 1024, so the image defaults to 8080 (web) and 8443 (websocket) and the chart maps them. Find the binary path with `dpkg -L deconz` in the build (UNVERIFIED; `/usr/bin/deCONZ` is assumed).
7. Copy license files to `/usr/share/licenses/deconz/` if the .deb ships them (UNVERIFIED). Otherwise state the source of the license in `docker-bake.hcl` and PR.
8. `ENV DECONZ_APPDATA_DIR=/config DECONZ_WEB_PORT=8080 DECONZ_WS_PORT=8443 DECONZ_UPNP=0 HOME=/config` (the app data path moves from `/opt/deCONZ` to `/config`, see section 9). Do not set a default VNC password (no VNC in this app).
9. Tail:

```dockerfile
COPY --chmod=0755 . /
EXPOSE 8080 8443
VOLUME /config
USER apps
```

`USER apps` is the final directive; root-only steps (apt, dpkg) run before it.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "deconz" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=dresden-elektronik/deconz-rest-plugin versioning=semver
  default = "2.33.2"
}
variable "LICENSE" { default = "BSD-3-Clause" }   // confirm against the shipped .deb, see section 1
variable "SOURCE" { default = "https://github.com/dresden-elektronik/deconz-rest-plugin" }
```

Four standard targets (`docker-metadata-action`, `image`, `image-local`, `image-all`) and the `default` group, copied from `apps/adguardhome-sync`. `image-all` must build both platforms. `image` passes `args.VERSION` and OCI labels. Run `docker buildx bake --print` from `apps/deconz/` and require exit 0.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/dresden-elektronik/deconz-rest-plugin"
ports:
  - port: 8080
    protocol: tcp
    required: true
  - port: 8443
    protocol: tcp
    required: false
env:
  - name: DECONZ_WEB_PORT
    default: "8080"
    required: false
  - name: DECONZ_WS_PORT
    default: "8443"
    required: false
  - name: DECONZ_UPNP
    default: "0"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Only list env vars that `start.sh` or the app actually reads. Upstream `DECONZ_VNC_*` and `DECONZ_NOVNC_PORT` are dropped with VNC. Upstream defaults are 80 and 443; this image moves them to 8080 and 8443 because it runs rootless. Confirm the numeric defaults of `DECONZ_WEB_PORT` and `DECONZ_WS_PORT` from the upstream `root/` scripts before merging (UNVERIFIED). Dependencies: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config
export DECONZ_APPDATA_DIR=/config

web_port="${DECONZ_WEB_PORT:-8080}"
ws_port="${DECONZ_WS_PORT:-8443}"
upnp="${DECONZ_UPNP:-0}"

exec /usr/bin/deCONZ --dbg-info=1 --http-listen=0.0.0.0:"${web_port}" --ws-port="${ws_port}" --upnp="${upnp}" \
  --dbpath=/config/zll.db --configpath=/config
```

The flags above are UNVERIFIED: check the real option names with `deCONZ --help` inside the built image before finalizing. Requirements: idempotent, seed nothing (the gateway creates its database under `/config` on first start), no writes to `/app`, bind `0.0.0.0`, `exec` the final process. Note the gateway needs a radio device; without one it should still start and serve the web UI (verify this in the run step; if it exits, record it under section 10).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8080'
- port: '8443'
http:
- port: '8080'
  path: /
filePaths:
- /usr/bin/deCONZ
- /usr/share/licenses/deconz/LICENSE
```

Every port in `settings.yaml` has a probe (8080 tcp and http, 8443 tcp). The http probe path and the expected status are UNVERIFIED; confirm with the running container before fixing the probe. Tests run with no env vars, so the defaults above are what gets exercised. `filePaths` must list the real binary path (UNVERIFIED, see section 4 step 6). Do not weaken the 8443 probe if the gateway binds it late; wait instead by raising `timeoutSeconds`.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/opt/deCONZ` (`DECONZ_APPDATA_DIR`, VOLUME) | `/config` (env `DECONZ_APPDATA_DIR=/config`, persistent volume) |
| Gateway logs and temp files | `/tmp` (tmpfs under `--read-only --tmpfs /tmp`); set `HOME=/config` for any tool that writes dotfiles |
| `root/` helper scripts (`/start.sh`, `/firmware-update.sh`) | Not ported. `start.sh` in the app folder replaces them. `firmware-update.sh` is out of scope: flashing the radio needs privileged device access. |
| `deconz` user UID 1000 | Use the ContainerForge `apps` user. Upstream UID is not kept. |
| Device access (USB ConBee/RaspBee, `/dev/ttyACM*`) | Not a container-image concern. The chart must pass the device and add the host device group as a supplementary group. Document in the PR; do not add `privileged`. |

Security reconciliation with the draft: draft expects `readOnlyRootFilesystem: false`, `runAsUser 0`. The target is `USER apps`, read-only rootfs compatible, no extra capability: the gateway listens on 8080/8443, not 80/443. Privileged stays off.

## 10. Risks, caveats and open questions

- No checksum is published by upstream. We pin our own sha256 and say so in the PR (section 4 step 4).
- The arm64 package is a Debian buster build. Compatibility with the Ubuntu 26.04 base is UNVERIFIED; if it fails at runtime, arm64 is a blocker (note it and build amd64 only).
- The vendor `.deb` is downloaded over plain HTTP. Mitigated by the sha256 pin, but still worth noting.
- Default upstream VNC password (`changeme`) is dropped with VNC; confirm no VNC port is needed by the chart before merging.
- The chart's `/opt/deCONZ` path is not known to the chart's consumers as `/config`. Document the path change for chart authors.
- Hardware: the gateway is useless without a ConBee or RaspBee radio. Start-up without a radio is UNVERIFIED.
- Firmware update flow (`firmware-update.sh`) is not ported. Document as a caveat.
- Blocker rule: if `apt-get install` of the amd64 deb cannot resolve Qt5 deps on 26.04, stop and report; do not switch base silently.

## 11. Build and test steps

From `apps/deconz/`:

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker volume create deconz-probe-config`
   `docker run --rm -d --name deconz-probe --read-only --tmpfs /tmp -p 8080:8080 -v deconz-probe-config:/config ghcr.io/trueforge-org/deconz:2.33.2`
   `docker logs -f deconz-probe` until idle. Readiness signal: the web/HTTP listener line (UNVERIFIED exact text; take it from the first real run). Pass also needs: process still running, no fatal errors.
4. `forgetool containers test --image <image>:2.33.2 --config ./container-test.yaml`. If forgetool is unavailable, check the ports and files by hand.
5. Cleanup: `docker rm -f deconz-probe; docker volume rm deconz-probe-config`.

Also run with `--read-only --tmpfs /tmp` and an empty `/config` (step 3 does this). arm64 is attempted only if amd64 is green and time allows.

## 12. PR checklist

- Branch `feat/add-deconz` from `main`.
- Commit `feat(deconz): add new container`, with the Co-Authored-By line from the session attribution.
- PR title `feat(deconz): add new container`.
- PR body from `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes; check only what applies.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user the CLA is required: https://cla-assistant.io/trueforge-org/containerforge (only they can sign it; the `license/cla` check shows status).
- State honestly what is not tested: arm64 build and run, a real ConBee/RaspBee radio, the web UI unlock flow, and firmware update. Do not tick "Built container locally" unless the build and run were actually done.
- Downstream impact: confirm no `apps/*/Dockerfile` uses `FROM ...deconz`; if one does, add `DOWNSTREAM_CHANGES.md`.
