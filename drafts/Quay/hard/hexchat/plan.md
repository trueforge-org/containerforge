# hexchat — implementation plan
> Source: ./draft.md · Target: apps/hexchat/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Upstream app `v2.16.2` (latest GitHub release, published 2024-02-07): https://github.com/hexchat/hexchat/releases/tag/v2.16.2. Ubuntu archive package `hexchat 2.16.2-1build6` in resolute (26.04): https://packages.ubuntu.com/resolute/hexchat. The chart image `quay.io/binhex/arch-hexchat:latest` is a rolling tag with no version; it is not the version to build. |
| Renovate | Ubuntu package: no renovate datasource fits an apt version. Use `datasource=github-releases depName=hexchat/hexchat versioning=semver` for the app version, and pin the apt version in the Dockerfile (section 4). |
| License | GPL-2.0 (GitHub API `repos/hexchat/hexchat` `.license.spdx_id`). COPYING: https://raw.githubusercontent.com/hexchat/hexchat/master/COPYING (GNU GPL v2). |
| Source URL | https://github.com/hexchat/hexchat |
| Download amd64 | Ubuntu archive via apt (`hexchat` package, `main` pocket). The amd64 `.deb` URL was not fetched: UNVERIFIED (arm64 was confirmed: https://packages.ubuntu.com/resolute/arm64/hexchat/download, `hexchat_2.16.2-1build6_arm64.deb`). |
| Download arm64 | Ubuntu archive via apt, confirmed for `hexchat_2.16.2-1build6_arm64.deb` (see above). |
| Checksum source | Ubuntu archive signatures and `Release` metadata via apt (signed by Ubuntu archive keys). No separate checksum is needed for apt. |
| Chart container | `quay.io/binhex/arch-hexchat:latest@sha256:c99d7cea48789657fb30de2194646e23631ee2249f59113d1cadf40689b72d34` (chart `charts/stable/hexchat`, https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/hexchat/values.yaml). |
| Upstream Dockerfile reviewed | binhex, pinned commit `2c35dde8b489a4cfec0ffbd3118c6166fb11516a` (2026-11-12): https://raw.githubusercontent.com/binhex/arch-hexchat/2c35dde8b489a4cfec0ffbd3118c6166fb11516a/Dockerfile. `FROM ghcr.io/binhex/arch-int-gui:latest` (Arch Linux, a GUI base), `ADD build/root/*.sh /root/`, `ADD config/nobody/* /home/nobody/`, `RUN /bin/bash /root/install.sh "${APPNAME}" "${RELEASETAG}" "${TARGETARCH}"`, `HEALTHCHECK` script, `CMD ["/bin/bash", "init.sh"]`. The `install.sh`, `init.sh` and the `arch-int-gui` base were NOT fetched: UNVERIFIED for the GUI stack and env list. |
| Ports (chart) | Service `main` port 10307 maps to container `targetPort: 6080` (noVNC, `http`). Source: chart values.yaml. |
| Env vars (chart) | `VNC_PASSWORD` (secret `env-secrets`), `WEBPAGE_TITLE=HexChat`. Source: chart values.yaml. Any other env is UNVERIFIED (upstream `install.sh`/`init.sh` not fetched). |
| Config path (chart) | `/config` (chart `persistence.config.mountPath: /config`). |
| Security (chart) | `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`. |
| Dependencies | None. |

## 2. Target layout

- `apps/hexchat/Dockerfile`
- `apps/hexchat/docker-bake.hcl`
- `apps/hexchat/settings.yaml`
- `apps/hexchat/container-test.yaml`
- `apps/hexchat/start.sh` (starts the display stack and HexChat, see section 7)
- `apps/hexchat/defaults/` (only when first-run desktop/VNC config is seeded, e.g. the window-manager config; list every file there, with its reason)

`root/` is not used. `DOWNSTREAM_CHANGES.md` is not needed (not a base image).

## 3. Base image

- `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` for the final stage. The package is in the Ubuntu 26.04 archive for both arches (section 1), so the ubuntu base is the right fit.
- Do not base on `ghcr.io/binhex/arch-int-gui`: it is Arch Linux, not ContainerForge's Ubuntu base, and the rules forbid copying a foreign runtime in.
- Closest sibling for a desktop/VNC session: `apps/kasmvnc` (ubuntu base, `start.sh` seeds `/config` openbox files from `/defaults`, `DISPLAY=:1`). Reuse its layout and naming, not its code, because kasmvnc is a larger stack.

## 4. Dockerfile

1. `FROM <ubuntu digest> AS base` is not needed. A single stage is enough: the app is an apt package.
2. `ARG VERSION` (the hexchat upstream version, `2.16.2`, for the license and label), `ARG TARGETARCH`, `USER root`.
3. Install with pinned package versions checked against `VERSION`, as the rules ask for apt packages:

```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
    hexchat=2.16.2-1build6 \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    openbox \
    dbus-x11 \
    xauth \
    && rm -rf /var/lib/apt/lists/*
```

   - `hexchat=2.16.2-1build6` is the resolute version from section 1. Verify both arches resolve it; if the amd64 version differs, pin per arch and record it.
   - The exact set of GUI packages (`xvfb`, `x11vnc`, `novnc`, `websockify`, `openbox`) is a plan, not a verified list. UNVERIFIED that the binhex stack needs them; check `hexchat` starts under `xvfb` in the build test.
   - `novnc` and `websockify` provide the noVNC web UI on 6080 (chart `targetPort 6080`).
4. License: `install -D /usr/share/doc/hexchat/copyright /usr/share/licenses/hexchat/copyright` (Debian/Ubuntu copyright file from the package; UNVERIFIED path). Ship the upstream `COPYING` text too, from the package doc directory if present.
5. `mkdir -p /app/hexchat && chown -R apps:apps /app/hexchat` (start script and any read-only assets). Do not write to `/app` at runtime.
6. `ENV HOME=/config DISPLAY=:1 XDG_RUNTIME_DIR=/tmp/xdg`.
7. Final lines:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 6080
VOLUME /config
```

`apt-get` runs as root, so `USER root` stays only for the install and is switched back to `apps` before the final copy.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "hexchat"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=hexchat/hexchat versioning=semver
  default = "2.16.2"
}

variable "LICENSE" {
  default = "GPL-2.0-only"
}

variable "SOURCE" {
  default = "https://github.com/hexchat/hexchat"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
  }
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
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
```

- `LICENSE` is `GPL-2.0` in the GitHub SPDX field; the bake value uses the SPDX-correct `GPL-2.0-only` per the GitHub-reported `GPL-2.0`. Confirm against COPYING (GPL v2 text, "version 2" only). UNVERIFIED which one to use; default to the GitHub SPDX field `GPL-2.0` if the reviewer prefers it.
- Validate with `docker buildx bake --print` in `apps/hexchat`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/hexchat/hexchat"
ports:
  - port: 6080
    protocol: tcp
    required: true
env:
  - name: VNC_PASSWORD
    default: ""
    required: true
  - name: WEBPAGE_TITLE
    default: "HexChat"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

- `VNC_PASSWORD` is `required: true` with an empty default. The rules require a default or start.sh handling. Handle it in `start.sh` (section 7): refuse to start with no password, or generate one into `/tmp` and print a warning. Decide with the user; do not run VNC with no auth.
- `WEBPAGE_TITLE` is read by the noVNC page the chart sets it on (UNVERIFIED that the Ubuntu noVNC package honours it; if not, drop it).
- Port 6080 is the only port the chart exposes; `5900/tcp` (VNC) is inferred in the draft and is kept internal (not listed), so no probe is needed for it.

## 7. start.sh

```bash
#!/usr/bin/env bash

if [[ -z "${VNC_PASSWORD:-}" ]]; then
  echo "VNC_PASSWORD is not set; refusing to start an unauthenticated desktop" >&2
  exit 1
fi

mkdir -p /config/.vnc /tmp/xdg
chmod 700 /tmp/xdg
export XDG_RUNTIME_DIR=/tmp/xdg DISPLAY=:1 HOME=/config

# Store the VNC password for x11vnc in /config, not in the process list.
x11vnc -storepasswd "${VNC_PASSWORD}" /config/.vnc/passwd >/dev/null

Xvfb :1 -screen 0 1280x800x24 &
sleep 2
openbox &
hexchat &
x11vnc -display :1 -forever -shared -rfbauth /config/.vnc/passwd -rfbport 5900 -quiet &
exec websockify --web=/usr/share/novnc 6080 localhost:5900
```

- Idempotent: the VNC password file is rewritten on every start from `VNC_PASSWORD`, so a changed password takes effect (the stored form is an obfuscated file, not written from a baked value).
- `exec` the final long-running process (websockify) so signals reach PID 1 (the protocol's rule for start.sh). The background X and VNC processes are children and must be supervised; UNVERIFIED that this is acceptable, or use a small supervisor such as `s6`/`tini` with multiple processes (decide before build).
- `/tmp/xdg` for XDG runtime, not `/config`.
- `hexchat &` is launched after `openbox &`; confirm the exact launch line and that HexChat runs as user `apps`.
- Binds `0.0.0.0:6080` (websockify default binds all interfaces; confirm).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '6080'
http:
- port: '6080'
  path: /vnc.html
filePaths:
- /usr/bin/hexchat
- /usr/share/novnc/vnc.html
- /usr/share/licenses/hexchat/copyright
```

- The test runs with no env vars, so `start.sh` exits 1 without `VNC_PASSWORD` and the test fails (same conflict as aistor). Options: pass the password in the test if the schema supports env, or narrow the test with a comment and a file check on the start path. Do not remove the tcp or http probes. Decide with the user; the rule is "fix the defect, never weaken".
- `/vnc.html` is the noVNC page path (UNVERIFIED that the Ubuntu novnc package serves it at that path; check during build).
- `timeoutSeconds: 120` is a guess; measure startup, since Xvfb and openbox add time.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Chart runs as root (`runAsUser 0`) | This image runs as `apps` (568) via `USER apps`. X and VNC must run without root: Xvfb and x11vnc as `apps` are allowed; a privileged port is not needed (5900 and 6080 are above 1024). |
| `/config` (chart PVC) | `/config` holds the user's HexChat config (`/config/.config/hexchat`) and the VNC password file (`/config/.vnc/passwd`). HOME is `/config`. |
| X socket `/tmp/.X11-unix` | `/tmp` tmpfs, compatible with `--read-only --tmpfs /tmp`. |
| XDG runtime `/tmp/xdg` | `/tmp`, not `/config`. |
| `/app` | Not written at runtime. |
| Chart `readOnlyRootFilesystem: false` | The image can be read-only with `/tmp` and `/config` writable; set the chart value to true in the chart, not here (out of scope). |

- Draft expectations reconciled: chart is non-root false (runs as UID 0); this image is rootless (apps 568). Chart read-only rootfs false; this image is compatible with read-only rootfs (UNVERIFIED until the probe run, which has to show that X and noVNC do not write elsewhere).
- Privileged: not required (no device access, no host network).

## 10. Risks, caveats and open questions

- GUI session: HexChat is a GTK app, and there is no headless mode (draft). The stack needs Xvfb, a window manager, x11vnc, noVNC and websockify. The exact package set and startup order are UNVERIFIED; this is the main effort.
- Process model: `start.sh` runs several long-lived processes. PID 1 handling needs a decision (a supervisor, or accept that only the last process is supervised). UNVERIFIED which the protocol accepts for multi-process apps; check `apps/kasmvnc/start.sh` for the sibling pattern before deciding.
- Password: `VNC_PASSWORD` is required and the no-env test conflicts with it (section 8).
- The chart uses binhex's Arch image. Moving to Ubuntu means the user's existing config and layout may change; document the `/config` layout in the PR.
- IRC networks, nicks and servers are set up by the user in the UI or in `/config` (manual setup, draft).
- Copy source: the binhex image is a rolling `latest` tag. This plan does not copy from it, so the rolling-base risk does not apply. The copy-from arm64 value is `no` in the draft and is not used.
- Release date: the upstream release is from 2024-02-07, and Ubuntu 26.04 ships 2.16.2, so there is no newer upstream version to pin. UNVERIFIED whether upstream has a newer tag not published as a release (`git ls-remote` listed tags up to v2.9.x in the sample only).
- arm64: the package exists for arm64 (confirmed), but the GUI stack on arm64 is untested.
- Not a blocker: not musl-only, no GPU, not privileged.

## 11. Build and test steps

```sh
cd apps/hexchat
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name hexchat-probe --read-only --tmpfs /tmp \
  -e VNC_PASSWORD='<test-password>' \
  -p 6080:6080 \
  -v hexchat-probe-config:/config hexchat:2.16.2
docker logs -f hexchat-probe
curl -fsS http://127.0.0.1:6080/vnc.html -o /dev/null && echo OK
docker rm -f hexchat-probe; docker volume rm hexchat-probe-config
forgetool containers test --image hexchat:2.16.2 --config ./apps/hexchat/container-test.yaml
```

- The probe sets `VNC_PASSWORD` by hand because the protocol's no-env run cannot start (section 8). Record it.
- Expected readiness signal: Xvfb and websockify start lines, and a `listening` line on 6080 from websockify. Exact text UNVERIFIED; capture the first 100 lines.
- Check that HexChat is running (process list inside the container) and that the window is visible via noVNC.
- arm64: run only if the amd64 build fails for an arm64-specific reason.

## 12. PR checklist

- Branch `feat/add-hexchat`, commit `feat(hexchat): add new container`, PR title `feat(hexchat): add new container`, target `main`.
- Tell the user that a signed Contributor License Agreement is needed (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- State in the PR that the GUI stack, the process supervision, the amd64 apt version, the licence value, and the readiness signal are UNVERIFIED or untested, and that the arm64 run is not done.
- `docker buildx bake --print` passes; `VERSION` in bake equals the Dockerfile `ARG VERSION`; no assertion weakened.
