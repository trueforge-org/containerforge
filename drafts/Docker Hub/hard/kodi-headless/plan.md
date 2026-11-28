# kodi-headless — implementation plan
> Source: ./draft.md · Target: apps/kodi-headless/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | Kodi 21.3 "Omega" (latest xbmc/xbmc release, published 31 Oct). Draft image `linuxserver/kodi-headless` is deprecated and still ships Kodi 18.5 (Leia). |
| Renovate | `datasource=github-releases depName=xbmc/xbmc versioning=loose extractVersion=^(?<version>[0-9.]+)-Omega$` (tag is `21.3-Omega`). The image installs from apt, so `PACKAGE_VERSION` is pinned alongside (valkey pattern). |
| License | GPL-2.0-or-later for Kodi. UNVERIFIED: the release page did not state it; confirm in xbmc/xbmc LICENSE.md and the Ubuntu `copyright` file. |
| Source | https://github.com/xbmc/xbmc |
| Downloads | No binary download. apt on Ubuntu 26.04 (resolute): `kodi-eventclients-common` is `2:21.3+dfsg-1ubuntu1` (universe, verified). UNVERIFIED: exact versions of `kodi-bin`, `kodi-data`, `kodi`; read them with `apt-cache policy` in the base image. Both amd64 and arm64: UNVERIFIED (check packages.ubuntu.com build status). |
| Checksum | apt signature verification only. |
| Upstream Dockerfile | https://github.com/linuxserver/docker-kodi-headless (archived 2022-02-24, deprecated). Reviewed: compiles Kodi 18.5 with a `headless.patch`, GL/GLX/ALSA/PulseAudio disabled, `HOME=/config`, ports 8080, 9090, 9777/udp, volume `/config/.kodi`, env PUID/PGID/TZ, s6-overlay, default web login kodi/kodi. |

Key finding: the headless patch is not available in the stock apt Kodi. Stock Kodi needs a display, so the plan runs it under Xvfb. UNVERIFIED: whether Kodi 21 offers a native headless windowing mode; check `kodi --help` first.

## 2. Target layout
- `Dockerfile`
- `docker-bake.hcl`
- `settings.yaml`
- `container-test.yaml`
- `start.sh`: starts Xvfb, seeds config, execs Kodi.
- `defaults/userdata/guisettings.xml` and `defaults/userdata/advancedsettings.xml`: seeds web server on 8080, JSON-RPC/websocket, event server on 9777, and a null audio sink. Reason: Kodi has no env-based config. Copied only when missing.
- No `root/`. No `DOWNSTREAM_CHANGES.md` (not used as a FROM base).

## 3. Base image
`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`
Kodi comes from apt, so ubuntu alone is enough. Closest sibling: `apps/valkey` (pinned apt package with `PACKAGE_VERSION`).

## 4. Dockerfile
1. `ARG VERSION`, `ARG PACKAGE_VERSION`; `USER root`.
2. Version check, then install, as valkey does: `test "${PACKAGE_VERSION%%+*}" ...` adjusted for the epoch (`2:21.3+dfsg-...`); the check must prove the package is Kodi `${VERSION}`.
3. `apt-get install -y --no-install-recommends kodi-bin=${PACKAGE_VERSION} kodi-data=${PACKAGE_VERSION} xvfb libgl1-mesa-dri` (+ `kodi-eventclients-kodi-send` optional). Do not install pulseaudio; use a null audio sink. UNVERIFIED: whether `kodi-bin` alone pulls everything needed.
4. Optionally `kodi-addon-*` for vfs.rar/libarchive: UNVERIFIED package names.
5. Licenses: `mkdir -p /usr/share/licenses/kodi-headless && cp /usr/share/doc/kodi-bin/copyright ...`.
6. `ENV HOME=/config KODI_HOME=...` UNVERIFIED; `XDG_RUNTIME_DIR=/tmp/runtime`, `XDG_CACHE_HOME=/tmp/cache`, `DISPLAY=:99`.
7. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080 9090 9777/udp`, `VOLUME /config`, `CMD ["/start.sh"]`.

## 5. docker-bake.hcl
```hcl
variable "APP" { default = "kodi-headless" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=xbmc/xbmc versioning=loose extractVersion=^(?<version>[0-9.]+)-Omega$
  default = "21.3"
}
variable "PACKAGE_VERSION" { default = "<read from apt-cache policy kodi-bin on 26.04>" }
variable "LICENSE" { default = "GPL-2.0-or-later" }
variable "SOURCE" { default = "https://github.com/xbmc/xbmc" }
```
Plus `docker-metadata-action`, `image` (args VERSION and PACKAGE_VERSION, OCI labels), `image-local` (type=docker, tag `${APP}:${VERSION}`), `image-all` (amd64+arm64), `group "default"`. Validate with `docker buildx bake --print`.

## 6. settings.yaml
- Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/xbmc/xbmc"`.
- ports: 8080 tcp (web UI, JSON-RPC), 9090 tcp (websockets, upstream image), 9777 udp (event server); all `required: false`.
- env: `TZ` default `Etc/UTC`. Add `KODI_WEB_USERNAME` / `KODI_WEB_PASSWORD` only if start.sh applies them to the seeded config (ContainerForge-defined, not read by Kodi itself). Upstream PUID/PGID are not applicable (rootless).
- volumes: `/config` required (Kodi data in `/config/.kodi`).
- dependencies: none (optional MariaDB for a shared library, via `advancedsettings.xml`; `apps/mariadb` exists, verified).

