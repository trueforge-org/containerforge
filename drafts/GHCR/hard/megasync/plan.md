# megasync — implementation plan
> Source: ./draft.md · Target: apps/megasync/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version (upstream container) | Chart uses `ghcr.io/ich777/megasync:latest` (unversioned). The upstream repo has no GitHub releases (API returns 404 for `ich777/docker-megasync`). GHCR manifest not fetched: UNVERIFIED |
| MEGAsync version | `6.7.1-1.1` is the latest listed in the vendor repo directory for both architectures (`6.2.0-1.1` also listed). Sources: https://mega.nz/linux/repo/Debian_12/amd64/ and https://mega.nz/linux/repo/xUbuntu_24.04/arm64/ |
| Renovate | No clean datasource: the upstream Dockerfile scrapes the version from a directory listing. Annotation is UNVERIFIED (section 10) |
| License | Closed-source MEGA client, SPDX not confirmed: UNVERIFIED |
| Source / docs / site | https://github.com/meganz/MEGAsync (closed-source client, not fetched) · https://help.mega.io/installs-apps/desktop · https://mega.io/desktop |
| Upstream Dockerfile | https://raw.githubusercontent.com/ich777/docker-megasync/master/Dockerfile. `FROM ich777/novnc-baseimage`, `ARG DEBIAN_V="12"`. Version scraped from `https://mega.nz/linux/repo/Debian_${DEBIAN_V}/amd64/` (grep `megasync_.*_amd64.deb`) |
| Download URLs (verified) | amd64: `https://mega.nz/linux/repo/Debian_12/amd64/megasync_6.7.1-1.1_amd64.deb` (HTTP 200, 54008336 bytes). arm64: `https://mega.nz/linux/repo/xUbuntu_24.04/arm64/megasync_6.7.1-1.1_arm64.deb` (HTTP 200, 52041280 bytes) |
| Upstream arch handling | amd64 only. URLs and grep pattern hardcoded to amd64; no arm64 path in the upstream Dockerfile |
| Checksums | None in the upstream Dockerfile. GPG key for the MEGA apt repo not shown: UNVERIFIED |
| Upstream packages (apt) | gpg, fontconfig, x11-xserver-utils; Qt5 (libqt5core5a, libqt5dbus5, libqt5gui5, libqt5network5, libqt5svg5, libqt5widgets5, libqt5x11extras5, qml-module-qtquick-controls2); libxcb-* set; libxkbcommon0, libevdev2, libinput, libwacom; libegl1, libegl-mesa0, libgbm1; libssl3, libcrypto++, libcurl3-gnutls, libssh2-1, libnghttp2-14; kerberos/LDAP libs; libmediainfo0v5, libraw20, libzen0v5, libtinyxml2-9, libicu72 and others |
| Upstream user | `useradd -d $DATA_DIR -s /bin/bash megasync`, `DATA_DIR=/megasync`. No `USER` instruction: container runs as root unless start.sh changes it (start.sh not fetched) |
| Upstream entrypoint | `ENTRYPOINT ["/opt/scripts/start.sh"]`, no CMD |
| Upstream EXPOSE / VOLUME | `EXPOSE 8080`. No VOLUME. `DATA_DIR` set to `/megasync` but not declared as volume |
| Upstream env | `DATA_DIR=/megasync`, `CUSTOM_RES_W=750`, `CUSTOM_RES_H=550`, `CUSTOM_DEPTH=16`, `NOVNC_PORT=8080`, `RFB_PORT=5900`, `TURBOVNC_PARAMS=-securitytypes none`, `UMASK=000`, `UID=99`, `GID=100`, `DATA_PERM=770`, `USER=megasync` |
| Ports | 8080/http (noVNC) confirmed by upstream EXPOSE and NOVNC_PORT. 5900/tcp (RFB) confirmed by RFB_PORT env, not exposed upstream |
| Arm64 copy-from | Draft: `copy-from amd64` = `ghcr.io/ich777/megasync:latest` (an image, not a plain binary). Upstream image is Debian-based glibc; the plan does not use `COPY --from` (see section 10) |

