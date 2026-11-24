# tinymediamanager — implementation plan
> Source: ./draft.md · Target: apps/tinymediamanager/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | 5.3.5 (released 2026-10-30; matches draft tag 5.3.5, latest stable at verification) |
| Renovate | `datasource=gitlab-tags depName=tinyMediaManager/tinyMediaManager versioning=semver extractVersion=^tinyMediaManager-(?<version>.+)$` (tags look like `tinyMediaManager-5.3.5`) |
| License | Apache-2.0 (LICENSE file inside the tarball is the Apache License 2.0) |
| Source URL | https://gitlab.com/tinyMediaManager/tinyMediaManager |
| amd64 download | `https://archive.tinymediamanager.org/v5.3.5/tinyMediaManager-5.3.5-linux-amd64.tar.xz` |
| arm64 download | `https://archive.tinymediamanager.org/v5.3.5/tinyMediaManager-5.3.5-linux-arm64.tar.xz` |
| Checksum source | `<tarball>.sha256` next to each file (64 hex chars, no filename). amd64 = `5901310291318bbbf0768d79dc859b4e8bb3151806fb00231c5b8ddd81aac24e` (I downloaded the tarball and it matches), arm64 = `807a0183aae39bdc936af791b7c89ceee5576f0ffaefc709664c5174f3dcff37` |
| Tarball layout | top dir `tinyMediaManager/` with executable launcher `tinyMediaManager`, `tmm.jar`, `lib/`, `launcher.yml`, `LICENSE`, `.userdir`, and a bundled JRE in `jre/` (so no java base is needed) |
| Upstream Dockerfile reviewed | `src/docker/Dockerfile.amd64` at a2204fc: base `tinymediamanager/base-amd64:<date>` (a jlesage-style GUI base), env `APP=tinyMediaManager`, `ALLOW_DIRECT_VNC=true`, installs libzen0v5 + libmediainfo0v5 debs from mediaarea.net, app in `/app`, CMD sets `-Dtmm.contentfolder=/data` |
| Upstream docker docs | https://www.tinymediamanager.org/docs/docker : ports 4000 (noVNC web) and 5900 (VNC), env `USER_ID`, `GROUP_ID`, `PASSWORD`, `ALLOW_DIRECT_VNC`, `LC_TIME`, `TZ`, `LC_ALL`, `LANG`; volumes `/data`, `/media/*`; `/app/launcher-extra.yml` for custom start parameters |
| Data dir flags | `-Dtmm.contentfolder=` (all data), or `-Dtmm.datafolder/cachefolder/logfolder/backupfolder`; settable in `extra.txt` in the tmm folder or in the start script (from the install docs) |

Corrections to the draft: ports 5800/5900 are guesses and do not match upstream (4000/5900). Our GUI base (kasmvnc app) exposes 3000/3001, so the ContainerForge ports will be 3000 and 3001. Upstream user/group handling (`USER_ID`/`GROUP_ID`) belongs to the jlesage GUI base and does not apply.

## 2. Target layout

```
apps/tinymediamanager/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh            # thin wrapper: prepares /config, then execs the kasmvnc start script
  defaults/autostart  # openbox autostart that launches tinyMediaManager (overrides kasmvnc's default)
  defaults/extra.txt  # not needed if baked in Dockerfile; omit unless build step prefers COPY
```
- `defaults/autostart` is needed because kasmvnc seeds `/config/.config/openbox/autostart` from `/defaults/autostart` when missing.
- No `root/` directory (reserved). `DOWNSTREAM_CHANGES.md` is not needed for this app (nothing builds FROM it). Consuming `kasmvnc` as a FROM base means `apps/kasmvnc/DOWNSTREAM_CHANGES.md` should be checked and extended by the implementer, because kasmvnc's own `COPY . /` brings its start.sh and defaults; see risks.

## 3. Base image

- `FROM ghcr.io/trueforge-org/kasmvnc:1.5.2@sha256:<UNVERIFIED: digest not published to me; ghcr tag list needs auth, take it from the kasmvnc release workflow or the current kasmvnc bake VERSION (1.5.2)>`.
- Why: the app is a Java Swing GUI, so it needs an X server and a web display. `apps/kasmvnc` already provides Xvnc, openbox, nginx and a kclient web UI as user `apps`, with ports 3000/3001 and read-only-rootfs fixes (nginx config to /tmp). The draft's alternative (ubuntu + xvfb) would need us to also build a web VNC layer.
- Closest siblings: `apps/kasmvnc` (base), `apps/hytale` (java FROM line pattern), `apps/adguardhome-sync` (prebuilt download pattern).
- Java: not needed from a java base; the tarball ships a JRE in `jre/`. A `java17` base would not be used.

## 4. Dockerfile