## 7. start.sh
- `set -euo pipefail`; `mkdir -p /config/.kodi/userdata /tmp/runtime /tmp/cache`; `chmod 700 /tmp/runtime`.
- Seed `defaults/userdata/*.xml` into `/config/.kodi/userdata` only when missing (`cp -n`).
- If web credentials env is set, rewrite the credentials in the seeded file only on first seed, or apply via `sed` on each start without echoing secrets.
- `Xvfb :99 -screen 0 1280x720x24 -nolisten tcp &`; wait for `/tmp/.X11-unix/X99`. Never write to /app. UNVERIFIED: Xvfb can create `/tmp/.X11-unix` as a non-root user (it normally can if /tmp is writable).
- Bind web server on all interfaces (Kodi default for webserver once enabled). `exec kodi-standalone` or `exec kodi --standalone` (UNVERIFIED which works headless); trap to stop Xvfb.

## 8. container-test.yaml
Header: `# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json`
```yaml
timeoutSeconds: 120
tcp:
- port: '8080'
- port: '9090'
http:
- port: '8080'
  path: /
  statusCode: 401   # UNVERIFIED: no sibling uses `statusCode`; check the forgetool schema for the key name. Web UI auth default adjusts after run
filePaths:
- /usr/bin/kodi
- /defaults/userdata/guisettings.xml
healthCommands:
- command: sh -c 'grep -q ":2631" /proc/net/udp'   # 9777 = 0x2631; the schema has no udp probe
```
The schema has no `udp` key (verified), so 9777/udp is checked by a health command. Timeout 120 is an estimate; compare with `apps/jellyfin`.

## 9. Rootless and read-only-rootfs adaptations
- Upstream runs as root with PUID/PGID via s6; ours runs `USER apps`, no s6. Drop PUID/PGID.
- Writes: `/config/.kodi` (persistent), `/tmp/runtime`, `/tmp/cache`, `/tmp/.X11-unix` (ephemeral). Kodi writes `~/.kodi/temp` and `~/.kodi/userdata/Thumbnails`; both land in `/config`. Consider pointing temp to /tmp via `special://temp` in advancedsettings (`<pathsubstitution>`, UNVERIFIED).
- Draft expects root and writable rootfs; reconciled: rootless, read-only rootfs, `/config` is the only persistent path. No privileged mode and no ports below 1024.

## 10. Risks, caveats and open questions
- Blocker risk: stock Kodi may refuse to start without GL/EGL even under Xvfb (software Mesa should work, UNVERIFIED). Upstream used a custom patched build, which this plan avoids.
- Upstream image is archived/deprecated (2022). The plan follows Kodi itself, not that image.
- Default web credentials in upstream are kodi/kodi; seed a random or env-supplied password instead.
- Library updates need the DB/`sources.xml` kept in `/config`; losing it loses the library (upstream note).
- amd64 and arm64 availability of the Kodi packages is UNVERIFIED.
- Event server 9777/udp is not probed by a real UDP check.

## 11. Build and test steps
```sh
cd apps/kodi-headless
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create kodi-headless-probe-config
docker run --rm -d --name kodi-headless-probe --read-only --tmpfs /tmp \
  -v kodi-headless-probe-config:/config kodi-headless:21.3
docker logs -f kodi-headless-probe
forgetool containers test --image kodi-headless:21.3 --config ./apps/kodi-headless/container-test.yaml
docker rm -f kodi-headless-probe; docker volume rm kodi-headless-probe-config
```
Expected readiness: Kodi log line about starting the web server / JSON-RPC (UNVERIFIED wording) and port 8080 open; process still running.

## 12. PR checklist
- Branch `feat/add-kodi-headless`; commit `feat(kodi-headless): add new container`; PR title the same, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` check).
- Untested at planning time: build, run, container tests, arm64, headless operation, UDP 9777.
- Pre-completion: bake --print OK, USER apps, empty /config OK, versions aligned, no DOWNSTREAM_CHANGES.md needed.
