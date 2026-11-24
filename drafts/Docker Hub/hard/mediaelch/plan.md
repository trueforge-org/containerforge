# mediaelch — implementation plan
> Source: ./draft.md · Target: apps/mediaelch/ · Difficulty: hard (Qt GUI behind a web desktop) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `2.12.0` (latest release and tag, published 2024-10-13). `master` already reads 2.12.1 in CMake, but it is unreleased. The last release is over two years old, so expect slow upstream updates. |
| Renovate | `datasource=github-releases depName=Komet/MediaElch versioning=semver`. Tags are `v2.12.0`, so the Dockerfile adds `v`. |
| License | LGPL-3.0 (SPDX `LGPL-3.0-only`; GitHub reports `lgpl-3.0`; `COPYING` is the LGPL v3 text) |
| Source | https://github.com/Komet/MediaElch |
| amd64 | `https://github.com/Komet/MediaElch/releases/download/v2.12.0/MediaElch_linux_2.12.0_2024-10-13_git-8032465.AppImage` (70,395,072 bytes). The file name contains a date and a git hash, so it cannot be derived from `VERSION` alone. Keep the date and hash as two extra bake variables, or use the source build for both arches (see section 10). |
| arm64 | No release asset. Build from the tag with CMake and Qt6. Needs `git clone --recurse-submodules` (the repo has `.gitmodules` and `third_party/`), because GitHub's archive tarball does not include submodules. |
| Checksum | UNVERIFIED: the release publishes no checksum file. Compute the sha256 once and pin it in the Dockerfile as an `ARG`, and update it with each bump. |
| Upstream Dockerfile reviewed | `Giftie/docker-mediaelch` (draft link). It is `jlesage/baseimage-gui:ubuntu-18.04`, installs the `mediaelch` PPA package and ffmpeg, and creates a `mediaelch` user. It is old, so only the idea (GUI over VNC plus ffmpeg) is reused. |
| Build deps (from `debian/control`) | `cmake libmediainfo-dev libqt6opengl6-dev libquazip1-qt6-dev libxkbcommon-dev libzen-dev qt6-base-dev qt6-multimedia-dev qt6-svg-dev qt6-tools-dev` (CMake needs Qt >= 6.3 and Core5Compat). Runtime deps: `libqt6svg6 libmediainfo0v5 libzen0v5`. Package names on Ubuntu 26.04 are UNVERIFIED. |
| Ports | MediaElch has no port. The web desktop comes from the existing `apps/kasmvnc` image, which exposes 3000 (HTTP) and 3001 (HTTPS). The draft's 5800/5900 (jlesage noVNC and VNC) do not apply. |
| Config location | `Settings.cpp` uses `QSettings` (INI, `MediaElch.ini` in the app dir only in portable mode). By default the file is under `$XDG_CONFIG_HOME` or `~/.config`. Pointing `HOME` and `XDG_CONFIG_HOME` to `/config` is enough. UNVERIFIED: exact subfolder name. |

## 2. Target layout

```
apps/mediaelch/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh                  # thin wrapper, see section 7
  defaults/autostart        # openbox autostart that launches MediaElch
```
No `root/` (reserved). No `DOWNSTREAM_CHANGES.md` because nothing uses this image as a base. This image changes nothing in `apps/kasmvnc`.

## 3. Base image

`FROM ghcr.io/trueforge-org/kasmvnc:1.5.2` (the version from `apps/kasmvnc/docker-bake.hcl`). Add `@sha256:...` from `docker buildx imagetools inspect ghcr.io/trueforge-org/kasmvnc:1.5.2`. UNVERIFIED: the digest and that the image is published on GHCR. Kasmvnc is Ubuntu 26.04 plus Xvnc, openbox, nginx and a Node `kclient` wrapper, so MediaElch only adds the app. Sibling for the GUI layer: `apps/kasmvnc` (uses `/defaults/autostart` copied to `/config/.config/openbox/autostart` on first run). For the prebuilt-binary part: `apps/adguardhome-sync`.

## 4. Dockerfile