Steps:
1. `FROM` line from section 3, then `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. apt install only what the base lacks. `ffmpeg` is already in kasmvnc. Add `libmediainfo0v5` (and `libzen0v5` pulled as dependency) from Ubuntu instead of the mediaarea debs (package names for 26.04: UNVERIFIED, confirm with `apt-cache policy libmediainfo0v5`). Pin versions only if the implementer chooses apt for the app itself; these are libraries, so no pin is needed.
3. Download and verify:
```dockerfile
RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64) SHA=5901310291318bbbf0768d79dc859b4e8bb3151806fb00231c5b8ddd81aac24e ;; \
      arm64) SHA=807a0183aae39bdc936af791b7c89ceee5576f0ffaefc709664c5174f3dcff37 ;; \
      *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/tmm.tar.xz "https://archive.tinymediamanager.org/v${VERSION}/tinyMediaManager-${VERSION}-linux-${TARGETARCH}.tar.xz"; \
    echo "${SHA}  /tmp/tmm.tar.xz" | sha256sum -c -; \
    mkdir -p /app /usr/share/licenses/tinymediamanager; \
    tar -xJf /tmp/tmm.tar.xz -C /app; \
    cp /app/tinyMediaManager/LICENSE /usr/share/licenses/tinymediamanager/LICENSE; \
    rm -f /app/tinyMediaManager/.userdir; \
    printf '%s\n' '-Dtmm.contentfolder=/config/data' '-Dtmm.noupdate=true' > /app/tinyMediaManager/extra.txt; \
    chown -R root:root /app/tinyMediaManager && chmod -R a+rX /app/tinyMediaManager; \
    rm -f /tmp/tmm.tar.xz
```
(Better: read the sha256 from the upstream `.sha256` file at build time and compare; hard-coded values above go stale on every renovate bump, so implement it as `curl ...sha256` and `echo "$(cat file)  tmm.tar.xz" | sha256sum -c -`.) Whether `extra.txt` takes one option per line and whether `.userdir` removal is needed is UNVERIFIED (docs only say "extra.txt in the tinyMediaManager folder" and `.userdir` text says "REMOVE THIS IF YOU WANT A PORTABLE VERSION"); verify in the run step.
4. `ENV HOME=/config` is already set by the kasmvnc base; keep `TZ` default via the base. Add `ENV TMM_HOME=/app/tinyMediaManager`.
5. `USER apps`, then `COPY --chmod=0755 . /` (this lands `defaults/autostart` in `/defaults/`, overriding kasmvnc's default, and `start.sh`).
6. `EXPOSE 3000 3001`, `VOLUME /config`, `WORKDIR /config`.
The final line before `CMD`/end must leave `USER apps` as the last `USER` directive.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" { default = "tinymediamanager" }

variable "VERSION" {
  // renovate: datasource=gitlab-tags depName=tinyMediaManager/tinyMediaManager versioning=semver extractVersion=^tinyMediaManager-(?<version>.+)$
  default = "5.3.5"
}

variable "LICENSE" { default = "Apache-2.0" }
variable "SOURCE" { default = "https://gitlab.com/tinyMediaManager/tinyMediaManager" }
```
Plus the four standard targets (`docker-metadata-action`, `image` with `args.VERSION` and OCI labels, `image-local` with `output=["type=docker"]` and tag `${APP}:${VERSION}`, `image-all` for linux/amd64 + linux/arm64) and `group "default" { targets = ["image-local"] }`, copied from `apps/adguardhome-sync/docker-bake.hcl`. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://gitlab.com/tinyMediaManager/tinyMediaManager"
ports:
  - {port: 3000, protocol: tcp, required: false}   # kasmvnc web UI (http)
  - {port: 3001, protocol: tcp, required: false}   # kasmvnc web UI (https, self-signed)
env:
  - {name: TZ, default: "Etc/UTC", required: false}
  - {name: PASSWORD, default: "", required: false}       # read by kasmvnc start.sh (basic auth)
  - {name: CUSTOM_USER, default: "apps", required: false}  # read by kasmvnc start.sh
volumes:
  - path: /config
    required: true
```
(Write in the multi-line style of the siblings.) Env names are those the kasmvnc `start.sh` reads (`PASSWORD`, `CUSTOM_USER`, `CUSTOM_PORT`, `CUSTOM_HTTPS_PORT`, `SUBFOLDER`); upstream tmm's `USER_ID`, `GROUP_ID`, `ALLOW_DIRECT_VNC` are not read here, so they are not listed. Media mounts (`/media/movies`, `/media/tvshows`) are user-chosen paths: list one optional `volumes` entry `/media` with `required: false`. Dependencies: none.

## 7. start.sh

Goal: prepare `/config` and hand off to the base start script.
- `mkdir -p /config/data` (tmm data, only when missing).
- Seeding of `/config/.config/openbox/autostart` is done by the base script from `/defaults/autostart`; our `defaults/autostart` contains one line: `/app/tinyMediaManager/tinyMediaManager &` followed by nothing else (tmm is the visible window; openbox maximizes it).
- Do not write to `/app`. The JRE, `lib/` and `launcher.yml` stay read-only; data goes to `/config/data` through `extra.txt` (build-time); caches: `-Dtmm.cachefolder=/tmp/tmm-cache` can be appended to `extra.txt` if the cache is large (UNVERIFIED that the folders can be split).
- Idempotent; no passwords stored in files; `PASSWORD` is handled by the base nginx htpasswd in /tmp.
- Final line: `exec /start.sh.kasmvnc-orig` is NOT possible, since `COPY . /` would overwrite `/start.sh`. Resolution: do not ship our own `start.sh`; rely on the base `/start.sh` and only ship `defaults/autostart`. If a wrapper is required, install it under a different name (for example `/scripts/tmm-prepare.sh` called from `autostart`), because the allow-list copies `scripts/`. So the final layout drops `start.sh` and adds `scripts/tmm-prepare.sh` (mkdir `/config/data`); `autostart` runs `/scripts/tmm-prepare.sh; exec /app/tinyMediaManager/tinyMediaManager`. The container's PID 1 handoff stays with the base `node index.js`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '3000'
- port: '3001'
filePaths:
- /app/tinyMediaManager/tinyMediaManager
- /app/tinyMediaManager/tmm.jar
- /usr/share/licenses/tinymediamanager/LICENSE
- /defaults/autostart
```
Timeout copied from the nginx/kasmvnc-family style (180). The test runs without env vars, so `PASSWORD` code paths are not covered; run them by hand (step 11). No DB dependency, so no narrowing.

