# calibre — implementation plan
> Source: ./draft.md · Target: apps/calibre/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `9.19.0` (tag `v9.19.0`, published 2026-11-21). The draft pins linuxserver `9.18.0`, which is stale (the TrueCharts chart already pins `9.19.0`, appVersion 9.19.0). Source: https://api.github.com/repos/kovidgoyal/calibre/releases/latest |
| Renovate | `// renovate: datasource=github-releases depName=kovidgoyal/calibre versioning=loose` (tag is `v`-prefixed, so `loose`). |
| License | GPL-3.0 (https://api.github.com/repos/kovidgoyal/calibre). |
| Source URL | https://github.com/kovidgoyal/calibre |
| Download amd64 | https://github.com/kovidgoyal/calibre/releases/download/v9.19.0/calibre-9.19.0-x86_64.txz |
| Download arm64 | https://github.com/kovidgoyal/calibre/releases/download/v9.19.0/calibre-9.19.0-arm64.txz |
| Checksum source | None. The release has no checksum asset (checked the asset list). UNVERIFIED: an upstream checksum. Plan: record the sha256 of each tarball at first download and pin it in the Dockerfile, marked as self-computed. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/linuxserver/docker-calibre/master/Dockerfile. `FROM ghcr.io/linuxserver/baseimage-selkies:ubunturesolute`; downloads the x86_64 `.txz` from GitHub (fallback calibre-ebook.com), extracts to `/opt/calibre`, runs `calibre_postinstall`; `dbus-uuidgen > /etc/machine-id`; `COPY root/ /`; `HOME=/config`; no `EXPOSE`, no `VOLUME`, no `USER`. Only x86_64 is fetched there, so the arm64 image is not proven upstream. |
| Env vars (upstream, Selkies) | `CUSTOM_PORT=8080`, `CUSTOM_HTTPS_PORT=8181`, `HOME=/config`, `TITLE=Calibre`, `QTWEBENGINE_DISABLE_SANDBOX=1`, `NO_GAMEPAD=true`, `PIXELFLUX_WAYLAND=true`. Only `HOME` is relevant to a headless image. `QTWEBENGINE_DISABLE_SANDBOX=1` is a security caveat. |
| apt packages (upstream) | dbus, fcitx-rime, fonts-wqy-microhei, libnss3, libopengl0, libqpdf30, libxkbcommon-x11-0, libxcb-cursor0, libxcb-icccm4, libxcb-image0, libxcb-keysyms1, libxcb-randr0, libxcb-render-util0, libxcb-xinerama0, poppler-utils, python3, python3-xdg, ttf-wqy-zenhei, wget, xz-utils; speech-dispatcher separately. Most are GUI or font packages. |
| Port | 8080 is the upstream `CUSTOM_PORT` for the Selkies UI. The calibre content server port is UNVERIFIED for this image. The draft's 3000/3001 are UNVERIFIED. |
| Data / config paths | `HOME=/config` (upstream). The library location is UNVERIFIED. |
| Dependencies | None. |

## 2. Target layout

- `apps/calibre/Dockerfile`
- `apps/calibre/docker-bake.hcl`
- `apps/calibre/settings.yaml`
- `apps/calibre/container-test.yaml`
- `apps/calibre/start.sh`

No `root/`. No `DOWNSTREAM_CHANGES.md`, because nothing uses this image as `FROM`. Add `defaults/` only if a config seed is shown to be needed.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. The `.txz` bundles its own Qt runtime, so the generic ubuntu userland fits. Closest sibling: `apps/adguardhome-sync` (prebuilt binary on ubuntu). The draft's reason holds.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`. Map `amd64` to `x86_64` and `arm64` to `arm64` for the asset name.
2. `ARG SHA256_X86_64` and `ARG SHA256_ARM64`, pinned to the self-computed values from the first download (section 1). Verify with `sha256sum -c`.
3. `USER root`. Download to `/tmp/calibre.txz`:
   `curl -fsSL -o /tmp/calibre.txz "https://github.com/kovidgoyal/calibre/releases/download/v${VERSION}/calibre-${VERSION}-${ARCH}.txz"`
4. Extract to `/opt/calibre` and run `/opt/calibre/calibre_postinstall` (or confirm it is not needed on headless use; UNVERIFIED). Do not write to `/app`.
5. Install only the runtime libraries the binaries need that the base lacks. Check with `ldd` on `/opt/calibre/calibre-server` and `/opt/calibre/ebook-convert`. Pin any apt package to the 26.04 version. Versions UNVERIFIED.
6. License from the tarball to `/usr/share/licenses/calibre/`. Path UNVERIFIED until the tarball is read.
7. `ENV HOME=/config XDG_CACHE_HOME=/tmp`. Clean `/tmp/calibre.txz` and apt lists.
8. Final stage: `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "calibre" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=kovidgoyal/calibre versioning=loose
  default = "9.19.0"
}
variable "LICENSE" { default = "GPL-3.0" }
variable "SOURCE" { default = "https://github.com/kovidgoyal/calibre" }
```

Keep the four standard targets and the `default` group from `apps/adguardhome-sync`. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/kovidgoyal/calibre"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Port 8080 is the planned content server port. Confirm it on the first run, because the upstream value only comes from the Selkies env. Dependencies: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
mkdir -p /config/library
exec /opt/calibre/calibre-server --listen-on 0.0.0.0 --port 8080 /config/library
```

`calibre-server` in the tarball is the expected headless entry point (UNVERIFIED: confirm the binary name and flags on the first build). It listens on all interfaces, writes only to `/config` and `/tmp`, and seeds nothing beyond creating the library directory. The `/config/library` subdirectory is a plan choice, not an upstream fact.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /opt/calibre/calibre-server
- /usr/share/licenses/calibre/
```

The test runs with no env vars, and the server needs none, so no required-env path is covered here. The HTTP status for `/` is UNVERIFIED, so confirm the status code on the first run before setting the probe.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `HOME=/config` (library, settings, caches) | Kept under `/config`. Caches go to `/tmp` via `XDG_CACHE_HOME`. |
| `/etc/machine-id` (`dbus-uuidgen`) | Not needed for a headless server. Do not write it at build. UNVERIFIED that calibre-server needs it. |
| `/opt/calibre` | Build-time extraction only. Nothing writes there at runtime. |

Reconciling the draft's expectations: the chart runs as root with `readOnlyRootFilesystem: false`. The target runs as `USER apps` on a read-only rootfs. Drop `QTWEBENGINE_DISABLE_SANDBOX=1` (not needed headless). Not privileged.

## 10. Risks, caveats and open questions

- **No upstream checksum.** The sha256 must be self-computed on the first download and documented as such. UNVERIFIED against upstream.
- **Large tarball.** The first start and image pull will be slow (draft caveat).
- **Desktop packages.** The upstream apt list is mostly GUI and fonts. The headless target should keep only what `calibre-server` needs (confirm with `ldd`).
- **Content server must be enabled in the GUI** (draft note). In a headless build it starts directly, so the note does not apply.
- **Port.** 8080 is the planned port. The upstream value comes from the Selkies env, so it is UNVERIFIED for the calibre content server.
- **arm64:** the arm64 `.txz` exists, but upstream linuxserver only fetches x86_64, so arm64 is UNVERIFIED for the image.
- **Security:** the draft's root and capability expectations do not apply. Verify the server does not need `QTWEBENGINE_DISABLE_SANDBOX`.

## 11. Build and test steps

```sh
cd apps/calibre
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name calibre-probe --read-only --tmpfs /tmp -v calibre-probe-config:/config calibre:9.19.0
docker logs -f calibre-probe
forgetool containers test --image calibre:9.19.0 --config ./apps/calibre/container-test.yaml
docker rm -f calibre-probe; docker volume rm calibre-probe-config
```

Readiness signal: UNVERIFIED. Expect the server to log that it is listening on port 8080 (confirm on the first build).

## 12. PR checklist

- Branch `feat/add-calibre`, commit `feat(calibre): add new container`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`, keeping sections and checkboxes.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- State that nothing was built or run, if that remains true.
