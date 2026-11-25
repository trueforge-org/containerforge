# opengl-desktop-g3 — implementation plan
> Source: ./draft.md · Target: apps/opengl-desktop-g3/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | The product is a desktop recipe, not a single app. Tracked version: VirtualGL `3.1.5` (latest GitHub release, marked Latest; tarball `VirtualGL-3.1.5.tar.gz`). accetto's own version is "G3v8" (project README; no semver). Draft tag `latest`. Use `3.1.5` as `VERSION` so the image contains the version it is tagged with. |
| Renovate | `datasource=github-releases depName=VirtualGL/virtualgl versioning=semver` |
| License | Repo accetto/headless-drawing-g3: MIT. VirtualGL: license not retrievable from the release page, believed wxWindows Library License 3.1 (UNVERIFIED). Mesa: MIT-style (distribution packages). The `LICENSE` in docker-bake.hcl must name the VirtualGL licence (the component this tag tracks): `wxWindows` UNVERIFIED; confirm from the package's `/usr/share/doc/virtualgl/copyright` before committing. |
| Source URL | https://github.com/accetto/headless-drawing-g3 (VirtualGL: https://github.com/VirtualGL/virtualgl) |
| Per-arch download | `https://github.com/VirtualGL/virtualgl/releases/download/3.1.5/virtualgl_3.1.5_amd64.deb` (HTTP 200, 1,721,678 bytes) and `.../virtualgl_3.1.5_arm64.deb` (HTTP 200). The draft says `apt:virtualgl`; the Ubuntu archive package version is UNVERIFIED, so the upstream .deb is used to match `VERSION`. |
| Checksum | None found on the release page (could not list assets via the API: rate limited): UNVERIFIED. Compute `sha256sum` of both debs during implementation and pin as Dockerfile ARGs. |
| Upstream Dockerfile reviewed | https://github.com/accetto/headless-drawing-g3/blob/master/docker/Dockerfile.xfce : `ubuntu:24.04`, UID 1001 `headless`, `ENV DISPLAY=:1 VNC_PORT=5901 VNC_PW=headless VNC_RESOLUTION=1360x768 NOVNC_PORT=6901 HOME=/home/headless STARTUPDIR=/dockerstartup`, entrypoint `tini -- /dockerstartup/startup.sh`, stages: `stage_mesa` (apt `mesa-utils mesa-utils-extra glmark2`), `stage_virtualgl` (VirtualGL deb + `vglserver_config -config +s +f -t`), noVNC, browsers; the final image only includes Mesa/VirtualGL/noVNC when the stage ARGs are overridden (the opengl image does that). |
| Ports | accetto: 5901 (VNC), 6901 (noVNC). ContainerForge replaces both with the existing KasmVNC web stack on 3000/3001 (see below). |
| Env vars | accetto: `VNC_PW`, `VNC_RESOLUTION`, `VNC_PORT`, `NOVNC_PORT`, `DISPLAY`. Not used in this plan (the base `kasmvnc` image reads `PASSWORD`, `CUSTOM_USER`, `CUSTOM_PORT`, `CUSTOM_HTTPS_PORT`, `SUBFOLDER`, per `apps/kasmvnc/settings.yaml`). README of accetto g3 on `/dev/dri`/shm: not read (UNVERIFIED). |

## 2. Target layout

```
apps/opengl-desktop-g3/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh                   # prepares /config, hands over to the base desktop init
  defaults/autostart         # overrides the base's openbox autostart: terminal + glxgears hint
```
No `root/`, no `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/kasmvnc:1.5.2@sha256:870414f75035f215e19dbb5583e163b5d8e603e41ca8fa0e4669323c45fbdc27`

(Digest of the `1.5.2` tag read from ghcr.io on 2026-11-24; `apps/kasmvnc/docker-bake.hcl` `VERSION` is `1.5.2`.) Why: replaces accetto's XFCE+TigerVNC+noVNC chain with the repo's existing, already rootless-adapted KasmVNC web desktop (openbox, `apps` user, `/config` home); only Mesa and VirtualGL are added. This is a deliberate deviation from the draft (XFCE, two browsers, 5901/6901 are dropped); a future change can add `xfce4` packages if needed. Closest sibling: `apps/kasmvnc`, then `apps/rdesktop`.

## 4. Dockerfile