## 9. Rootless and read-only-rootfs adaptations

- Draft expected UID 0, `readOnlyRootFilesystem: false`; we run as `apps` (568), read-only rootfs compatible.
- Upstream writes: `/data` (settings, DB, logs, cache, backups) -> remapped to `/config/data` via `-Dtmm.contentfolder`. `/app/addons` (custom scrapers) -> `/config/data/addons` (documented as `CONTENT_DIR/addons/*` in `launcher.yml` classpath, so it follows the content folder). Auto-update -> disabled with `-Dtmm.noupdate=true`. `/app/launcher-extra.yml` not used.
- GUI side (inherited from kasmvnc): nginx pid/logs/config in /tmp, `XDG_RUNTIME_DIR=/config/.XDG`, pulse in /tmp. Java temp: set `-Djava.io.tmpdir=/tmp` (default already /tmp).
- Media: draft's `/media/movies` and `/media/tvshows` PVCs become user mounts; tmm needs write access there to write NFO/artwork; ownership must be UID/GID 568 on the host.
- Extra persistence `/data` in the draft is replaced by `/config`.

## 10. Risks, caveats and open questions

- Dependency on `ghcr.io/trueforge-org/kasmvnc`: tag/digest UNVERIFIED; kasmvnc's own start.sh is large, ships a docker-in-docker stack and uses `sudo`/wheel; kasmvnc is not currently a FROM base for any app, so its README/DOWNSTREAM notes may need an entry.
- `/config/.config/openbox/autostart` seeded only when missing: existing users upgrading would keep an old file.
- kasmvnc image size and attack surface are large for a single GUI app; alternative is ubuntu + `xvfb` app + a noVNC layer (more work).
- tmm first start downloads artwork/metadata (needs outbound internet); large libraries are slow (draft caveat).
- `.userdir` removal, `extra.txt` format and `-Dtmm.noupdate` honoring are UNVERIFIED; the JRE version in the tarball is unknown (has `jwebserver`, so JDK 18+), only matters for arm64 (upstream docs say ARM ships no Java; the 5.3.5 arm64 listing is a 130M tarball, so a JRE is likely bundled: UNVERIFIED).
- No auth by default: `PASSWORD` unset means the web UI is open; document in README/PR.
- 3001 uses a self-signed cert generated into `/config/ssl`.
- UNVERIFIED count for this plan: 6.

## 11. Build and test steps

```sh
cd apps/tinymediamanager
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create tinymediamanager-probe-config
docker run --rm -d --name tinymediamanager-probe --read-only --tmpfs /tmp \
  -v tinymediamanager-probe-config:/config tinymediamanager:5.3.5
docker logs -f tinymediamanager-probe
```
Success signals: nginx up, Xvnc "Listening" on 6901 (kasmvnc), and a `tinyMediaManager` java process (`docker exec ... pgrep -f tmm.jar`); `curl -sk https://localhost:3001/` returns HTML from outside the container; `/config/data` is created. Also run once with `-e PASSWORD=test` and check HTTP 401 without credentials. Then:
```sh
forgetool containers test --image tinymediamanager:5.3.5 --config ./apps/tinymediamanager/container-test.yaml
docker rm -f tinymediamanager-probe; docker volume rm tinymediamanager-probe-config
```

## 12. PR checklist

- Branch `feat/add-tinymediamanager`; commit and PR title `feat(tinymediamanager): add new container`; target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`, check only boxes that apply. Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- Pre-completion: bake `--print` ok; Dockerfile `ARG VERSION` equals bake `VERSION` (5.3.5); final `USER apps`; `COPY --chmod=0755 . /` present; license in `/usr/share/licenses/tinymediamanager/`.
- State honestly what is untested until run: kasmvnc base digest, arm64 build, `extra.txt` handling, PASSWORD path, library scraping with real media, libmediainfo package names.
