# cura-novnc — implementation plan
> Source: ./draft.md · Target: apps/cura-novnc/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `5.14.0` is the newest UltiMaker Cura release (2026-11-05). The draft used `5.8.1` (the `mikeah/cura-novnc` image tag; wrapper repo `helfrichmichael/cura-novnc` latest release also `5.8.1`). Plan uses the newest Cura on amd64; arm64 cannot match (see below). |
| Renovate | `datasource=github-releases depName=Ultimaker/Cura versioning=loose` (tags are plain `5.14.0`; there are also `-RC` tags, release feed lists RC and final, so use `loose` and let the release flag filter prereleases). |
| License | `LGPL-3.0-or-later` (Cura LICENSE is "GNU LESSER GENERAL PUBLIC LICENSE Version 3"; Cura source headers say "or later", UNVERIFIED per file). |
| Source | https://github.com/Ultimaker/Cura |
| amd64 | `https://github.com/Ultimaker/Cura/releases/download/${VERSION}/UltiMaker-Cura-${VERSION}-linux-X64.AppImage` (370,960,888 bytes for 5.14.0). Signature file `...AppImage.asc` is published (GPG, no sha256 file). |
| arm64 | No AppImage (release assets are linux-X64 only plus macOS/Windows). Ubuntu 26.04 (resolute, universe) has `cura` `5.0.0-6build1`, arch `all`. So arm64 would get Cura 5.0.0 (draft caveat confirmed). |
| Wrapper Dockerfile | `helfrichmichael/cura-novnc/Dockerfile` reviewed: debian bullseye, `easy-novnc` v1.1.0 on 8080, TigerVNC on 5900, supervisord, openbox, runs as user `cura`, AppImage `--appimage-extract`, sed `QT_QPA_PLATFORMTHEME=xdgdesktopportal` to `gtk3` in `AppRun`, `VOLUME /home/cura/` and `/prints/`, `usermod -aG dialout cura`. Ports there are 8080 (HTTP) and 5900 (VNC), NOT 6080 as the draft guessed. |
| Runtime env | None of its own. Desktop env comes from the kasmvnc base (`CUSTOM_PORT`, `CUSTOM_HTTPS_PORT`, `CUSTOM_USER`, `PASSWORD`, `SUBFOLDER`, `TZ`, per `apps/kasmvnc/settings.yaml`). |

## 2. Target layout

```
apps/cura-novnc/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh          # only if a wrapper around the base start is needed (see section 7)
  defaults/
    autostart       # overrides the base /defaults/autostart so openbox launches Cura
    menu.xml        # optional openbox menu entry (copy base menu.xml and add Cura)
```
`defaults/` is allowed by `include/.dockerignore`. Never use `root/` (even though `apps/kasmvnc` does). No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/kasmvnc:1.5.2@sha256:<digest>`. `apps/kasmvnc/docker-bake.hcl` `VERSION` is `1.5.2` (renovate `kasmtech/KasmVNC`). The digest and the registry tag are UNVERIFIED (nothing in `apps/` uses kasmvnc as `FROM` yet, so there is no line to copy): resolve with `docker buildx imagetools inspect ghcr.io/trueforge-org/kasmvnc:1.5.2` before writing, or add the line with the digest Renovate will maintain. Why: replaces the draft's "kasmvnc sibling container": Cura is a desktop GUI, so it runs inside the kasmvnc desktop image, giving a single container (web client on 3000/3001) instead of easy-novnc + TigerVNC + supervisord. Closest sibling: `apps/kasmvnc` itself (consumer pattern: `autostart` + `defaults/`). Because it is a `FROM` consumer, no changes needed to kasmvnc itself.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`; `USER root`.
2. Packages (check what the kasmvnc base already has first, with `dpkg -l` in a scratch run; do not duplicate): `libgl1 libegl1 libxkbcommon0 libgl1-mesa-dri libglu1-mesa libxcb-cursor0 libnss3 libxcomposite1 libxdamage1 libxrandr2 libxtst6 libxss1` (Qt 6 xcb needs; all inferred, remove unneeded ones after the first run), `openscad` optional (wrapper installs it for scripts). Arm64: `apt-get install -y cura=5.0.0-6build1` (pin; renovate cannot track it).
3. amd64: `curl -fsSL -o /tmp/cura.AppImage "https://github.com/Ultimaker/Cura/releases/download/${VERSION}/UltiMaker-Cura-${VERSION}-linux-X64.AppImage"` and the `.asc`; verify with `gpg --verify` against the UltiMaker release key (UNVERIFIED key id: look it up from UltiMaker docs; otherwise pin a sha256 you compute). Then `chmod +x`, `./cura.AppImage --appimage-extract` in `/tmp`, `mv squashfs-root /app/cura`, and `sed -i 's/QT_QPA_PLATFORMTHEME=xdgdesktopportal/QT_QPA_PLATFORMTHEME=gtk3/' /app/cura/AppRun`. No FUSE needed.
4. License: copy `LICENSE` (from the extracted tree or the source) to `/usr/share/licenses/cura-novnc/`.
5. Arch switch: `if [ "$TARGETARCH" = "amd64" ]; then ...; else apt-get install cura; fi`. Provide a launcher `/usr/local/bin/cura` (create in the `RUN` via `ln -s /app/cura/AppRun /usr/local/bin/cura` on amd64; arm64 uses the apt-provided `/usr/bin/cura`).
6. `ENV QT_QPA_PLATFORM=xcb LIBGL_ALWAYS_SOFTWARE=1 MESA_GL_VERSION_OVERRIDE=4.5 XDG_DOWNLOAD_DIR=/config/prints` (software GL for Xvnc, since kasmvnc has no GPU; the override values are UNVERIFIED, test Cura start).
7. `mkdir -p /prints && chown apps:apps /prints`; `chown -R apps:apps /app/cura`; cleanup `rm -rf /tmp/* /var/lib/apt/lists/*`.
8. `USER apps`, `COPY --chmod=0755 . /` (copies `defaults/autostart` over the base file), `EXPOSE 3000 3001`, `VOLUME /config`, `VOLUME /prints`. Keep base `WORKDIR /config`/entrypoint (inherited; do not redefine).

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "cura-novnc" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=Ultimaker/Cura versioning=loose
  default = "5.14.0"
}
variable "LICENSE" { default = "LGPL-3.0-or-later" }
variable "SOURCE"  { default = "https://github.com/Ultimaker/Cura" }
```
Standard targets (`docker-metadata-action`, `image` with `args.VERSION`, `image-local`, `image-all` amd64 + arm64, `group "default"`) copied from `apps/adguardhome-sync`. Note in a comment that `VERSION` only applies to amd64; arm64 has apt Cura 5.0.0. Run `docker buildx bake --print`.

## 6. settings.yaml

Header + `schema_version: 1`; `upstream_env_url: "https://github.com/Ultimaker/Cura"`.
- ports: `3000` tcp (web client http, required), `3001` tcp (https, required: false). Do not list 5900/8080/6080 (not opened by this image).
- env: same set as `apps/kasmvnc/settings.yaml` that the base reads: `TZ` (`Etc/UTC`), `CUSTOM_PORT` (`3000`), `CUSTOM_HTTPS_PORT` (`3001`), `CUSTOM_USER` (`apps`), `PASSWORD` (`""`), `SUBFOLDER` (`/`).
- volumes: `/config` required (Cura settings under `/config/.config/cura` and `/config/.local/share/cura`), `/prints` (required: false, STL/GCODE exchange).
- dependencies: `kasmvnc` ✅ (exists as `apps/kasmvnc`; it is a build-time base, not a runtime sidecar).

## 7. start.sh

Not needed if the base start script already runs openbox and `/config/.config/openbox/autostart` is seeded from `/defaults/autostart` when missing (verified in `apps/kasmvnc/start.sh`). Therefore ship only `defaults/autostart`:

```
cura
```
(`/app/cura/AppRun` symlinked as `cura`; use `exec`-less single line, openbox autostart is plain shell.) Caveat: the base only copies the autostart when `/config/.config/openbox/autostart` is missing, so an existing config volume keeps an old file; document it. Do not add a start.sh unless the first test shows Cura needs env set before openbox.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '3000'
- port: '3001'
filePaths:
- /usr/local/bin/cura
- /defaults/autostart
- /usr/share/licenses/cura-novnc
```
`/usr/local/bin/cura` is a symlink only on amd64; on arm64 use `/usr/bin/cura`. Because tests run on both arches, test only `/defaults/autostart` and the license dir in `filePaths`, and verify the `cura` binary by hand per arch. `timeoutSeconds`: copy `apps/kasmvnc/container-test.yaml` (it has none; add a generous value because Xvnc + openbox take about 5 s).

