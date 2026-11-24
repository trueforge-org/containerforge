# fmd2-wine — implementation plan
> Source: ./draft.md · Target: apps/fmd2-wine/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | 2.0.34.5 (GitHub "Latest", published 17 Mar; same as draft). Upstream docker image Dockerfile still defaults to 2.0.32.0. |
| Renovate | `datasource=github-releases depName=dazedcat19/FMD2 versioning=loose` (four-part version, not semver) |
| License | GPL-2.0 per README ("released under the GPLv2 license"); SPDX `GPL-2.0-only` (UNVERIFIED whether "or later") |
| Source URL | https://github.com/dazedcat19/FMD2 (Object Pascal/Lazarus app with Lua modules; Windows build run under Wine) |
| Download | amd64 only: `https://github.com/dazedcat19/FMD2/releases/download/${VERSION}/fmd_${VERSION}_x86_64-win64.7z` (from the draft; the asset list did not load on the releases page, UNVERIFIED by name). The release has 4 assets. |
| arm64 | No (Windows x86_64 binary). |
| Checksum | UNVERIFIED: no checksum file seen. If the release publishes digests, use them; otherwise record the sha256 of the archive in a build ARG and verify it. |
| Upstream Dockerfile reviewed | https://github.com/Banh-Canh/docker-FMD2/blob/master/Dockerfile: base `ghcr.io/linuxserver/baseimage-kasmvnc:ubuntunoble`; `ENV WINEDLLOVERRIDES="mscoree,mshtml=" HOME=/config`; `dpkg --add-architecture i386`; apt `wine64=9.0~repack-4build3 wget p7zip-full curl git python3-pyxdg inotify-tools rsync`; extracts the 7z into `/app/FMD2`; creates `/downloads`, `/app/FMD2/userdata`, `/app/FMD2/downloads`; `VOLUME /config`; `EXPOSE 3000` |
| Ports | 3000 (KasmVNC web HTTP) and 3001 (HTTPS) from the repo's `apps/kasmvnc`. The draft's 5800/5900 are wrong for this stack. |

## 2. Target layout

```
apps/fmd2-wine/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  defaults/autostart     # replaces kasmvnc's /defaults/autostart so openbox launches FMD2 under wine
  defaults/fmd2.sh       # wrapper: prefix seeding + `exec wine /app/FMD2/fmd.exe`
```
No `start.sh`: it would overwrite the kasmvnc base's `/start.sh` through `COPY --chmod=0755 . /`, which breaks the desktop. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/kasmvnc:1.5.2@sha256:<UNVERIFIED: read the published digest from ghcr.io when implementing>`

Tag `1.5.2` is the `VERSION` in `apps/kasmvnc/docker-bake.hcl`. Why: the draft's reason is "Wine on the KasmVNC base", and ContainerForge already has it (the draft says ubuntu; this reuses the existing sibling). Closest siblings: `apps/kasmvnc`, `apps/kasm`. The base ends in `USER apps`, so switch to root only to install.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH` (assert `amd64` and fail otherwise: `[ "$TARGETARCH" = amd64 ] || exit 1`).
2. `USER root`.
3. `dpkg --add-architecture i386`; `apt-get install -y --no-install-recommends wine64 wine32:i386 p7zip-full winbind cabextract` (wine is not in the kasmvnc base; Wine version 9 pinned upstream as `wine64=9.0~repack-4build3` on noble; for Ubuntu 26.04 UNVERIFIED, check `apt-cache policy wine64` and pin). `curl` already exists. Purge `p7zip-full` not needed after extraction only if unused at runtime.
4. Download `fmd_${VERSION}_x86_64-win64.7z` to `/tmp`, verify sha256, `7z x -o/app/FMD2`.
5. Writable dirs: replace `/app/FMD2/userdata`, `/app/FMD2/lua`, `/app/FMD2/data` (draft persistence list) by symlinks into `/config/FMD2/...`; seed from copies saved to `/usr/share/fmd2-defaults/`. `/downloads` becomes the mount point; `mkdir -p /downloads` owned by `apps`.
6. Licenses: copy the archive's license/README files to `/usr/share/licenses/fmd2-wine/`.
7. `ENV HOME=/config WINEPREFIX=/config/.wine WINEARCH=win64 WINEDLLOVERRIDES="mscoree,mshtml=" WINEDEBUG=-all`.
8. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 3000 3001`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

- `APP` `fmd2-wine`; `VERSION` with `// renovate: datasource=github-releases depName=dazedcat19/FMD2 versioning=loose`, default `2.0.34.5`.
- `LICENSE` `GPL-2.0-only`; `SOURCE` `https://github.com/dazedcat19/FMD2`.
- Targets: `docker-metadata-action`, `image`, `image-local`, `group "default"`, and `image-all` restricted to `linux/amd64` only (there is no arm64; do not list arm64, otherwise CI fails). `docker buildx bake --print`.

