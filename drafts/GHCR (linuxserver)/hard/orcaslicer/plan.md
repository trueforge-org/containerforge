# orcaslicer — implementation plan
> Source: ./draft.md · Target: apps/orcaslicer/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Draft pins **2.5.1**. Latest stable is **v2.5.2** (published 2026-11-21). Plan: pin **2.5.2**. Source: https://api.github.com/repos/OrcaSlicer/OrcaSlicer/releases/latest (via `gh api`). |
| Difference from draft | Repo moved: canonical is `OrcaSlicer/OrcaSlicer`; the draft's `SoftFever/OrcaSlicer` URLs redirect. Use the canonical repo for `SOURCE` and renovate. |
| Renovate | `datasource=github-releases depName=OrcaSlicer/OrcaSlicer versioning=semver` (tags are `vX.Y.Z`). Proposed, consistent with the release API above. |
| License | **AGPL-3.0** (GitHub API `license.spdx_id` for OrcaSlicer/OrcaSlicer, via `gh api`). |
| Source URL | https://github.com/OrcaSlicer/OrcaSlicer |
| Download amd64 | https://github.com/OrcaSlicer/OrcaSlicer/releases/download/v2.5.2/OrcaSlicer_Linux_AppImage_Ubuntu2404_V2.5.2.AppImage (size 201034232, from release asset list) |
| Download arm64 | https://github.com/OrcaSlicer/OrcaSlicer/releases/download/v2.5.2/OrcaSlicer_Linux_AppImage_Ubuntu2404_aarch64_V2.5.2.AppImage (size 196807176, from release asset list). Same naming pattern confirmed for 2.5.1 (HEAD 200 both arches). |
| Checksum source | **None published.** The v2.5.2 asset list has no `.sha256`, `.sha512` or checksum file. Plan: pin a SHA256 computed locally at build time (or from a first verified download) and record it in a comment. UNVERIFIED until computed. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/linuxserver/docker-orcaslicer/4b114d95b04b/Dockerfile. Base `ghcr.io/linuxserver/baseimage-selkies:debiantrixie`. Adds the Mozilla apt repo and installs `firefox` plus gstreamer, `libwebkit2gtk-4.1-0`, `libwx-perl`, `libmspack0`. Downloads the `Ubuntu2404_V` AppImage from the GitHub API latest release (unpinned unless `ORCASLICER_VERSION` is set), runs `--appimage-extract` to `/opt/orcaslicer` (no FUSE needed), `sed` adds `export GDK_BACKEND=x11` to `AppRun`. `ENV TITLE=OrcaSlicer SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt PIXELFLUX_WAYLAND=true`; `COPY /root /`; `EXPOSE 3001`; `VOLUME /config`. |
| Ports | 3001 (EXPOSE in upstream). Draft's 3000 is UNVERIFIED. |
| Env vars (real) | Only the image ENV values above are confirmed. OrcaSlicer's own env vars: UNVERIFIED. |
| Data path | `/config` (VOLUME in upstream). Profile location under `$HOME`: UNVERIFIED. |
| arm64 | aarch64 AppImage exists for v2.5.2. The upstream linuxserver image builds for arm64 (UNVERIFIED for this tag). |

## 2. Target layout

- `apps/orcaslicer/Dockerfile`
- `apps/orcaslicer/docker-bake.hcl`
- `apps/orcaslicer/settings.yaml`
- `apps/orcaslicer/container-test.yaml`
- `apps/orcaslicer/start.sh`

No `defaults/` unless a default profile is needed. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. Fits because the app is a prebuilt AppImage (built for Ubuntu 24.04) and needs only glibc plus GUI libraries. Closest sibling for GUI apps: `apps/kasmvnc` or `apps/xvfb` (both exist; not inspected in this run). The draft's `libfuse2` guess is not needed if the AppImage is extracted (upstream method).

## 4. Dockerfile

1. `# syntax=docker/dockerfile:1`, `FROM <ubuntu digest>`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Map the arch to the asset name, failing on unknown arches:
   ```dockerfile
   RUN set -eux; \
     case "$TARGETARCH" in \
       amd64) ORCA_ARCH="";          ORCA_SHA256="<sha256 computed locally, amd64>" ;; \
       arm64) ORCA_ARCH="aarch64_";  ORCA_SHA256="<sha256 computed locally, arm64>" ;; \
       *) echo "unsupported arch $TARGETARCH" >&2; exit 1 ;; \
     esac; \
     curl -fsSL -o /tmp/orca.AppImage \
       "https://github.com/OrcaSlicer/OrcaSlicer/releases/download/v${VERSION}/OrcaSlicer_Linux_AppImage_Ubuntu2404_${ORCA_ARCH}V${VERSION}.AppImage"; \
     echo "${ORCA_SHA256}  /tmp/orca.AppImage" | sha256sum -c -
   ```
   The `sha256` literal is not published upstream: compute it from the downloaded file once, then pin it. Do not invent a value. The `VERSION` `2.5.2` must match `docker-bake.hcl`.
3. Extract (no FUSE, runs as root only at build time):
   ```dockerfile
   RUN set -eux; \
     cd /tmp && chmod +x orca.AppImage && ./orca.AppImage --appimage-extract && \
     mv squashfs-root /app/orcaslicer && \
     rm -f /tmp/orca.AppImage
   ```
   `/app/orcaslicer` is the extracted tree. Check that `AppRun` and `bin/` exist (`test -x /app/orcaslicer/AppRun`).
