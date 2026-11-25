# rapidphotodownloader — implementation plan
> Source: ./draft.md · Target: apps/rapidphotodownloader/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `0.9.37` (upstream tag `v0.9.37`, published 2026-02-18). Source: https://api.github.com/repos/damonlynch/rapid-photo-downloader/releases/latest (read via `gh api`). |
| Draft chart image | `ghcr.io/ich777/rapidphotodownloader:latest@sha256:fef9de67f31ace4d9eedd05c79159ec0aa1307cb2bffec38383778479d8e4154` (https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rapidphotodownloader/values.yaml). This plan does not reuse it: the upstream image is `FROM ich777/novnc-baseimage:bullseye_amd64`, runs as root, and pins an old pyqt installer `0.9.17`. |
| Renovate | Upstream release assets are a source tarball only. Proposed: `datasource=github-releases depName=damonlynch/rapid-photo-downloader versioning=loose` (tags are `v`-prefixed; check the first run). UNVERIFIED against this repo's renovate config. |
| License | GPL-3.0 (`gh api repos/damonlynch/rapid-photo-downloader`, `license.spdx_id`). Source: https://github.com/damonlynch/rapid-photo-downloader |
| Source URL | https://github.com/damonlynch/rapid-photo-downloader |
| Download (chosen) | apt package, not a source build: `rapid-photo-downloader` from the Ubuntu archive. resolute (26.04 LTS) `0.9.37-0ubuntu4`; resolute-updates `0.9.37-0ubuntu4.1`; noble `0.9.36-0ubuntu3` (https://packages.ubuntu.com/search?keywords=rapid-photo-downloader&searchon=names&suite=all&section=all). |
| Per-arch | amd64: apt package resolute, version confirmed. arm64: UNVERIFIED (the search page did not list architectures). Verify with `apt-cache policy` / `packages.ubuntu.com/resolute/arm64/rapid-photo-downloader/download` during step 2. |
| Checksum source | Ubuntu archive signatures (apt). Upstream tarball has a detached signature `rapid-photo-downloader-0.9.37.tar.gz.asc` (not used). Signature verification: UNVERIFIED (key not fetched). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ich777/docker-rapidphotodownloader/master/Dockerfile: `FROM ich777/novnc-baseimage:bullseye_amd64`, `ENTRYPOINT ["/opt/scripts/start.sh"]`, `EXPOSE 8080`, no `USER`, no `VOLUME`. Env: `DATA_DIR=/rapidphotodownloader`, `NOVNC_PORT=8080`, `RFB_PORT=5900`, `CUSTOM_RES_W=1024`, `CUSTOM_RES_H=881`, `CUSTOM_DEPTH=16`, `TURBOVNC_PARAMS="-securitytypes none"`, `UMASK=000`, `UID=99`, `GID=100`, `DATA_PERM=770`, `USER=rpd`. |
| Upstream start.sh reviewed | https://raw.githubusercontent.com/ich777/docker-rapidphotodownloader/master/scripts/start.sh: remaps UID/GID with usermod/groupmod, chowns `${DATA_DIR}`, creates `/var/run/dbus`, then `su ${USER} -c "/opt/scripts/start-server.sh" &`. Starts no X server itself (start-server.sh not fetched: UNVERIFIED). |
| Ports | 8080 (noVNC, chart service `main` port 8080 tcp, https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rapidphotodownloader/values.yaml). 5900 (VNC, upstream `RFB_PORT`): internal only. |
| App config path | `~/.config/Rapid Photo Downloader/Rapid Photo Downloader.conf` (https://damonlynch.net/rapid/documentation). |
| App cache path | `~/.cache/rapid-photo-downloader/` (log, thumbnails). Changed by `XDG_CACHE_HOME` (same URL). |
| Headless / CLI | No headless or container mode documented; startup automation is set in the GUI preferences (same URL). |
| App deps (docs) | exiv2 (metadata, default reader), exiftool 10.63+ (HEIF and fallback), pyheif (optional pip), gphoto2 (cameras), libimobiledevice-utils + ifuse (iOS). Same URL. |
| Chart persistence | `datadir` -> `/rapidphotodownloader`, `destinantionfolder` -> `/media/destination`, `sourcefolder` -> `/media/source` (values.yaml). |
| Chart security | `readOnlyRootFilesystem: false`, `runAsUser: 0`, `runAsGroup: 0`, no `privileged`, no `podSecurityContext` (values.yaml). Not applicable to the ContainerForge build (see section 9). |

## 2. Target layout

- `apps/rapidphotodownloader/Dockerfile`: apt install of the app and the display stack, final `USER apps`.
- `apps/rapidphotodownloader/docker-bake.hcl`: `APP`, `VERSION` (renovate), `LICENSE`, `SOURCE`, standard targets.
- `apps/rapidphotodownloader/settings.yaml`: port 8080, env, `/config` volume.
- `apps/rapidphotodownloader/container-test.yaml`: tcp and http probes on 8080.
- `apps/rapidphotodownloader/start.sh`: first-run seeding, starts the X and VNC stack, then `exec`s the app.
- `apps/rapidphotodownloader/defaults/fluxbox/` (only if a default fluxbox config is needed; reason: first-run seeding into `/config`; `apps/kasmvnc` has no `defaults/` dir, so there is no precedent to cite). Start without it: omit unless the window manager needs a file to run.

No `root/` (reserved). No `etc/` unless a system file must change (not planned). No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Fits because the 26.04 archive carries `rapid-photo-downloader` 0.9.37. The upstream image's `bullseye` base is replaced, not reused. Closest siblings (both exist): `apps/kasmvnc` (VNC stack on the ubuntu base) and `apps/xvfb` (installs apt `xvfb`, confirmed). The Python alternative (`ghcr.io/trueforge-org/python`) is not used: the app is an apt-installed PyQt app and the distro provides Python.

## 4. Dockerfile

1. Single stage, `FROM <ubuntu 26.04 digest>`. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Install the app and display stack in one `RUN` (no `--no-install-recommends` override needed beyond the standard):
   - `rapid-photo-downloader` pinned to the resolute version, e.g. `rapid-photo-downloader=0.9.37-0ubuntu4.1`. Check the pin against `VERSION=0.9.37` at build time (step 2 in section 11).
   - Display: `xvfb`, `x11vnc`, `novnc`, `websockify`, `fluxbox`, `dbus-x11`, `fonts-dejavu-core`. None of these is confirmed in the 26.04 archive: UNVERIFIED, check with `apt-cache policy <pkg>` in the build.
   - `apt-get clean && rm -rf /var/lib/apt/lists/*`.
3. `COPY --chmod=0755 . /` is done after `USER apps` (section 4 tail). Scripts come from `start.sh` and optional `defaults/`.
4. Remove nothing from the base. Do not install Python packages: the apt package brings its own.
5. Env (image level): `HOME=/config`, `XDG_CACHE_HOME=/tmp/cache`, `XDG_RUNTIME_DIR=/tmp/xdg`, `DISPLAY=:99`, `TZ=Etc/UTC`.
6. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
```

Set neither `ENTRYPOINT` nor `CMD`: the base `ubuntu` image's `ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]` execs `/start.sh` (see `apps/ubuntu/Dockerfile`, `apps/steamcmd/Dockerfile`).

Key points: no `USER root` after the install step; no writes to `/app` (none is needed); the `apps` UID/GID come from the base.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "rapidphotodownloader"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=damonlynch/rapid-photo-downloader versioning=loose
  default = "0.9.37"
}

variable "LICENSE" {
  default = "GPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/damonlynch/rapid-photo-downloader"
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

`LICENSE` `GPL-3.0-only` is a guess within the GPL-3.0 family (GitHub API reports `GPL-3.0`); UNVERIFIED whether the source headers say `-only` or `-or-later`: confirm in `/usr/share/doc/rapid-photo-downloader/copyright` in the built image. `image-all` is only valid if arm64 is confirmed (section 1). Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/damonlynch/rapid-photo-downloader"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: RESOLUTION
    default: "1280x800x24"
    required: false
volumes:
  - path: /config
    required: true
```

Notes: `RESOLUTION` is read by `start.sh` (the X screen size) and is not an upstream variable. Do not list `CUSTOM_RES_*`, `UID`, `GID`, `UMASK`, `RFB_PORT` or `TURBOVNC_PARAMS`: the ContainerForge runtime does not read them. Mount points `/media/source` and `/media/destination` are not listed as `volumes:` (user data mounts, not required by the app); document them in the README only if the team asks.

## 7. start.sh

Requirements: idempotent, seeds only missing files, never writes to `/app`, caches in `/tmp`, binds 0.0.0.0 for noVNC, ends with `exec`.

```bash
#!/usr/bin/env bash
set -euo pipefail

# First-run seeding (only when missing)
mkdir -p /config/.config "/config/.config/Rapid Photo Downloader"
# (copy /defaults/fluxbox into /config/.fluxbox only if absent; add only if defaults/ is used)

# Runtime dirs on tmpfs
export XDG_CACHE_HOME=/tmp/cache XDG_RUNTIME_DIR=/tmp/xdg
mkdir -p "${XDG_CACHE_HOME}" "${XDG_RUNTIME_DIR}" /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

RES="${RESOLUTION:-1280x800x24}"
export DISPLAY=:99

# X display (background), window manager (background), VNC on localhost only
Xvfb "${DISPLAY}" -screen 0 "${RES}" -nolisten tcp &
until [ -S "/tmp/.X11-unix/X99" ]; do sleep 0.2; done
fluxbox >/tmp/fluxbox.log 2>&1 &
x11vnc -display "${DISPLAY}" -forever -shared -nopw -rfbport 5900 -localhost -q &

# noVNC on all interfaces (required for use from other containers)
websockify --web=/usr/share/novnc 0.0.0.0:8080 localhost:5900 &

# Final process: the app (exec so signals reach it)
exec rapid-photo-downloader
```

Caveats for this script:
- `-nopw` on `x11vnc` means no VNC password. It is bound to `localhost` only, so only the noVNC proxy reaches it. Document this in the log line. If the team wants a password, add `PASSWORD` to `settings.yaml` and pass `-passwd` (not planned here).
- `exec rapid-photo-downloader` makes the app the last process: if the app exits, the container exits. Background children (Xvfb, fluxbox, x11vnc, websockify) then stop with it.
- `rapid-photo-downloader` must be launched with `HOME=/config` so the config file lands in `/config/.config/Rapid Photo Downloader/`.
- Remove `set -u` if any variable (e.g. `RESOLUTION`) is optional at runtime; the defaults above already cover it.
- The first `Xvfb` wait loop must have a timeout in the final version (`timeout 30 bash -c 'until ...; do sleep 0.2; done'`), so a crash does not hang forever.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '8080'
http:
- port: '8080'
  path: /vnc.html
```

`timeoutSeconds` is a top-level key (see `apps/changedetection/container-test.yaml`), so add `timeoutSeconds: 120` above `tcp:`. `apps/kasmvnc/container-test.yaml` uses `tcp` only; the `http` form is as in `apps/caddy/container-test.yaml`. `timeoutSeconds` is 120 because Xvfb, fluxbox and the app start in sequence; compare with sibling GUI images before settling on a value. No env vars are set by the test, so the default `RESOLUTION` path is the one exercised. Per the test rules, `filePaths` should check `/usr/share/novnc/vnc.html` exists (the noVNC index file the proxy serves) and `/usr/bin/rapid-photo-downloader` is executable.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap in this image |
| --- | --- |
| `/rapidphotodownloader` (DATA_DIR, chown to UID 99) | Not used. App data goes to `/config`. |
| `~/.config/Rapid Photo Downloader/` | `HOME=/config` makes it `/config/.config/Rapid Photo Downloader/`. |
| `~/.cache/rapid-photo-downloader/` | `XDG_CACHE_HOME=/tmp/cache` (ephemeral; thumbnails regenerate). |
| `/var/run/dbus`, `/var/lib/dbus/machine-id` | Not created: dbus is not started. Watch the log for dbus errors and add `dbus-run-session` only if the app requires it (UNVERIFIED). |
| `/tmp/.X11-unix`, `XDG_RUNTIME_DIR` | Created under `/tmp` (tmpfs under `--read-only --tmpfs /tmp`). |
| `/opt/scripts`, `/etc/sudoers`, `/etc/.fluxbox` (upstream) | Not used: no sudo, no `/etc` writes. |
| `/media/source`, `/media/destination` | User mounts. The chart's root user is replaced by `apps` (UID from the base). Source files keep their owner; destination writes need the mount to be writable by the `apps` UID. Document this for the user. |

Security expectations, reconciled:
- Chart expects root (`runAsUser 0`, `runAsGroup 0`) and `readOnlyRootFilesystem: false`. This image runs as `apps` and works with a read-only rootfs (`/tmp` and `/config` writable). The chart values do not apply to ContainerForge.
- No `privileged` and no extra capabilities are needed for X, VNC or the app.
- USB devices (cameras, card readers) need passthrough from the host. Not set in ContainerForge; the user adds it at deploy time (same caveat as the draft).

## 10. Risks, caveats and open questions

- arm64 package availability for `rapid-photo-downloader` in resolute is UNVERIFIED. If absent, use `VERSION` and `image-local` only (amd64), and do not publish `image-all`.
- The display packages (`novnc`, `x11vnc`, `websockify`, `fluxbox`) on 26.04 are UNVERIFIED. The `kasmvnc` sibling uses its own noVNC build from source; the apt path is simpler, so confirm before committing.
- The app is a PyQt GUI with no headless or container mode documented. The image is only useful through a browser (noVNC on 8080). A headless or CLI use case does not exist upstream.
- The upstream image pins `RapidPhotoDownloader 0.9.17` (old pyqt installer). The apt package is `0.9.37`. Behavior differences are UNVERIFIED.
- The draft's `(inferred)` packages (`python3-pyqt5`, `exiv2`, `novnc`, `fluxbox`, `xvfb`) are partly confirmed: the app's docs list exiv2, exiftool, gphoto2 and iOS tools. `python3-pyqt5` is a dependency of the apt package; confirm with `apt-cache depends rapid-photo-downloader` in the build.
- Camera and card-reader imports need USB passthrough (not in the chart values). Only a runtime concern; not testable in the container test.
- Blocker check: none of the hard-band blockers (musl-only, GPU, privileged) apply. The remaining risk is GUI-only operation. Treat this as a `hard` port for the display stack, not for the app.

## 11. Build and test steps

From `apps/rapidphotodownloader/`:

1. `docker buildx bake --print` (must exit 0).
2. Confirm the apt pins and arm64 availability inside the build: `docker buildx bake --set image-local.platform=linux/amd64 image-local` (amd64 only first; arm64 only if the failure is arm64-specific).
3. Probe run on read-only rootfs with an empty `/config`:
   ```sh
   docker run --rm -d --name rapidphotodownloader-probe --read-only --tmpfs /tmp \
     -v rapidphotodownloader-probe-config:/config rapidphotodownloader:0.9.37
   docker logs -f rapidphotodownloader-probe
   ```
   Expected readiness signals: `Xvfb` started, `websockify` listening on `0.0.0.0:8080`, and the app's main window or startup line. Must stay running. Fail on any `Permission denied` for `/config` or `/tmp`.
   Clean up: `docker rm -f rapidphotodownloader-probe; docker volume rm rapidphotodownloader-probe-config`.
4. Test suite: `forgetool containers test --image rapidphotodownloader:0.9.37 --config ./apps/rapidphotodownloader/container-test.yaml`. If `forgetool` is missing, validate the 8080 probe and `/vnc.html` by hand with `curl`.
5. Run `haiku-triage` (per repo rule) for any lint or test output; do not run the test suite inline in the main session if the log is large.

## 12. PR checklist

- Branch `feat/add-rapidphotodownloader`, commit `feat(rapidphotodownloader): add new container`, PR title the same.
- PR body from `.github/PULL_REQUEST_TEMPLATE.md` (keep sections and checkboxes; check only what applies).
- Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it; the `license/cla` check shows the status.
- Say what was not tested: if the image was not built or run locally, say so and do not check "Built container locally". The web-fetch step did not build or run anything.
- Untested items to state in the PR: arm64 availability of the apt package and display packages, GUI usability over noVNC, USB passthrough, and the first-run seeding path.
- Downstream: none (`DOWNSTREAM_CHANGES.md` not needed; the image is not a `FROM` base).
