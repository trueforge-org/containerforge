# prusaslicer-novnc — implementation plan
> Source: ./draft.md · Target: apps/prusaslicer-novnc/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | PrusaSlicer latest GitHub release `version_2.9.7` (2026-11-02). Draft says apt `prusa-slicer` 2.9.4, which lags. UNVERIFIED: what 2.9.x version Ubuntu 26.04 ships. |
| Renovate | For the apt route: `datasource=repology depName=ubuntu_26_04/prusa-slicer versioning=loose` (UNVERIFIED that Repology tracks this). Fallback: `datasource=github-releases depName=prusa3d/PrusaSlicer extractVersion=^version_(?<version>.+)$` if a release tarball is used. |
| License | PrusaSlicer is AGPL-3.0 (UNVERIFIED: GitHub API not readable, rate limited). Use `AGPL-3.0-only` after reading the LICENSE file. |
| Source URL | https://github.com/prusa3d/PrusaSlicer |
| Download URLs | The 2.9.7 release lists only `PrusaSlicer-2.9.7-setup.exe`, `.dmg` and `.zip` (no Linux AppImage in the asset list). The wrapper `helfrichmichael/prusaslicer-novnc` fetches an AppImage via its own helper script, so Linux AppImages may exist elsewhere. UNVERIFIED. Plan uses apt. |
| Checksum source | apt (signed archive). For any AppImage route: UNVERIFIED. |
| Upstream wrapper Dockerfile | Reviewed `helfrichmichael/prusaslicer-novnc` master: base `nvidia/opengl:1.2-glvnd-runtime-ubuntu22.04`; xorg, novnc, lxde, supervisor, firefox-esr, VirtualGL, TurboVNC; AppImage extracted with `--appimage-extract`; user `slic3r`; volumes `/configs/` and `/prints/`; entrypoint `/entrypoint.sh`; supervisord.conf. No EXPOSE. |
| Wrapper env | `SSL_CERT_FILE` (example `/etc/ssl/certs/ca-certificates.crt`), `VNC_PASSWORD` (empty), `SUPD_LOGLEVEL` (INFO), `DISPLAY=:0`, `ENABLEHWGPU`, `VGL_DISPLAY=egl`, `NOVNC_PORT=8080`, `VNC_RESOLUTION=1280x800`, `VNC_PORT=5900`. |
| Wrapper ports | 8080 (noVNC web), 5900 (raw VNC, optional). |
| Reuse in repo | `apps/kasmvnc` (KasmVNC web desktop, ports 3000/3001, `PASSWORD`, `CUSTOM_USER`, `SUBFOLDER`, `/defaults/autostart`) and `apps/xvfb`, `apps/rdesktop` already exist. |

## 2. Target layout

```
apps/prusaslicer-novnc/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  defaults/autostart   # openbox autostart that launches prusa-slicer (overrides kasmvnc's seed file)
  defaults/menu.xml    # optional, only if a menu entry is wanted
```
No `start.sh` of our own: the kasmvnc base already owns `/start.sh`, and `COPY . /` would overwrite it. If a custom launcher is needed, put it under `scripts/` and call it from `defaults/autostart`. No `root/`. `apps/kasmvnc/DOWNSTREAM_CHANGES.md` is required (kasmvnc becomes a `FROM` base; file does not exist today): list this app, the exact need (stable `/defaults/autostart` contract), and the kasmvnc `VERSION` normalised to `x.y.z` (currently 1.5.2).

## 3. Base image

`FROM ghcr.io/trueforge-org/kasmvnc:<tag>@sha256:<digest>`. UNVERIFIED: published tag and digest; take them from the registry or the latest kasmvnc build when porting, never guess. Rationale: gives a rootless browser desktop with openbox on 3000/3001, replacing the upstream noVNC+supervisor+lxde stack. Fallback if kasmvnc is unsuitable as a base: ubuntu `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` plus xvfb and noVNC (large rework). Closest sibling: `apps/kasmvnc`, then `apps/rdesktop`.

## 4. Dockerfile

1. `FROM` kasmvnc (section 3), `ARG VERSION`, `ARG PACKAGE_VERSION`, `USER root`.
2. Pinned apt per `apps/valkey`: `test "${PACKAGE_VERSION%%-*}" = "${VERSION}" && apt-get update && apt-get install -y --no-install-recommends "prusa-slicer=${PACKAGE_VERSION}" libgl1-mesa-dri` (UNVERIFIED: package exists in 26.04 and its version; do not add `xvfb`/`libgl1-mesa-dri` if kasmvnc already provides them, check first).
3. Licence files: `mkdir -p /usr/share/licenses/prusaslicer-novnc && cp /usr/share/doc/prusa-slicer/copyright ...`.
4. Cleanup apt lists.
5. `ENV HOME=/config XDG_CONFIG_HOME=/config/.config XDG_CACHE_HOME=/tmp/.cache` (UNVERIFIED that kasmvnc does not already set these).
6. `USER apps`
7. `COPY --chmod=0755 . /` (puts `defaults/autostart` over the base file).
8. Keep base `EXPOSE 3000 3001` and `VOLUME /config`; add `VOLUME /prints` only if the mount is documented.
Do not re-add ports 8080/5900; they are not used.

## 5. docker-bake.hcl