## 9. Rootless and read-only-rootfs adaptations

- Draft expected root (UID 0), `readOnlyRootFilesystem: false`, persistence `/home/cura/` and `/prints/`. Reconcile: run as `apps` (UID 568) like the base; Cura state moves to `/config` (`HOME=/config`), prints to `/prints`.
- Cura writes `~/.config/cura`, `~/.local/share/cura`, `~/.cache` and a temp dir: set `XDG_CACHE_HOME=/tmp/cache` and let Qt temp go to `/tmp`; settings stay in `/config`. AppImage tree lives in `/app/cura` read-only. `QT_QPA_PLATFORMTHEME=gtk3` sed is done at build time, not runtime.
- USB printing needs `dialout` access (`usermod -aG dialout apps` is possible at build) and `--device=/dev/ttyUSB0`; document as optional.
- Not privileged.

## 10. Risks, caveats and open questions

- Architecture skew: amd64 5.14.0 vs arm64 apt 5.0.0 (and apt version cannot be renovated). Alternative: ship amd64 only. Decide before the first PR.
- `kasmvnc` image reference and digest are UNVERIFIED (no consumer exists; it is also a large image with `root/` layout we must not copy).
- Cura needs OpenGL 4.1+ for its default renderer; Xvnc has no GL, software rendering through Mesa llvmpipe may be slow or fail. UNVERIFIED until a run.
- `ghcr.io/trueforge-org/kasmvnc` may not be published yet; if not, the plan is blocked until it is.
- AppImage extraction is 1 GB+ unpacked; image size is large.
- The signing key for the `.asc` is not verified; fall back to a self-computed sha256 pin.

## 11. Build and test steps

```sh
cd apps/cura-novnc
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name cura-novnc-probe --read-only --tmpfs /tmp \
  -v cura-novnc-probe-config:/config -v cura-novnc-probe-prints:/prints cura-novnc:5.14.0
docker logs -f cura-novnc-probe   # expect kasmvnc Xvnc + nginx + kclient start, then a Cura window; port 3000 open
forgetool containers test --image cura-novnc:5.14.0 --config ./apps/cura-novnc/container-test.yaml
docker rm -f cura-novnc-probe; docker volume rm cura-novnc-probe-config cura-novnc-probe-prints
```
Open `http://localhost:3000` manually and confirm the Cura window renders. Run arm64 only after amd64 passes.

## 12. PR checklist

- Branch `feat/add-cura-novnc`; commit and PR title `feat(cura-novnc): add new container`; target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; `🤖 This PR is AI generated.` in Notes.
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Honest list of untested items: kasmvnc base reference, GPU-less OpenGL, arm64 apt Cura 5.0.0, USB printing, signature verification, the read-only rootfs run.
