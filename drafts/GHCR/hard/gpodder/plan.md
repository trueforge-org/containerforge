# gpodder — implementation plan
> Source: ./draft.md · Target: apps/gpodder/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | gPodder `3.11.5` (tag `3.11.5`, highest numeric tag in https://github.com/gpodder/gpodder). Release date: UNVERIFIED (GitHub API rate-limited on 2026-11-25). |
| Chart image (draft) | `ghcr.io/xthursdayx/gpodder-docker:latest@sha256:76cb41a1cca8de985f42d43a4b98f7a0a9129e415399b445cf787bd375e04d61` (digest matches GHCR `latest`, 2026-11-25). Third-party image, Alpine/selkies; not reused. |
| Upstream image Dockerfile | https://raw.githubusercontent.com/xthursdayx/gpodder-docker/2c723a12db40b1ab9ab2cde0b6b298932c245321/Dockerfile. Base `ghcr.io/linuxserver/baseimage-selkies:alpine324` (Alpine, musl, s6-overlay, runs as root). Build stage: `make install PYTHON=/usr/bin/python3 PREFIX=/usr DESTDIR=/out` from the upstream tarball `https://github.com/gpodder/gpodder/archive/refs/tags/3.11.5.tar.gz`. Runtime: apk packages (ffmpeg, webkit2gtk-4.1, py3-gobject3, yt-dlp, …). `ENV GPODDER_HOME=/config GPODDER_DOWNLOAD_DIR=/downloads GPODDER_THEME=light TITLE=gPodder LANG=en_US.UTF-8`. `EXPOSE 3000 3001`. `VOLUME ["/config", "/downloads"]`. |
| Renovate | App version: `datasource=github-tags depName=gpodder/gpodder versioning=semver`. |
| License | GPL-3.0. Source: https://raw.githubusercontent.com/gpodder/gpodder/3.11.5/COPYING (GNU GPL v3). |
| Source URL | https://github.com/gpodder/gpodder (docs https://gpodder.github.io/docs/). |
| Download | Source tarball `https://github.com/gpodder/gpodder/archive/refs/tags/${VERSION}.tar.gz`. |
| Checksum source | No upstream checksum file found. The fetched tarball hashed locally to `c09de56290589f5d66592d79acdfb8b70e76deab6df590715e4556c6d2d2068c` on 2026-11-25; this is a local hash, not an upstream-published one (UNVERIFIED as upstream). |
| Packaging for apt | `apt:gpodder` exists in Ubuntu (packages.ubuntu.com search lists jammy, noble, resolute). The listed source version is `3.11.3-2ubuntu2`, older than upstream `3.11.5`. Series-specific binary version: UNVERIFIED. |
| Python version / setup | `setup.py` at 3.11.5 is a pure-Python distutils/setuptools project (https://raw.githubusercontent.com/gpodder/gpodder/3.11.5/setup.py). Minimum Python version: UNVERIFIED. |
| Ports | Upstream `EXPOSE 3000 3001` (selkies web UI, from the linuxserver base). Chart service `main` 3000/tcp. Whether gPodder itself opens a port: no (it is a desktop client, no HTTP server in the image's runtime path, inferred). |
| Chart security (draft/values.yaml) | `readOnlyRootFilesystem: false`, `runAsUser: 0`, `runAsGroup: 0`, `privileged` not set. Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/gpodder/values.yaml |
| Chart persistence | `config` -> `/config`, `downloadspath` -> `/downloads`. |
| Dependencies | None (no database). Runtime needs a GTK/WebKit desktop stack for the GUI. |

## 2. Target layout

The upstream product is a GUI desktop session. The port cannot copy the selkies image. The plan targets the gPodder Python core only if the user accepts a non-GUI container (see section 10). If the user wants the web desktop, stop and ask: there is no ContainerForge selkies base (`grep -l selkies apps/*/Dockerfile` finds nothing relevant), so this is out of scope for the standard layout.

Layout if the non-GUI option is chosen:

- `apps/gpodder/Dockerfile`
- `apps/gpodder/docker-bake.hcl`
- `apps/gpodder/settings.yaml`
- `apps/gpodder/container-test.yaml`
- `apps/gpodder/start.sh`

No `defaults/`, `etc/`, `root/`. `DOWNSTREAM_CHANGES.md` not needed.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` (runtime) for the non-GUI option, using the ContainerForge Python rules. Alternative: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` with `apt-get install gpodder` if the distro package is acceptable (version lags upstream).

The draft's Base container section (ubuntu + python) is consistent with this. Python version compatibility of gPodder 3.11.5 with the 3.15 base is UNVERIFIED: test it in step 2.

Closest siblings: `apps/bazarr` (python), `apps/changedetection` (python-node). Confirm with `ls apps/` before implementing.

## 4. Dockerfile

Option A (preferred, pip-free, source tarball, matches upstream's own install path):

1. `FROM <python base> AS build`, `ARG VERSION`, `USER root`.
2. `apt-get install -y --no-install-recommends make gettext intltool` (build-only tools, removed or left in build stage only).
3. `curl -fL https://github.com/gpodder/gpodder/archive/refs/tags/${VERSION}.tar.gz | tar xz -C /tmp/src --strip-components=1`.
4. `make -C /tmp/src install PREFIX=/usr DESTDIR=/tmp/out` (no `/usr/share/gpodder/no-update-check` unless it is wanted: the upstream image disables the in-app update check, which is a container decision to keep).
5. Runtime stage: same base, `USER root` for `apt-get install -y --no-install-recommends ffmpeg python3-mygpoclient python3-podcastparser python3-html5lib python3-requests python3-mutagen python3-pil python3-socks python3-gi python3-dbus` (package names UNVERIFIED for the chosen base; the ContainerForge python base may not provide them, so use `pip` into `/tmp` or the base venv instead: `/app/venv` is read-only, so install into `/tmp/venv` only if needed).
6. `COPY --from=build /tmp/out/ /` (after verifying the layout), license to `/usr/share/licenses/gpodder/COPYING`.
7. `chown -R apps:apps` on any `/app` tree written at build time.
8. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /
   ENV GPODDER_HOME=/config GPODDER_DOWNLOAD_DIR=/downloads HOME=/config
   EXPOSE 3000
   VOLUME ["/config", "/downloads"]
   ```
   `EXPOSE 3000` only if option B (web UI) is used; the non-GUI option exposes nothing.

Option B (GUI, not recommended): would need a selkies-equivalent desktop and web proxy on ubuntu. Not in ContainerForge today. Out of scope for this plan.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "gpodder" }
variable "VERSION" {
  // renovate: datasource=github-tags depName=gpodder/gpodder versioning=semver
  default = "3.11.5"
}
variable "LICENSE" { default = "GPL-3.0-only" }
variable "SOURCE" { default = "https://github.com/gpodder/gpodder" }
```

`LICENSE` SPDX suffix (`-only` vs `-or-later`): UNVERIFIED. The COPYING file is GPLv3 text only; the choice must match upstream's stated license in `setup.py`/README (not fetched in full). Use `GPL-3.0-only` only after checking. Standard four targets and `default` group from `apps/adguardhome-sync`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/gpodder/gpodder"
ports: []
env:
  - name: GPODDER_DOWNLOAD_DIR
    default: "/downloads"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
  - path: /downloads
    required: false
dependencies: []
```

Ports: empty for the non-GUI option, since nothing listens. Option B would need 3000 and a probe. Env: `GPODDER_HOME` is hard-set to `/config`, so it is not user-facing. `PASSWORD` from the chart is only meaningful for the selkies UI and must not be listed (it is not read by the non-GUI core; UNVERIFIED for the xthursdayx image).

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config /downloads

export GPODDER_HOME="${GPODDER_HOME:-/config}"
export GPODDER_DOWNLOAD_DIR="${GPODDER_DOWNLOAD_DIR:-/downloads}"

cd /tmp
exec gpodder --no-gui "$@"
```

Notes:
- `--no-gui` is a CLI flag: UNVERIFIED. Confirm with `gpodder --help` in step 2 before writing the `exec` line. If gPodder has no headless mode that stays alive, a long-running process does not exist, and the app is not a container service (see section 10).
- Seeding: none required; gPodder creates `GPODDER_HOME` on first use. Confirm that a fresh empty `/config` works (protocol step 3).
- No writes to `/app`. Caches go to `/tmp` (`XDG_CACHE_HOME=/tmp/cache`).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
filePaths:
- /usr/bin/gpodder
- /usr/share/licenses/gpodder/COPYING
```

No tcp/http probe for the non-GUI option (no listener). If a process probe is supported by forgetool, add it for the running daemon; otherwise rely on `filePaths` plus step 3 log checks. Do not invent a port probe. For option B, add `tcp: [{port: '3000'}]` and an `http` probe, per the container-test rules.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `GPODDER_HOME=/config` (upstream, unchanged) | `/config` persistent; keep the upstream name. |
| `GPODDER_DOWNLOAD_DIR=/downloads` | Keep `/downloads` as a volume (chart `downloadspath`); not `/config`. |
| `XDG_CACHE_HOME`, `HOME` for gtk/webkit caches | `/tmp` (`HOME=/config` only if the app stores settings there; cache under `/tmp`). |
| Selkies `/config` root, `/var/run` (chart disables `varrun`) | Not needed for the non-GUI option. |
| Runtime user | Chart forces root (`runAsUser: 0`, `runAsGroup: 0`). ContainerForge: `USER apps`. The non-GUI core writes only to `/config` and `/downloads`, so the chart's root is not required (UNVERIFIED by running it as `apps`). |
| `readOnlyRootFilesystem` | Compatible for the non-GUI option (only `/config`, `/downloads`, `/tmp` written). Chart's `false` is not needed. |

## 10. Risks, caveats and open questions

- **Scope blocker (decide before implementing).** The upstream image is a GUI desktop (selkies web desktop, GTK, WebKit). ContainerForge has no selkies base. A headless gPodder core is a different product from the chart's container. Ask the user whether a non-GUI image is acceptable; if not, record as `blocked: needs GUI desktop base` and stop.
- Headless mode: whether gPodder 3.11.5 has a non-GUI run mode that stays running is UNVERIFIED (gPodder is primarily a GUI application; it may only run subcommands). If it cannot stay up, the step 3 criteria cannot be met: record `unfixable`.
- Ubuntu apt package lags upstream (3.11.3 seen vs 3.11.5). Pin the version, or build from source.
- Chart pins the third-party `xthursdayx` image at rolling `latest`, so the chart is not a reliable reference for behaviour.
- The upstream Dockerfile downloads a web icon from `raw.githubusercontent.com/xthursdayx/docker-templates` (third-party, unverified). Do not copy it.
- Upstream Dockerfile uses Alpine packages (`py3-*`, `webkit2gtk-4.1`, `yt-dlp`). Ubuntu package names differ and are UNVERIFIED per series.
- `PASSWORD` env from the chart: not read by the non-GUI core (UNVERIFIED); do not add it.
- License SPDX suffix: UNVERIFIED (see section 5).

## 11. Build and test steps

From `apps/gpodder/`:

```sh
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name gpodder-probe --read-only --tmpfs /tmp \
  -v gpodder-probe-config:/config -v gpodder-probe-downloads:/downloads gpodder:3.11.5
docker logs -f gpodder-probe
forgetool containers test --image gpodder:3.11.5 --config ./container-test.yaml
docker rm -f gpodder-probe; docker volume rm gpodder-probe-config gpodder-probe-downloads
```

Expected readiness signal: UNVERIFIED until `gpodder --help` and a headless run are checked in step 2. Do not accept "exits 0" as success under the protocol (the container must stay running).

## 12. PR checklist

- Branch `feat/add-gpodder`; commit `feat(gpodder): add new container`; PR title the same.
- PR body from `.github/PULL_REQUEST_TEMPLATE.md`; `🤖 This PR is AI generated.` in Notes.
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (only they can sign; the `license/cla` check shows status).
- State untested items: GUI, arm64 build, Ubuntu/Python package versions, headless run mode.
- Do not check "Built container locally" unless steps 2 and 3 passed.
- No downstream `FROM` expected; confirm with `grep -rl "apps/gpodder" apps/*/Dockerfile`.
