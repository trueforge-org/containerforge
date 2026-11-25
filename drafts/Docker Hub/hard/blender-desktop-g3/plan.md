# blender-desktop-g3 — implementation plan
> Source: ./draft.md · Target: apps/blender-desktop-g3/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts
| Item | Value |
|---|---|
| Version | draft says 5.0.1; download.blender.org now lists Blender5.1, 5.2 and 5.3 directories (5.3 contains `blender-5.3.0-linux-x64.tar.xz`). Plan pins the newest stable found, 5.3.0; confirm it is not a pre-release and that no 5.3.x exists before implementing. 5.0.1 is a fallback. |
| Renovate | UNVERIFIED: no clean datasource for download.blender.org. Use `datasource=github-tags depName=blender/blender versioning=loose extractVersion=^v(?<version>.+)$` (the GitHub mirror tags `vX.Y.Z`; confirm it mirrors tags) |
| License | GPL-3.0-or-later (Blender 4.x and later; UNVERIFIED this session, confirm in the tarball's copyright.txt) |
| Source | https://github.com/blender/blender |
| amd64 | https://download.blender.org/release/Blender5.3/blender-5.3.0-linux-x64.tar.xz |
| arm64 | no official linux arm64 tarball seen in the release listing (only linux-x64); draft says `apt:blender`. apt version on Ubuntu 26.04 is UNVERIFIED and will differ from the tarball version |
| Checksum | https://download.blender.org/release/Blender5.3/blender-5.3.0.sha256 |
| Upstream Dockerfile reviewed | accetto/headless-drawing-g3 Dockerfile.xfce.drawing: Ubuntu 24.04, apt blender, xfce, TigerVNC, noVNC; VNC_PORT 5901, NOVNC_PORT 6901, user headless UID 1001, HOME /home/headless, VNC_PW default "headless", VNC_RESOLUTION 1360x768, VNC_COL_DEPTH 24, DISPLAY :1, tini entrypoint |
| Ports | 6901 noVNC web, 5901 VNC (upstream defaults). If kasmvnc base is used: 3000/3001 |

## 2. Target layout
Dockerfile, docker-bake.hcl, settings.yaml, container-test.yaml, start.sh, defaults/ (openbox autostart that launches blender; blender user prefs optional). Prefer building on the kasmvnc image (draft Reason: "kasmvnc or xvfb siblings"); it needs DOWNSTREAM_CHANGES.md only for kasmvnc if it must change (it should not).

## 3. Base image
Preferred: `FROM ghcr.io/trueforge-org/kasmvnc:<version>@sha256:<digest>` (copy exact tag and digest from the published image; UNVERIFIED which tag is published). Fallback: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` with apt `xvfb x11vnc novnc websockify openbox`. Closest siblings: apps/kasmvnc, apps/xvfb.

## 4. Dockerfile
1. `ARG VERSION`, `ARG TARGETARCH`; `USER root`.
2. Runtime libs Blender needs from apt (not in base; check): `libxi6 libxxf86vm1 libxfixes3 libxrender1 libgl1 libegl1 libsm6 libxkbcommon0 libsdl2-2.0-0` (typical set, UNVERIFIED; verify with `ldd`). Add `mesa-utils libgl1-mesa-dri` for software GL.
3. amd64 branch: `curl` tarball + sha256 file, `grep linux-x64.tar.xz blender-${VERSION}.sha256 | sha256sum -c -`, extract to /app/blender (`tar xJf --strip-components=1`), symlink /usr/local/bin/blender. arm64 branch: `apt-get install -y --no-install-recommends blender` with the apt version pinned (`blender=<ver>`) and checked; the image tag cannot honestly equal VERSION on arm64, so either document this or build arm64 from source (not planned).
4. License: copy copyright.txt and GPL text to /usr/share/licenses/blender-desktop-g3/.
5. `ENV HOME=/config`, `XDG_CACHE_HOME=/tmp/.cache`, `BLENDER_USER_RESOURCES=/config/blender` (BLENDER_USER_RESOURCES is a real Blender env var; confirm in docs when implementing).
6. `USER apps`, `COPY --chmod=0755 . /`, EXPOSE web port, `VOLUME /config`.

## 5. docker-bake.hcl
APP=blender-desktop-g3, VERSION "5.3.0" (see section 1 for the renovate comment), LICENSE "GPL-3.0-or-later", SOURCE "https://github.com/blender/blender"; standard 4 targets + default; image-all amd64+arm64. `docker buildx bake --print`.

## 6. settings.yaml
Header, schema_version 1, upstream_env_url = SOURCE. ports: web desktop port (6901 or 3000/3001 per base) required false; raw VNC 5901 only if the fallback stack exposes it. env: TZ; resolution/password vars only with names the chosen stack really reads (kasmvnc: PASSWORD, CUSTOM_USER from apps/kasmvnc/settings.yaml; accetto-style VNC_PW / VNC_RESOLUTION only in the fallback stack). volumes: /config required true; optional /projects (draft chart mounts /srv/projects and /UNRAID_SHARE; map to /config/projects, drop the unRAID share, user can mount any path). dependencies: kasmvnc ✅ (if used as base).

## 7. start.sh
Seed /config/.config/openbox/autostart from /defaults only if missing (launch `blender`), create /config/projects, set `XDG_RUNTIME_DIR` under /tmp, then `exec` the desktop stack entrypoint (kasmvnc's start or `Xvfb :1 & x11vnc & websockify`). Listen on all interfaces. No writes to /app.

## 8. container-test.yaml
Header; `timeoutSeconds: 120` (apps/kasmvnc/container-test.yaml sets none; 120 is a common value in sibling apps); `tcp` probe for each declared port; `filePaths`: /app/blender/blender (amd64) or /usr/bin/blender (arm64 variant, keep both with a conditional-free check by always symlinking /usr/local/bin/blender); `runners: - entrypoint: blender --version` (Blender runs headless for --version).

## 9. Rootless and read-only-rootfs adaptations
| Upstream write path | Remap |
|---|---|
| /home/headless (HOME, .config/blender, .vnc) | HOME=/config |
| /srv/projects, /UNRAID_SHARE | /config/projects (volume) |
| Blender user resources / cache | /config/blender (persistent prefs) and cache in /tmp |
| /tmp/.X11-unix, VNC sockets | /tmp |
| headless sudo user, UID 1001 | apps user, no sudo |
Draft expects UID 0 and rw rootfs: not needed. No GPU in values, so software rendering only; GPU passthrough is out of scope.

## 10. Risks, caveats and open questions
- arm64 uses a different Blender build than amd64 (draft caveat confirmed: only linux-x64 is published at download.blender.org in the listing checked).
- Version drift: chart 5.0.1 vs available 5.3.0; pick before implementing.
- Software rendering is slow; Blender 5.x needs OpenGL 4.3, which Mesa llvmpipe may or may not satisfy under VNC (UNVERIFIED, test on first run).
- Large image (tarball ~370 MB compressed).
- Upstream accetto image has no public checksum equivalent; using blender.org .sha256 only.
- Open question: kasmvnc base vs light fallback.

## 11. Build and test steps
```sh
cd apps/blender-desktop-g3
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name blender-desktop-g3-probe --read-only --tmpfs /tmp -v blender-desktop-g3-probe-config:/config blender-desktop-g3:5.3.0
docker logs -f blender-desktop-g3-probe   # expect the VNC/web desktop "listening" line and Blender not crashing in autostart
docker rm -f blender-desktop-g3-probe; docker volume rm blender-desktop-g3-probe-config
forgetool containers test --image blender-desktop-g3:5.3.0 --config ./apps/blender-desktop-g3/container-test.yaml
```
Then try `--platform linux/arm64` separately only if the arm64 apt path is kept.

## 12. PR checklist
- Branch feat/add-blender-desktop-g3; commit `feat(blender-desktop-g3): add new container`; PR template; `🤖 This PR is AI generated.` in Notes.
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (user signs).
- Untested: build, arm64 apt path, OpenGL under software rendering, VNC auth, renovate comment resolution.
