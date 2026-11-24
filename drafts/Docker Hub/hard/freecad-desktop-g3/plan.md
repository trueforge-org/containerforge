# freecad-desktop-g3 — implementation plan
> Source: ./draft.md · Target: apps/freecad-desktop-g3/ (suggest naming it `freecad`) · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | 1.1.4 (latest stable per freecad.org downloads; last planned 1.1.x maintenance release; sourceforge folder dated 2026-09-28). 26.3 (calendar versioning) release candidates exist (`26.3rc2`, weekly builds) but are pre-releases. |
| Renovate | `datasource=github-releases depName=FreeCAD/FreeCAD versioning=loose` (the repo also holds `weekly-*` pre-releases; Renovate skips pre-releases by default; confirm it does not pick `26.3rc2`) |
| License | LGPL-2.1-or-later (UNVERIFIED in this session; FreeCAD is documented as LGPL-2+) |
| Source URL | https://github.com/FreeCAD/FreeCAD |
| Download | Draft says `apt:freecad`, but the accetto Dockerfile (https://github.com/accetto/headless-drawing-g3/blob/master/docker/Dockerfile.xfce.drawing.freecad) uses the **AppImage**, which tracks upstream. aarch64: `FreeCAD_1.1.4-Linux-aarch64-py311.AppImage` (SourceForge, 755.6 MB). x86_64 name by analogy `FreeCAD_1.1.4-Linux-x86_64-py311.AppImage` (UNVERIFIED), hosted on GitHub releases tag `1.1.4` and SourceForge `/1.1.4/`. |
| Checksum | A SHA256 file sits next to each AppImage on SourceForge (verified for aarch64). |
| Upstream Dockerfile reviewed | accetto: Ubuntu 24.04 + TigerVNC + noVNC + XFCE; FreeCAD AppImage into `/opt/FreeCAD`; needs OpenGL, so `mesa-utils`; extra libs `libpci3 libxss1 libxtst6`; user 1001 `headless`; ports VNC 5901, noVNC 6901 |
| Ports for this repo | 3000 / 3001 (KasmVNC base), not 5901/6901 |

## 2. Target layout

```
apps/freecad-desktop-g3/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  defaults/autostart    # launches freecad inside the KasmVNC openbox session
```
No `start.sh` (would clobber the kasmvnc base's `/start.sh` via `COPY . /`; see section 7). No `root/`, no `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/kasmvnc:1.5.2@sha256:<UNVERIFIED: read the digest from ghcr.io when implementing>`

Why: the draft says "the kasmvnc or xvfb sibling applies"; `apps/kasmvnc` exists (version from its docker-bake.hcl). It brings openbox, KasmVNC, `USER apps`. XFCE from the accetto image is not needed and not installed. Closest siblings: `apps/kasmvnc`, `apps/kasm`.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`; map `amd64 -> x86_64`, `arm64 -> aarch64`.
2. `USER root`.
3. apt (not already in kasmvnc base; verify with `dpkg -l`): `libpci3 libxss1 libxtst6 mesa-utils libgl1-mesa-dri libglu1-mesa libfuse2t64` (libfuse2 not needed when extracting). Not version-pinned (the image version is the AppImage, not an apt package).
4. Download `https://github.com/FreeCAD/FreeCAD/releases/download/${VERSION}/FreeCAD_${VERSION}-Linux-${ARCH}-py311.AppImage` and the matching `.sha256`/`-SHA256.txt` file (name UNVERIFIED), `sha256sum -c`, `chmod +x`, then `./FreeCAD*.AppImage --appimage-extract && mv squashfs-root /app/freecad` (run as root during build, since FUSE is not available in the build or at runtime).
5. `ln -s /app/freecad/AppRun /usr/local/bin/freecad`.
6. Licenses to `/usr/share/licenses/freecad/` (from the extracted tree if present, else fetch `LICENSE` of the tag).
7. `ENV HOME=/config XDG_CONFIG_HOME=/config/.config XDG_CACHE_HOME=/tmp/.cache XDG_DATA_HOME=/config/.local/share LIBGL_ALWAYS_SOFTWARE=1`.
8. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 3000 3001`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

- `APP` `freecad-desktop-g3` (decide the final name; `freecad` is cleaner); `VERSION` `1.1.4` with `// renovate: datasource=github-releases depName=FreeCAD/FreeCAD versioning=loose`.
- `LICENSE` `LGPL-2.1-or-later`; `SOURCE` `https://github.com/FreeCAD/FreeCAD`.
- 4 standard targets and `default` group; `image-all` amd64+arm64. `docker buildx bake --print`.

## 6. settings.yaml

- Header, `schema_version: 1`, `upstream_env_url: "https://github.com/FreeCAD/FreeCAD"`.
- ports: `3000/tcp`, `3001/tcp`.
- env: `TZ`, `CUSTOM_USER`, `PASSWORD`, `SUBFOLDER`, `CUSTOM_PORT`, `CUSTOM_HTTPS_PORT` (copy from `apps/kasmvnc/settings.yaml`, defaults identical).
- volumes: `/config` (required true; projects live in `/config/projects`, replacing the chart's `/UNRAID_SHARE`).
- dependencies: none.

## 7. start.sh

Not applicable: the base's `/start.sh` seeds `/config/.config/openbox/autostart` from `/defaults/autostart` only if missing, then launches KasmVNC, openbox and kclient (`exec node index.js`). This app overrides `/defaults/autostart` with `mkdir -p /config/projects && exec freecad "$@"`-style content (`freecad &` form, keep it non-blocking). `/config` startup is therefore idempotent via the base.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120   # copy from apps/kasmvnc if different
tcp:
- port: '3000'
- port: '3001'
```
Add a runner/file assertion `test -x /app/freecad/AppRun` using the sibling schema's key (see `apps/bookstack/container-test.yaml` runners; note it disables the main runner, so do not copy `mainRunner.enabled: false` here).

## 9. Rootless and read-only-rootfs adaptations

- Draft: root, writable rootfs, `/UNRAID_SHARE`. Target: `USER apps`, `/app` read-only, config `/config/.config/FreeCAD`, user data `/config/.local/share/FreeCAD`, cache/temp `/tmp`.
- AppImage extracted at build time, so no FUSE and no writes to `/app`.
- Software OpenGL (llvmpipe) is slow but needs no GPU; no privilege needed.
- Map `/UNRAID_SHARE` to `/config/projects`; document that users who want the old path can bind-mount it there.

## 10. Risks, caveats and open questions

- Image is large (AppImage ~750 MB uncompressed plus mesa).
- x86_64 AppImage asset name and checksum file name UNVERIFIED (only the aarch64 one was seen).
- 26.3 calendar-versioned releases will replace 1.1.x; Renovate may jump versions.
- FreeCAD under llvmpipe: possible Qt/xcb plugin libs missing; resolve at the first run (`QT_QPA_PLATFORM=xcb`).
- Ubuntu apt `freecad` alternative exists (draft) but lags upstream and is not version aligned; rejected for that reason.
- kasmvnc base digest and version must be kept in sync.

## 11. Build and test steps

```sh
cd apps/freecad-desktop-g3
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create freecad-desktop-g3-probe-config
docker run --rm -d --name freecad-desktop-g3-probe --read-only --tmpfs /tmp -v freecad-desktop-g3-probe-config:/config freecad-desktop-g3:1.1.4
docker logs -f freecad-desktop-g3-probe   # expect KasmVNC listening on 3000, no FreeCAD crash
forgetool containers test --image freecad-desktop-g3:1.1.4 --config ./apps/freecad-desktop-g3/container-test.yaml
docker rm -f freecad-desktop-g3-probe; docker volume rm freecad-desktop-g3-probe-config
```

## 12. PR checklist

- Branch `feat/add-freecad-desktop-g3`, commit `feat(freecad-desktop-g3): add new container`.
- Template filled, `🤖 This PR is AI generated.` in Notes.
- CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested: build, AppImage extraction, GUI launch, arm64, checksum asset names.