4. Apt packages: the upstream list (`libwebkit2gtk-4.1-0`, `libwx-perl`, `libmspack0`, gstreamer plugins, `libgtk-3-0t64` etc.) is for a Debian trixie base. On Ubuntu 26.04, install only what `ldd /app/orcaslicer/bin/orca-slicer` reports as missing. Package names are UNVERIFIED for 26.04 and must be confirmed with `apt-cache policy`.
5. Set the X11 backend as upstream does: `sed -i "1a export GDK_BACKEND=x11" /app/orcaslicer/AppRun` (inspect the result).
6. License: copy the AppImage's license file (path inside the extracted tree is UNVERIFIED; `LICENSE` in the repo is AGPL-3.0) into `/usr/share/licenses/orcaslicer/`. Fetch `LICENSE` from the repo tag if none is inside the AppImage.
7. Cleanup apt lists and `/tmp/*` in the same layer.
8. Final tail:
   ```dockerfile
   ENV HOME=/config \
       XDG_CACHE_HOME=/tmp/.cache \
       SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
   RUN chown -R apps:apps /app/orcaslicer && chmod -R 755 /app/orcaslicer
   USER apps
   COPY --chmod=0755 . /
   EXPOSE 3001
   VOLUME /config
   ```
   `COPY --chmod=0755 . /` is mandatory.

## 5. docker-bake.hcl

```hcl
variable "APP" {
  default = "orcaslicer"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=OrcaSlicer/OrcaSlicer versioning=semver
  default = "2.5.2"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/OrcaSlicer/OrcaSlicer"
}
```

Four standard targets and the default group as in `apps/adguardhome-sync`. `image-all` keeps both platforms (amd64 and arm64 AppImages exist). Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/OrcaSlicer/OrcaSlicer"
ports:
  - port: 3001
    protocol: tcp
    required: false
env:
  - name: TITLE
    default: "OrcaSlicer"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

- Port 3001 only if the display/web layer serves it (section 10).
- No dependencies.
- Env: only `TITLE` and `TZ`. Do not invent OrcaSlicer env vars.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/.config /tmp/.cache

export HOME=/config
export XDG_CACHE_HOME=/tmp/.cache
export GDK_BACKEND=x11

cd /config
exec /app/orcaslicer/AppRun
```

- Idempotent: only creates dirs when missing; never writes to `/app`.
- Caches go to `/tmp`; profile and settings to `/config` (UNVERIFIED path under `$HOME`).
- `GDK_BACKEND=x11` matches the upstream AppRun change; keep it in `start.sh` too so it is visible.
- Fail with a clear message if `DISPLAY` and `WAYLAND_DISPLAY` are both unset (section 10).
- `exec` for PID 1 handoff.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '3001'
filePaths:
- /app/orcaslicer/AppRun
```

- Every `settings.yaml` port has a probe (3001).
- `filePaths` covers the entry point.
- `timeoutSeconds`: UNVERIFIED; take from a sibling GUI app once chosen. Use a generous value for a GUI start.
- The test sets no env vars, so the display path is untested here (section 10).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `$HOME` profile and settings | `HOME=/config`, persistent. |
| Caches | `XDG_CACHE_HOME=/tmp/.cache`. |
| `AppRun` edits | Done at build time only, never at run time. |
| Mozilla Firefox from apt (upstream installs it for the slicer's web views) | Not required for the slicer itself; drop it unless a function needs it (UNVERIFIED). Do not add a browser to the image just for this. |

Draft's security expectations (root, `readOnlyRootFilesystem: false`, common root caps) are replaced: target `USER apps`, read-only rootfs, writable `/tmp` and `/config` only. No extra persistence.

## 10. Risks, caveats and open questions

- **Blocker: display layer.** The slicer GUI needs X11 or Wayland and OpenGL. Options: use `apps/kasmvnc` or `apps/xvfb` (not inspected in this run) or reject. Without a display layer, protocol step 3 cannot show readiness. Software OpenGL may be slow (draft caveat, confirmed as a plausible risk, not measured).
- **Blocker: no published checksum.** Pin a locally computed SHA256 and say so in a comment and in the PR.
- **Ubuntu 24.04 AppImage on 26.04 base:** the extracted binary's library needs are UNVERIFIED; run `ldd` at build time and install only missing libraries.
- **Version:** 2.5.2 is pinned. Upstream linuxserver fetches the latest release at build time, which this plan does not copy.
- **Resource needs:** slicing is CPU and RAM heavy (draft caveat). Not measured; do not put numbers in `settings.yaml`.
- **Licence:** AGPL-3.0 confirmed via GitHub API. Keep the license file in the image.
- arm64 AppImage is listed; not built or run.
- No dependencies, so no database rules apply.

## 11. Build and test steps

From `apps/orcaslicer`:

1. `docker buildx bake --print` (exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Run and parse logs:
   ```sh
   docker run --rm -d --name orcaslicer-probe --read-only --tmpfs /tmp \
     -v orcaslicer-probe-config:/config orcaslicer:2.5.2
   docker logs -f orcaslicer-probe
   ```
   Also check at build time: `docker run --rm --entrypoint sh orcaslicer:2.5.2 -c 'ldd /app/orcaslicer/bin/orca-slicer | grep "not found"'` must print nothing.
   Expected readiness: process running after the startup window and port 3001 open.
4. Cleanup: `docker rm -f orcaslicer-probe; docker volume rm orcaslicer-probe-config`.
5. Test suite: `forgetool containers test --image orcaslicer:2.5.2 --config ./apps/orcaslicer/container-test.yaml`.
6. Build arm64 only if the amd64 failure is arm64-specific.

## 12. PR checklist

- Branch: `feat/add-orcaslicer`. Commit: `feat(orcaslicer): add new container`. Title matches the commit.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes; check only what applies.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- State what is untested: display layer, library set on 26.04, OpenGL behavior, arm64, and the locally computed SHA256 (upstream publishes none).
- Downstream: none (not a `FROM` base), so no `DOWNSTREAM_CHANGES.md`.