## 2. Target layout

- `apps/megasync/Dockerfile`
- `apps/megasync/docker-bake.hcl`
- `apps/megasync/settings.yaml`
- `apps/megasync/start.sh`
- `apps/megasync/container-test.yaml`
- `apps/megasync/defaults/` only if a default MEGAsync config is seeded into `/config` (reason: first-run settings). Decide after the GUI runs (UNVERIFIED)
- Not used: `root/` (never used by plans), `etc/`, `health/` (only if a probe beyond tcp/http is needed), `DOWNSTREAM_CHANGES.md` (not a `FROM` base)

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for the build and final stages.

Why it fits: the upstream base is a Debian 12 noVNC image. ContainerForge has no equivalent GUI base, so the GUI (Qt client, Xvnc, noVNC) is rebuilt on ubuntu. Closest sibling for a GUI/VNC app on ubuntu: `apps/kasmvnc`. The vendor deb targets Ubuntu 24.04 (arm64) and Debian 12 (amd64), so ubuntu 26.04 is a best fit for the arm64 deb and an untested fit for the amd64 Debian deb (see section 10).

## 4. Dockerfile

1. Build stage `FROM <ubuntu> AS megasync-fetch`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`. `VERSION` = `6.7.1-1.1` (matches bake).
2. Select the vendor repo per arch:
   ```dockerfile
   RUN case "${TARGETARCH}" in \
         amd64) REPO="https://mega.nz/linux/repo/Debian_12/amd64" ;; \
         arm64) REPO="https://mega.nz/linux/repo/xUbuntu_24.04/arm64" ;; \
         *) echo "unsupported arch" >&2; exit 1 ;; \
       esac && \
       curl -fsSL -o /tmp/megasync.deb "${REPO}/megasync_${VERSION}_${TARGETARCH}.deb"
   ```
   Both URLs were confirmed by HTTP 200 in this run. The arm64 deb comes from the Ubuntu 24.04 repo, so its runtime on ubuntu 26.04 is UNVERIFIED.
3. Final stage `FROM <ubuntu>`, `USER root`. Install the deb with apt so its dependencies resolve: `apt-get install -y --no-install-recommends /tmp/megasync.deb`, then install the GUI runtime (Qt libs, xcb, mesa, fonts, `x11-xserver-utils`). Use upstream's list as the starting point, trimmed to what the deb does not already pull in. Package names on ubuntu 26.04 (Qt5 vs Qt6) are UNVERIFIED; check `apt-cache` in the build.
4. Do not reinstall anything already in the base. Clean apt lists in the same RUN.
5. Remove the downloaded deb in the same layer: `rm -f /tmp/megasync.deb`.
6. Licence: the MEGA client licence file from the deb (`/usr/share/doc/megasync/`) is copied to `/usr/share/licenses/megasync/` if present (UNVERIFIED that the deb ships one).
7. `ENV HOME=/config XDG_CACHE_HOME=/tmp/.cache DATA_DIR=/config/megasync CUSTOM_RES_W=750 CUSTOM_RES_H=550 CUSTOM_DEPTH=16 NOVNC_PORT=8080 RFB_PORT=5900 UMASK=000`. Note the planned `DATA_DIR` moves from upstream `/megasync` to `/config/megasync` (persistent, section 9).
8. `COPY --from` is not used. The `ghcr.io/ich777/megasync` image is not a clean binary source and is Debian-based.
9. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /

   EXPOSE 8080
   VOLUME /config
   VOLUME /mnt/host
   ```
   `/mnt/host` is the chart's `hostpath` mount (path from the draft). Keep only if the chart mount is confirmed to be a host path (section 10). Remove the line otherwise.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "megasync"
}

variable "VERSION" {
  // renovate: datasource=UNVERIFIED depName=UNVERIFIED
  default = "6.7.1-1.1"
}