1. `FROM` above; `ARG VERSION`, `ARG TARGETARCH`, `ARG VIRTUALGL_SHA256_AMD64`, `ARG VIRTUALGL_SHA256_ARM64` (values computed at implementation time); `USER root`.
2. `apt-get update && apt-get install -y --no-install-recommends mesa-utils mesa-utils-extra libgl1-mesa-dri libegl1 libglx-mesa0 glmark2-x11 xterm` (names from the accetto stage and Ubuntu's mesa packaging; check each against 26.04 and against what the kasmvnc base already installed, `libgl1-mesa-dri` and `libgbm` are in its build stage only: UNVERIFIED for the runtime stage). Apt packages are not version-defining here; they are not pinned (the tracked version is VirtualGL).
3. VirtualGL: `case "${TARGETARCH}" in amd64) sha="${VIRTUALGL_SHA256_AMD64}";; arm64) sha="${VIRTUALGL_SHA256_ARM64}";; esac`; `curl -fsSL -o /tmp/vgl.deb "https://github.com/VirtualGL/virtualgl/releases/download/${VERSION}/virtualgl_${VERSION}_${TARGETARCH}.deb"`; `echo "${sha}  /tmp/vgl.deb" | sha256sum -c -`; `apt-get install -y --no-install-recommends /tmp/vgl.deb`; assert `dpkg-query -W -f='${Version}' virtualgl | grep -q "^${VERSION}"`. Do NOT run `vglserver_config` (needs root, GPU, and modifies `/etc`); VirtualGL is used through `vglrun` with the EGL backend (`VGL_DISPLAY=egl`/`/dev/dri/cardN`), UNVERIFIED for the KasmVNC Xvnc server.
4. Licence files: `mkdir -p /usr/share/licenses/opengl-desktop-g3 && cp /usr/share/doc/virtualgl/copyright /usr/share/licenses/opengl-desktop-g3/virtualgl-copyright` (path UNVERIFIED), plus the accetto MIT licence fetched with `curl -fsSL https://raw.githubusercontent.com/accetto/headless-drawing-g3/master/LICENSE` only if its recipe is reused (it is not copied, so optional).
5. `rm -rf /tmp/* /var/lib/apt/lists/*`.
6. ENV: `HOME=/config` (as base), `XDG_CACHE_HOME=/tmp/.cache`, `LIBGL_ALWAYS_SOFTWARE` left unset (software fallback is Mesa's default without `/dev/dri`).
7. `USER apps`
8. `COPY --chmod=0755 . /`
9. `EXPOSE 3000 3001`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
variable "APP" {
  default = "opengl-desktop-g3"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=VirtualGL/virtualgl versioning=semver
  default = "3.1.5"
}

variable "LICENSE" {
  default = "wxWindows"
}

variable "SOURCE" {
  default = "https://github.com/accetto/headless-drawing-g3"
}
```
With `target "docker-metadata-action" {}`, `group "default" { targets = ["image-local"] }`, `image` (args VERSION), `image-local` (`output = ["type=docker"]`, `tags = ["${APP}:${VERSION}"]`), `image-all` (`linux/amd64`, `linux/arm64`; the draft says accetto has no arm64 image, but the VirtualGL arm64 deb exists and the kasmvnc base is multi-arch: UNVERIFIED that the base publishes arm64). Validate: `docker buildx bake --print`. `LICENSE` value to be confirmed (section 1).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/accetto/headless-drawing-g3"
ports:
  - port: 3000
    protocol: tcp
    required: false
  - port: 3001
    protocol: tcp
    required: false
env:
  - name: CUSTOM_PORT
    default: "3000"
    required: false
  - name: CUSTOM_HTTPS_PORT
    default: "3001"
    required: false
  - name: CUSTOM_USER
    default: "apps"
    required: false
  - name: PASSWORD
    default: ""
    required: false
  - name: SUBFOLDER
    default: "/"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```
The env set equals `apps/kasmvnc/settings.yaml` minus nothing: these names are actually read by the base's start logic (not accetto's `VNC_PW`, which would be silently ignored). The draft's 5901/6901 are not opened and therefore not listed. Draft extra persistence `/UNRAID_SHARE` is a runtime mount, not part of the image (do not declare it).

## 7. start.sh

CONFLICT: `COPY --chmod=0755 . /` would overwrite the base's `/start.sh` (apps/kasmvnc/start.sh seeds openbox config, starts nginx and ends with `cd /kclient; exec node index.js`). A replacement must either use another file name and chain to the base `/start.sh`, or reproduce all of the base logic (UNVERIFIED which is intended). Idempotent steps:
1. `mkdir -p /config/.config/openbox /config/Desktop /tmp/.cache`.
2. Seed `/config/.config/openbox/autostart` from `/defaults/autostart` only when missing (the base does this too; keep ours consistent). `defaults/autostart` starts `xterm` and prints `glxinfo -B` so users can see the renderer. Existing user state is never overwritten.
3. Export `VGL_DISPLAY` only when `/dev/dri/renderD128` (or any `/dev/dri/card*`) exists and is readable; otherwise log `No /dev/dri, using software Mesa (llvmpipe)`.
4. Final: hand over to the base's desktop launcher exactly as `apps/kasmvnc/start.sh` ends (copy its last `exec` line; UNVERIFIED which command). No `exec` of our own long-running process otherwise. All listeners (KasmVNC 3000/3001) bind all interfaces (confirm with `ss -ltn`).

Never write to `/app`; caches in `/tmp`; persistent state in `/config`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '3000'
- port: '3001'
filePaths:
- /usr/bin/vglrun
- /usr/bin/glxinfo
- /usr/share/licenses/opengl-desktop-g3
- /defaults/autostart
- /start.sh
```
Every port in settings.yaml (3000, 3001) has a `tcp` probe, same as `apps/kasmvnc`. `/usr/bin/vglrun` is the VirtualGL launcher (path UNVERIFIED, verify with `dpkg -L virtualgl`; the deb may install under `/opt/VirtualGL/bin` with symlinks).

## 9. Rootless and read-only-rootfs adaptations

| Upstream behaviour | Remap |
|---|---|
| accetto runs as UID 1001 `headless`, `sudo` with initial password, home `/home/headless` | `apps` (568), no sudo, `HOME=/config` |
| `vglserver_config -config +s +f -t` (root, changes /etc and X permissions) | Removed; EGL backend used without server config |
| VNC/noVNC on 5901/6901, `VNC_PW` | KasmVNC web on 3000/3001, `PASSWORD`/`CUSTOM_USER` |
| `/dockerstartup` scripts writing under `$HOME` | base init writes only to `/config` and `/tmp` (as in apps/kasmvnc) |
| GPU: `/dev/dri` | optional runtime device; `apps` already belongs to GIDs 44/107/129 (video/render class groups in `apps/ubuntu/Dockerfile`), so a device mounted with those groups works without root; groups on the host differ (UNVERIFIED) |
| Draft: UID 0, rootfs writable, `/UNRAID_SHARE` pvc | UID 568, read-only rootfs, `/config` only; the share is a deployment-time mount |
| Shared memory for browsers | no browsers included; if added later set `--shm-size` |

## 10. Risks, caveats and open questions

- This is a re-implementation, not a port: no XFCE, no Firefox/Chromium, no TigerVNC, ports differ. Decide with the user if XFCE and browsers are mandatory (they would add large apt installs and `/dev/shm` needs).
- Real GPU acceleration needs `/dev/dri`; without it Mesa llvmpipe software rendering is used (slow). VirtualGL with an Xvnc/KasmVNC server and the EGL backend is UNVERIFIED; if it does not work, keep Mesa only and drop VirtualGL (then `VERSION` should track Mesa/ubuntu instead).
- The version tracked (VirtualGL 3.1.5) is not the "app version" users expect (accetto G3v8).
- Large image in RAM and disk.
- No upstream licence verified for VirtualGL (UNVERIFIED), no published checksums.
- arm64: accetto has none (draft); this plan builds arm64 only if the `kasmvnc` base is arm64 (UNVERIFIED).
- UNVERIFIED count: 10 (VirtualGL licence/SPDX, checksums, EGL under KasmVNC, `/dev/dri` group ids, mesa package names on 26.04, vglrun path, kasmvnc arm64, hand-over command in base start.sh, accetto env/README details, copyright path).

## 11. Build and test steps

```sh
cd apps/opengl-desktop-g3
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create opengl-desktop-g3-probe-config
docker run --rm -d --name opengl-desktop-g3-probe --read-only --tmpfs /tmp -v opengl-desktop-g3-probe-config:/config opengl-desktop-g3:3.1.5
docker logs -f opengl-desktop-g3-probe
forgetool containers test --image opengl-desktop-g3:3.1.5 --config ./apps/opengl-desktop-g3/container-test.yaml
docker rm -f opengl-desktop-g3-probe; docker volume rm opengl-desktop-g3-probe-config
```
Readiness: KasmVNC web server answers on 3000 (open `http://localhost:3000`), the xterm autostart appears, `docker exec opengl-desktop-g3-probe glxinfo -B` reports `llvmpipe` (software) and `vglrun glxgears` runs; with `--device /dev/dri` check the renderer changes (only if hardware is available). Empty `/config` start required. Round limit 10; clean scratch containers/volumes each round.

## 12. PR checklist

- Branch `feat/add-opengl-desktop-g3`; commit and PR title `feat(opengl-desktop-g3): add new container`; target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md` (keep sections, tick only applicable boxes); include source, tracked version (VirtualGL 3.1.5), base `kasmvnc:1.5.2`, ports/volumes, and the deviations from the draft (no XFCE/browsers/5901/6901); `🤖 This PR is AI generated.` in Notes.
- CLA notice for the user: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested at plan time: build, run, GPU path through `/dev/dri`, VirtualGL under KasmVNC, arm64, read-only rootfs behaviour of the desktop. Do not check "Built container locally" unless done.