Three stages:
1. `appimage` (ubuntu, amd64 only): `ARG TARGETARCH`. If `amd64`, download the AppImage, check the pinned sha256, `chmod +x`, run `./MediaElch*.AppImage --appimage-extract` (no FUSE is needed for this), and move `squashfs-root` to `/out/mediaelch`. Otherwise `mkdir -p /out/mediaelch`.
2. `srcbuild` (ubuntu, arm64 only): install the build deps above plus `git build-essential`. `git clone --depth 1 --branch v${VERSION} --recurse-submodules https://github.com/Komet/MediaElch.git`, then `cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DMEDIAELCH_FORCE_QT6=ON -DCMAKE_INSTALL_PREFIX=/out/mediaelch && cmake --build build -j$(nproc) && cmake --install build`. On amd64 do `mkdir -p /out/mediaelch`.
3. Final: `FROM ghcr.io/trueforge-org/kasmvnc:1.5.2@sha256:...`
   - `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
   - `apt-get install -y --no-install-recommends ffmpeg mediainfo libmediainfo0v5 libzen0v5 libqt6svg6 libqt6multimedia6 libquazip1-qt6-1t64 fonts-noto` (check what kasmvnc already ships first; package names UNVERIFIED), then clean apt lists. ffmpeg is needed by MediaElch to create screenshots.
   - `COPY --from=appimage /out/mediaelch /app/mediaelch` and `COPY --from=srcbuild /out/mediaelch /app/mediaelch` (one of them is empty per arch). If both are copied into the same folder, keep them in different subfolders, `/app/mediaelch-appimage` and `/app/mediaelch-src`, and let `/usr/local/bin/mediaelch` (a small wrapper installed here) pick the one that has an executable.
   - License: `install -D COPYING /usr/share/licenses/mediaelch/COPYING` (taken from the clone in stage 2 and from `curl https://raw.githubusercontent.com/Komet/MediaElch/v${VERSION}/COPYING` in stage 1).
   - `ENV HOME=/config XDG_CONFIG_HOME=/config/.config XDG_CACHE_HOME=/tmp/.cache QT_QPA_PLATFORM=xcb`
   - Keep the kasmvnc entrypoint: `mv /start.sh /usr/local/bin/kasmvnc-start.sh` (UNVERIFIED that kasmvnc's script lives at `/start.sh`; confirm in the base image).
   - `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 3000 3001`, `VOLUME /config`.

## 5. docker-bake.hcl

- `APP=mediaelch`, `LICENSE=LGPL-3.0-only`, `SOURCE=https://github.com/Komet/MediaElch`.
- `VERSION` = `2.12.0` with `// renovate: datasource=github-releases depName=Komet/MediaElch versioning=semver`.
- Extra variables `APPIMAGE_DATE` = `2024-10-13`, `APPIMAGE_GIT` = `8032465` and `APPIMAGE_SHA256`, passed as `args` and kept next to `VERSION`. Renovate cannot update them, so bumps are manual. Mention this in the PR.
- Standard four targets plus `group "default"`. Check with `docker buildx bake --print`.

## 6. settings.yaml

- Header, `schema_version: 1`, `upstream_env_url: "https://github.com/Komet/MediaElch"`.
- `ports`: 3000 tcp and 3001 tcp, both `required: false`.
- `env` (the web desktop vars are the ones `apps/kasmvnc` really reads): `TZ` (`Etc/UTC`), `CUSTOM_PORT` (`3000`), `CUSTOM_HTTPS_PORT` (`3001`), `CUSTOM_USER` (`apps`), `PASSWORD` (empty, required false, but set it before exposing the UI), `SUBFOLDER` (`/`).
- `volumes`: `/config` required. Also list `/media` as `required: false` for the media library (the chart's `/shows` PVC should be mounted there, or keep the chart path and select it in the UI).
- `dependencies`: none.

## 7. start.sh

Wrapper only. It must not re-implement kasmvnc.
```bash
#!/usr/bin/env bash
set -euo pipefail
mkdir -p /config/.config/openbox /config/.config /tmp/.cache
# Seed the openbox autostart once, so a user edit survives
if [[ ! -s /config/.config/openbox/autostart ]]; then
  cp /defaults/autostart /config/.config/openbox/autostart
fi
exec /usr/local/bin/kasmvnc-start.sh "$@"
```
`defaults/autostart` contains one line: `/usr/local/bin/mediaelch &` (the wrapper sets `QT_QPA_PLATFORM=xcb`, runs from `/config`, and runs `AppRun` or `bin/mediaelch`). Note that the base `kasmvnc` start script copies its own `/defaults/autostart` only when the file is missing. Because we pre-seed first, ours wins. Servers listen on 0.0.0.0 already (Xvnc `-interface 0.0.0.0`, nginx on the custom ports).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 240
tcp:
- port: '3000'
- port: '3001'
filePaths:
- /usr/local/bin/mediaelch
- /usr/share/licenses/mediaelch/COPYING
runners:
- entrypoint: test -x /usr/local/bin/kasmvnc-start.sh
```
The test runs with no env, so the password path (`PASSWORD`) is not covered. Run it by hand in section 11. The `http` probe is skipped because kasmvnc's nginx may answer 401 or redirect. Use `tcp` as `apps/kasmvnc` does.

## 9. Rootless and read-only-rootfs adaptations

| Upstream or base write path | Remap |
|---|---|
| `~/.config/...` (QSettings), MediaElch cache and image cache | `HOME=/config`, `XDG_CONFIG_HOME=/config/.config`; caches via `XDG_CACHE_HOME=/tmp/.cache` |
| openbox config and cache | `/config/.config/openbox`, `/config/.cache/openbox` (done by the kasmvnc script) |
| nginx config and htpasswd | `/tmp/nginx-conf.d`, `/tmp/nginx` (done by kasmvnc) |
| Self-signed cert | `/config/ssl` (kasmvnc) |
| Libraries or scripts under `/app` | read-only; nothing is written there |

The draft expects root (UID 0, readOnlyRootFilesystem false). Reject that: run as `apps` (568) with a read-only rootfs, as `apps/kasmvnc` already does (it writes to `/tmp` and `/config` only). No privileged mode. The chart's extra `/shows` persistence becomes a plain user mount at `/media`. MediaElch needs write access to the media folders, so the mount must be writable by 568.

## 10. Risks, caveats and open questions

- The 70 MB AppImage is amd64 only, and arm64 needs a Qt6 build from source (long build, UNVERIFIED package names on Ubuntu 26.04). Consider using the source build for both arches to keep one code path and avoid the date-and-hash file name. Decide before implementing.
- The AppImage bundles its own Qt, so the `libqt6*` apt packages only matter for the source build.
- UNVERIFIED: the base image digest, the `/start.sh` location, and whether kasmvnc ships fonts and ffmpeg.
- Draft says VNC password must be set before first use: `PASSWORD` is the kasmvnc basic-auth switch. With it unset, the web desktop has no auth, so document it loudly.
- Scraping needs internet and some scrapers need API keys (entered in the UI, stored in `/config`).
- The upstream release is stale (2024). Renovate will mostly be quiet.
- Not a database app, so no test narrowing.

## 11. Build and test steps

```sh
cd apps/mediaelch
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create mediaelch-probe-config
docker run --rm -d --name mediaelch-probe --read-only --tmpfs /tmp -v mediaelch-probe-config:/config -p 3000:3000 mediaelch:2.12.0
docker logs -f mediaelch-probe     # expect Xvnc started, nginx started, kclient listening; no Qt "could not connect to display"
docker exec mediaelch-probe pgrep -a mediaelch
docker rm -f mediaelch-probe; docker volume rm mediaelch-probe-config
# second run with -e PASSWORD=test to check the auth path
forgetool containers test --image mediaelch:2.12.0 --config ./apps/mediaelch/container-test.yaml
```
Success signal: process `mediaelch` is running, port 3000 open, no repeated crashes. arm64 only if the amd64 failure is arch-specific.

## 12. PR checklist

- Branch `feat/add-mediaelch`, commit and PR title `feat(mediaelch): add new container`, target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`. Put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- List untested items honestly: arm64 source build, the `PASSWORD` path, real scraping, write access to a mounted media folder, the unverified base digest.
- Confirm `bake --print`, version alignment, the license file, `USER apps`, and an empty `/config` start.