variable "LICENSE" {
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://github.com/meganz/MEGAsync"
}
```

- `VERSION` is a deb version (`6.7.1-1.1`), not a plain semver. It must match the Dockerfile `ARG VERSION` and the deb file name.
- The renovate annotation is UNVERIFIED: the upstream version comes from a directory listing (no fitting renovate datasource). Options are listed in section 10; choose one before the bake is final.
- `LICENSE` stays `UNVERIFIED` until confirmed.
- Targets: copy the four standard targets and the default group from `apps/adguardhome-sync/docker-bake.hcl`, with `image-local` tagged `${APP}:${VERSION}`. Validate with `cd apps/megasync && docker buildx bake --print`.
- `image-all` (amd64 and arm64) only once both arches are confirmed to run (section 10).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/meganz/MEGAsync"
ports:
  - port: 8080
    protocol: http
    required: false
  - port: 5900
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: CUSTOM_RES_W
    default: "750"
    required: false
  - name: CUSTOM_RES_H
    default: "550"
    required: false
  - name: CUSTOM_DEPTH
    default: "16"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Rules applied:
- Port 8080 is confirmed upstream (EXPOSE and NOVNC_PORT). Port 5900 is confirmed as RFB_PORT; keep it as tcp only if the port is opened in the built image (section 11).
- Env: only variables start.sh applies. `DATA_DIR`, `UID`, `GID`, `USER` and `UMASK` are upstream internals tied to root-based setup; do not list them unless the port uses them. `TURBOVNC_PARAMS` is not used by the plan (Xvnc is planned, see section 7).
- No dependencies. The MEGA account login is entered in the GUI (draft caveat), not via env.
- Volumes: `/config` required. `/mnt/host` is optional and only if confirmed (section 10).

## 7. start.sh

Plan (launch details are UNVERIFIED until the upstream `/opt/scripts/start.sh` is read):

```bash
#!/usr/bin/env bash

export HOME=/config
export XDG_CACHE_HOME=/tmp/.cache
export DISPLAY=:1
mkdir -p "${DATA_DIR:-/config/megasync}"

# Xvnc on :1 (no auth, bind 0.0.0.0), then websocket/noVNC proxy on 8080
/usr/local/bin/Xvnc :1 -geometry "${CUSTOM_RES_W:-750}x${CUSTOM_RES_H:-550}" -depth "${CUSTOM_DEPTH:-16}" \
  -SecurityTypes None -interface 0.0.0.0 -rfbport 5900 &
sleep 2

exec /usr/bin/megasync
```

Notes:
- Idempotent: `mkdir -p` only. The MEGA client writes its own config under `DATA_DIR` on first login; nothing is seeded.
- Never write under `/usr` or `/app`. Settings go to `/config`, caches to `/tmp`.
- `exec` the final process. Xvnc and the noVNC proxy are launched first (their exact wrapper, e.g. websockify, is UNVERIFIED; reuse the `apps/kasmvnc` pattern if it fits).
- The GUI runs as `apps` (`USER apps`), not root, which differs from upstream (root, no USER). Confirm MEGAsync runs as a non-root user; this is a risk (section 10).
- Bind VNC and noVNC to `0.0.0.0` (start-script rule).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '8080'
- port: '5900'
http:
- port: '8080'
  path: /
filePaths:
- /usr/bin/megasync
- /usr/share/licenses/megasync
```