```hcl
variable "VERSION" {
  // renovate: datasource=repology depName=ubuntu_26_04/prusa-slicer versioning=loose
  default = "2.9.4"   // UNVERIFIED; set to the real 26.04 package version
}
variable "PACKAGE_VERSION" { default = "<exact apt version from apt-cache policy>" }
variable "APP"     { default = "prusaslicer-novnc" }
variable "LICENSE" { default = "AGPL-3.0-only" }
variable "SOURCE"  { default = "https://github.com/prusa3d/PrusaSlicer/" }
```
`args` pass `VERSION` and `PACKAGE_VERSION`. Standard four targets plus default group, copied from `apps/valkey` (it passes a package version) and `apps/adguardhome-sync`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/prusa3d/PrusaSlicer/"
ports:
  - port: 3000
    protocol: tcp
    required: true
  - port: 3001
    protocol: tcp
    required: false
env: TZ (Etc/UTC), PASSWORD (""), CUSTOM_USER ("apps"), SUBFOLDER ("/"), CUSTOM_PORT ("3000"), CUSTOM_HTTPS_PORT ("3001")  # inherited from apps/kasmvnc settings.yaml, all required: false
volumes:
  - path: /config
    required: true
  - path: /prints
    required: false
dependencies:
  - kasmvnc   # ✅ apps/kasmvnc exists (build-time base, not a runtime sidecar)
```
Write `env` as proper entries. The upstream wrapper variables (`VNC_PASSWORD`, `NOVNC_PORT`, `ENABLEHWGPU`, `VGL_DISPLAY`) are NOT supported by the kasmvnc stack and are intentionally omitted.

## 7. start.sh

Not applicable: the kasmvnc base start script is reused. Behaviour is injected through `/defaults/autostart`, which kasmvnc's `/start.sh` copies to `/config/.config/openbox/autostart` only when missing (idempotent, verified in `apps/kasmvnc/start.sh`). Content: `prusa-slicer --datadir /config/.config/PrusaSlicer` (UNVERIFIED flag set; confirm `--datadir`), run as `exec`-free openbox autostart line with `&`, restarting is left to openbox/base. Create `/config/prints` via autostart (`mkdir -p`). Caches go to `/tmp`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '3000'
- port: '3001'
filePaths:
- /usr/bin/prusa-slicer
- /defaults/autostart
- /usr/share/licenses/prusaslicer-novnc
```
Timeout copied from sibling `apps/kasmvnc`'s style (check its value when porting). Ports 3000 and 3001 each have a probe.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
|---|---|
| user `slic3r`, `/home/slic3r`, `/configs`, `/prints` owned by it | `apps` user, `HOME=/config`; `/prints` becomes `/config/prints` or an optional mount |
| self-signed cert `/etc/novnc.pem` generated at build | handled by kasmvnc (HTTPS 3001); UNVERIFIED where it writes |
| supervisord, lxde, TurboVNC (root) | replaced by kasmvnc + openbox as `apps` |
| PrusaSlicer config `~/.config/PrusaSlicer` and cache | `/config/.config/PrusaSlicer`, cache `/tmp` |
| Mesa shader cache | `MESA_SHADER_CACHE_DIR=/tmp/mesa` (UNVERIFIED need) |

Draft expectations: UID 0, `readOnlyRootFilesystem: false`, `/configs` and `/prints` PVCs. Decision: non-root, read-only rootfs, `/config` plus optional `/prints`. Migration note: existing users with `/configs` must remount to `/config/.config/PrusaSlicer`.

## 10. Risks, caveats and open questions

- Depends on `ghcr.io/trueforge-org/kasmvnc` being published with a usable tag, and adds a DOWNSTREAM_CHANGES.md in `apps/kasmvnc` (out of this app's folder; call it out in the PR).
- apt `prusa-slicer` version lags upstream 2.9.7; Renovate tracking via Repology is UNVERIFIED.
- Software OpenGL (llvmpipe) is slow; no GPU path in this plan (upstream `ENABLEHWGPU`/VirtualGL dropped).
- Wrapper licence not stated; do not copy its scripts, rewrite.
- Port change from upstream (8080/5900 to 3000/3001) breaks existing chart values.
- UNVERIFIED count: 7.

## 11. Build and test steps

```sh
cd apps/prusaslicer-novnc
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create prusaslicer-novnc-probe-config
docker run --rm -d --name prusaslicer-novnc-probe --read-only --tmpfs /tmp \
  -v prusaslicer-novnc-probe-config:/config prusaslicer-novnc:<version>
docker logs -f prusaslicer-novnc-probe   # expect KasmVNC listening on 3000, openbox started, prusa-slicer process present
docker exec prusaslicer-novnc-probe pgrep -a prusa-slicer
docker rm -f prusaslicer-novnc-probe; docker volume rm prusaslicer-novnc-probe-config
forgetool containers test --image prusaslicer-novnc:<version> --config ./apps/prusaslicer-novnc/container-test.yaml
```
Open `http://localhost:3000` from the host and confirm the PrusaSlicer window renders; restart and confirm `/config` settings persist.

## 12. PR checklist

- Branch `feat/add-prusaslicer-novnc`; commit and PR title `feat(prusaslicer-novnc): add new container`; target `main`.
- Include `apps/kasmvnc/DOWNSTREAM_CHANGES.md` (or note it as a follow-up) per repo rule.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; put `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- State what was not tested: anything not actually run, in particular the build, arm64, a rendered GUI session and kasmvnc base compatibility.