## 6. settings.yaml

- Header, `schema_version: 1`, `upstream_env_url: "https://github.com/dazedcat19/FMD2"`.
- ports: `3000/tcp`, `3001/tcp` (required false).
- env: those of `apps/kasmvnc/settings.yaml` that remain valid: `TZ` (`Etc/UTC`), `CUSTOM_USER` (`apps`), `PASSWORD` (`""`), `SUBFOLDER` (`/`), `CUSTOM_PORT` (`3000`), `CUSTOM_HTTPS_PORT` (`3001`). No FMD2-specific env.
- volumes: `/config` (required true, holds Wine prefix and FMD2 data), `/downloads` (required false).
- dependencies: none (kasmvnc is the base, not a runtime peer; list under a comment only).

## 7. start.sh

Not applicable: the kasmvnc base provides `/start.sh` and copies `/defaults/autostart` into `/config/.config/openbox/autostart` only when missing. The plan ships `defaults/autostart` (content: `/defaults/fmd2.sh &`). `defaults/fmd2.sh`: `mkdir -p /config/FMD2/{userdata,lua,data} /downloads`; seed from `/usr/share/fmd2-defaults` with `cp -n`; if `/config/.wine` missing run `wineboot --init` (slow first start); `exec wine /app/FMD2/fmd.exe` (binary name UNVERIFIED). Note existing users keep an old autostart (kasmvnc only seeds when missing).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120   # kasmvnc siblings: check apps/kasmvnc and raise if wineboot is slow
tcp:
- port: '3000'
- port: '3001'
```
Add `filePaths` for `/app/FMD2` and `/defaults/autostart` if the schema supports it (copy the key from a sibling).

## 9. Rootless and read-only-rootfs adaptations

- Draft: root, writable rootfs, persistence `/app/FMD2/lua|userdata|data`, `/downloads`. Target: `USER apps` (kasmvnc base), `/app` read-only, those three paths symlinked to `/config/FMD2/*`, `/downloads` volume, Wine prefix `/config/.wine`, Wine caches (`XDG_CACHE_HOME`) `/tmp`.
- Wine needs `/tmp/.wine-<uid>` and X11 socket in `/tmp` (kasmvnc already uses it).
- The kasmvnc base uses `sudo`/wheel; not relied upon here.

## 10. Risks, caveats and open questions

- amd64 only; draft says arm64 impractical, confirmed.
- First start builds the Wine prefix (minutes); readiness takes longer than other apps.
- `wine32` on 26.04 and the pinned versions are UNVERIFIED.
- FMD2 may write beside the exe (`lua`, `data`, `userdata` per draft); verify with `strace` or a `--read-only` run.
- Downstream: kasmvnc digest/version must be refreshed when kasmvnc updates.
- Per-site scraping scripts pull content from third parties; no technical blocker.

## 11. Build and test steps

```sh
cd apps/fmd2-wine
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create fmd2-wine-probe-config
docker run --rm -d --name fmd2-wine-probe --read-only --tmpfs /tmp -v fmd2-wine-probe-config:/config fmd2-wine:2.0.34.5
docker logs -f fmd2-wine-probe     # expect KasmVNC listening on 3000; then wineboot done, fmd.exe running
forgetool containers test --image fmd2-wine:2.0.34.5 --config ./apps/fmd2-wine/container-test.yaml
docker rm -f fmd2-wine-probe; docker volume rm fmd2-wine-probe-config
```
Do NOT build arm64.

## 12. PR checklist

- Branch `feat/add-fmd2-wine`, commit `feat(fmd2-wine): add new container`.
- PR template filled; Notes contain `🤖 This PR is AI generated.`
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested: image build, Wine prefix init, FMD2 launch, read-only run, 7z asset name and checksum.