Rules:
- Every port in `settings.yaml` has a probe (8080 tcp and http, 5900 tcp).
- `/usr/bin/megasync` is the expected path from the deb (UNVERIFIED until the image is built). The licence path is only valid if section 4 step 6 finds a licence in the deb.
- The test runs with no env vars and no MEGA account. Login is not tested; no required-env path exists.
- `timeoutSeconds: 120` is a starting value; adjust to the GUI startup measured in section 11.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `DATA_DIR=/megasync` (MEGA config and cache) | `DATA_DIR=/config/megasync` (persistent) |
| `HOME` (root's home or `/megasync`) | `HOME=/config` |
| Caches | `XDG_CACHE_HOME=/tmp/.cache` |
| X11 / VNC sockets (`/tmp/.X11-unix`) | `/tmp` (tmpfs under `--read-only --tmpfs /tmp`) |
| `/tmp/MegaSync.deb` (upstream download scratch) | build stage only; removed in the same layer |
| `/mnt/host` (draft hostpath) | user-mounted; path unchanged if kept |

Security expectations reconciled with the draft:
- Chart runs as UID 0 with `runAsNonRoot: false`. Plan runs as `apps` (`USER apps`). Upstream runs as root with no `USER`, so this is a change that must be tested (section 11).
- `readOnlyRootFilesystem: false` in chart. Plan targets `--read-only --tmpfs /tmp`; the Qt client may write config outside `/config` (UNVERIFIED).
- Not privileged in chart. Capabilities are not set in values, so none are added.
- `hostpath` key: the chart's type is unset (defaults to pvc per draft), though the name suggests hostPath. Verify the chart before claiming a host path is mounted (section 10).

## 10. Risks, caveats and open questions

- Closed-source GUI client: needs a desktop over VNC. The MEGA login is entered in the GUI, so the container is not usable without a MEGA account. Not testable in CI without an account.
- arm64: the vendor deb exists (xUbuntu_24.04/arm64, HTTP 200) but upstream is amd64-only and the Qt/runtime deps on ubuntu 26.04 are UNVERIFIED. Draft's `arm64 yes` is only the URL: runtime is UNVERIFIED. Do not mark `image-all` until tested.
- amd64 deb is built for Debian 12 (`Debian_12` repo). Running it on ubuntu 26.04 may need different libs. UNVERIFIED; test in section 11. The draft's `xUbuntu_24.04/amd64` URL was not checked and should not be used without a check.
- Running as `apps` instead of root (upstream root, no USER): the MEGA client and Xvnc may need root for a device or X socket. UNVERIFIED.
- Hostpath: `hostpath` in chart values has no type; the draft says it may be a PVC or hostPath. Verify the chart before adding `/mnt/host` as a volume.
- Renovate: `VERSION` comes from a repo directory listing, with no clean renovate datasource. Options: manual bumps, or a custom datasource (not chosen here; UNVERIFIED).
- Licence: closed-source MEGA EULA, SPDX not confirmed (section 5).
- Ports 8080 and 5900 are confirmed upstream, but the wrapper that serves noVNC on 8080 is UNVERIFIED.
- Upstream `/opt/scripts/start.sh` and the base-image noVNC wrapper were not fetched: launch details above are plan decisions to check.
- Blockers: the MEGA account requirement and the root-to-apps change are the main risks. No musl issue, no GPU or privileged need known.

## 11. Build and test steps

```sh
cd apps/megasync
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name megasync-probe --read-only --tmpfs /tmp \
  -v megasync-probe-config:/config megasync:6.7.1-1.1
docker logs -f megasync-probe
forgetool containers test --image megasync:6.7.1-1.1 --config ./apps/megasync/container-test.yaml
docker rm -f megasync-probe; docker volume rm megasync-probe-config
```

- Expected readiness signal: Xvnc and the noVNC proxy log their listen lines and the MEGAsync process stays running (exact strings UNVERIFIED until the image runs).
- Empty `/config` must start cleanly (protocol rule).
- arm64: build and run only after amd64 passes; the arm64 runtime is UNVERIFIED.
- Do not test the MEGA login in CI.

## 12. PR checklist

- Branch `feat/add-megasync`, commit and PR title `feat(megasync): add new container`, target `main`.
- PR body fills `.github/PULL_REQUEST_TEMPLATE.md`, keeps its sections and checkboxes, and checks only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: contributions need a signed CLA (https://cla-assistant.io/trueforge-org/containerforge). Tell the user; only the user can sign it. Check the `license/cla` status.
- State what was not tested: MEGA account login, arm64 runtime, the Debian-12 deb on ubuntu 26.04, the hostpath mount, the licence, and the renovate source.
- `docker buildx bake --print` passes; `VERSION` in bake equals `ARG VERSION` in the Dockerfile; no assertion weakened.
