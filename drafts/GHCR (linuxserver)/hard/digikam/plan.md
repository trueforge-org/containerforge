# digikam — implementation plan
> Source: ./draft.md · Target: apps/digikam/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 9.1.0 (latest stable in the KDE mirror, listed 2026-06-08). Draft tag matches. Source: https://mirrors.mit.edu/kde/stable/digikam/ |
| linuxserver tag in draft | `ghcr.io/linuxserver/digikam:9.1.0` (upstream tag `9.1.0-ls336`, published 2026-11-23). Source: https://api.github.com/repos/linuxserver/docker-digikam/releases |
| Renovate | UNVERIFIED: no confirmed datasource for the KDE mirror. GitHub `KDE/digikam` has no releases (404) and its tags stop at v6.x, so `github-releases` is wrong. Pick the pattern from a sibling that downloads from a mirror, or use a regex-based custom manager. |
| License | GPL-2.0 (`KDE/digikam`, GitHub SPDX). Upstream linuxserver wrapper is GPL-3.0 (not what ships in the image). Use `GPL-2.0` unless a license file in the AppImage says otherwise (UNVERIFIED). |
| Source URL | https://github.com/KDE/digikam (docs https://docs.digikam.org/, site https://www.digikam.org/) |
| Download (amd64) | `https://mirrors.mit.edu/kde/stable/digikam/${VERSION}/digiKam-${VERSION}-Qt6-x86-64.appimage` (316 MiB for 9.1.0). Listing: https://mirrors.mit.edu/kde/stable/digikam/9.1.0/ |
| Download (arm64) | UNVERIFIED: no arm64 AppImage in the 9.1.0 listing. Only x86-64 Qt5/Qt6 AppImages, plus macOS arm64 and Win64 packages. |
| Checksum source | None published (no `.sha256`, `.sha1` or `.md5` in the mirror directory). Detached signature `digiKam-9.1.0-Qt6-x86-64.appimage.sig` (833 B) is published. Signing key fingerprint: UNVERIFIED (not fetched). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/linuxserver/docker-digikam/fd0663bebb867b7dba24c63d14e0493e7d94c0b9/Dockerfile: `FROM ghcr.io/linuxserver/baseimage-selkies:debiantrixie`, AppImage extracted to `/opt/digikam`, launched by `/usr/sbin/digikam` (`cd /opt/digikam && ./AppRun`), apt installs `breeze-icon-theme caja chromium mariadb-server openexr libimage-exiftool-perl`, EXPOSE 3001, no VOLUME, no USER (base default). |
| Upstream env (real) | `TITLE=DigiKam`, `NO_GAMEPAD=true`, `PIXELFLUX_WAYLAND=true` (set in the Dockerfile). Build args `VERSION`, `DIGIKAM_VERSION`, `BUILD_DATE`. |
| Upstream base env | From the linuxserver selkies README (summarized, partial): `PUID`, `PGID`, `TZ`, `UMASK`, `CUSTOM_USER`, `PASSWORD`, `FILE__<VAR>`. Ports 3000 (http, must be proxied) and 3001 (https, required). `/config` is the home and data volume. Source: https://raw.githubusercontent.com/linuxserver/docker-digikam/fd0663bebb867b7dba24c63d14e0493e7d94c0b9/README.md |
| Architecture | amd64 only upstream. The README states arm64 is not available (changelog 25.11.24, "drop aarch64 support"). |

## 2. Target layout

- `apps/digikam/Dockerfile`
- `apps/digikam/docker-bake.hcl`
- `apps/digikam/settings.yaml`
- `apps/digikam/container-test.yaml`
- `apps/digikam/start.sh`

No `defaults/` or `etc/` (no seed config is needed for a first run). No `root/` (reserved, must not be touched). No `DOWNSTREAM_CHANGES.md` (the app is not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`, single stage (AppImage, no compile step).

Why: the AppImage is self-contained, so ubuntu is enough. There is no `python` or `java` runtime need. Closest sibling for a display-based app on ubuntu: `apps/xvfb` (ubuntu plus `apt-get install xvfb`, `USER apps`, `COPY --chmod=0755 . /`). The linuxserver `baseimage-selkies` base is NOT used: ContainerForge has no equivalent, and it runs as root (see section 10).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Fail fast on unsupported arches, because the AppImage is x86-64 only:
   `RUN [ "$TARGETARCH" = "amd64" ] || { echo "digikam: amd64 only"; exit 1; }`
3. Install the minimum apt packages needed to run a Qt6 AppImage headless-friendly. Final list depends on the display stack chosen (section 10, blocker 1). Expected: `libfuse2t64` is NOT needed because we extract instead of mounting. Icon theme (`breeze-icon-theme`) and `libimage-exiftool-perl` are UNVERIFIED as runtime needs; include only what `AppRun` fails without (test with `ldd`/startup, do not guess). Do not install `chromium`, `caja` or `mariadb-server` (see section 9).
4. Download and verify:
   ```dockerfile
   RUN curl -fL -o /tmp/digikam.appimage \
     "https://mirrors.mit.edu/kde/stable/digikam/${VERSION}/digiKam-${VERSION}-Qt6-x86-64.appimage" && \
     curl -fL -o /tmp/digikam.appimage.sig \
     "https://mirrors.mit.edu/kde/stable/digikam/${VERSION}/digiKam-${VERSION}-Qt6-x86-64.appimage.sig"
   ```
   There is no published checksum, so pin the version and verify the signature against the KDE key once its fingerprint is confirmed (UNVERIFIED). Record that gap in section 10.
5. Extract without FUSE (containers have no `/dev/fuse` by default):
   `chmod +x /tmp/digikam.appimage && cd /tmp && ./digikam.appimage --appimage-extract && mv /tmp/squashfs-root /app/digikam`
   Upstream moves the output to `/opt/digikam`. We use `/app/digikam` to follow the `/app` rule. UNVERIFIED: `--appimage-extract` must work on the arch and kernel of the build runner; test in step 11.
6. Licenses: ship the license text from the extracted tree to `/usr/share/licenses/digikam/` (exact path inside the AppImage UNVERIFIED; locate it with `find /app/digikam -iname 'COPYING*' -o -iname 'LICENSE*'` during the build, and fail if none is found).
7. Cleanup: `rm -f /tmp/digikam.appimage /tmp/digikam.appimage.sig`, then `apt-get clean && rm -rf /var/lib/apt/lists/*`.
8. `chown -R apps:apps /app/digikam && chmod -R 755 /app/digikam`.
9. Tail:
   ```dockerfile
   ENV HOME=/config TZ=Etc/UTC
   USER apps
   COPY --chmod=0755 . /
   EXPOSE <ports from section 6>
   VOLUME /config
   ```
   `HOME=/config` keeps the digiKam profile and library index (sqlite by default) on the persistent volume. `/config/.cache` must not be used for caches: set `XDG_CACHE_HOME=/tmp/cache` (upstream cleans `/config/.cache`, so it did write there).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "digikam"
}

variable "VERSION" {
  // renovate: datasource=UNVERIFIED depName=UNVERIFIED (see section 1; the KDE mirror is not a GitHub release source)
  default = "9.1.0"
}

variable "LICENSE" {
  default = "GPL-2.0"
}

variable "SOURCE" {
  default = "https://github.com/KDE/digikam"
}
```

Then the standard `image`, `image-local`, `image-all` and `default` group, copied from `apps/adguardhome-sync`. Difference: `image-all` must list only `linux/amd64` until an arm64 artifact is verified. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/KDE/digikam"
ports:
  - port: 3000        # UNVERIFIED: only if the chosen display stack serves HTTP on 3000
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

Ports are the open question: list only the ports the chosen stack really listens on (section 10). `dependencies`: none. The linuxserver image installs its own MariaDB, which is not a separate ContainerForge dependency; do not declare `mariadb` unless digiKam needs a server database for the chosen setup (UNVERIFIED). Env: list only variables `start.sh` or the stack reads. Do not copy the upstream `PUID`/`PGID` set unless our start script implements them.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/digikam /tmp/cache

cd /app/digikam
exec ./AppRun
```

Rules: idempotent, seeds nothing, never writes under `/app`. `XDG_CACHE_HOME` and `TMPDIR` point at `/tmp`. `exec` hands PID 1 to the app. The display stack (virtual X server and remote-desktop server) must be started before `AppRun`, in the same script, with the app kept in the foreground. Bind any server to `0.0.0.0`. The final process choice depends on section 10, blocker 1.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120   # UNVERIFIED: take the value from the sibling chosen in section 3
tcp:
- port: '3000'        # one tcp probe per port listed in settings.yaml
filePaths:
- /app/digikam/AppRun
- /usr/share/licenses/digikam
```

Every port in `settings.yaml` needs a `tcp` probe. The test runs with no env vars, so no password path is covered; if `start.sh` has a branch for an env var, add its file to `filePaths` and run it by hand per the protocol. The narrowing exception does not apply: there is no hard database dependency.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/config/.cache` (cleaned by upstream, so it was written) | `XDG_CACHE_HOME=/tmp/cache` |
| digiKam profile and library index under `$HOME` | `HOME=/config` (persistent, required) |
| AppImage extraction and `/tmp` scratch | `/tmp` (tmpfs under the protocol's `--read-only --tmpfs /tmp`) |
| Upstream `/opt/digikam` | `/app/digikam` (read-only at runtime, populated at build time) |
| X and desktop sockets | `/tmp/.X11-unix` on tmpfs (UNVERIFIED that the chosen stack needs nothing else) |

Security reconciliation (draft expectations to verify, not to copy):
- non-root: target is `USER apps`. The draft's `runAsUser 0` comes from the chart and is not a requirement for us.
- read-only rootfs: target is yes. The draft says no (chart value); our Dockerfile and start script keep all writes in `/config` and `/tmp`.
- privileged: no. Confirm no capability beyond the default.
- extra persistence: none beyond `/config`. The photo library itself is a user mount, not something the image owns; document it in the README-facing notes, not in the image.

## 10. Risks, caveats and open questions

- **Blocker 1 (decision needed): display stack.** The upstream image is a Selkies desktop (browser streaming) on a linuxserver base. ContainerForge has no equivalent. Options: (a) Xvfb plus a remote-desktop server, following `apps/kasmvnc` and `apps/xvfb` (kasmvnc uses a `root/` tree, which this plan does not use; copy only the pattern). (b) Defer the app until ContainerForge has a desktop base. Do not build until one of these is chosen; the ports, probes and readiness signal depend on it.
- **Blocker 2: amd64 only.** The AppImage is x86-64. `arm64` is UNVERIFIED and not built. The draft says arm64 "yes" through apt; that route is not verified for digiKam (apt digikam on arm64 was not fetched).
- **Integrity:** no published checksum. Mitigated by the version pin plus the `.sig` file; the key fingerprint is UNVERIFIED.
- **Size:** AppImage 316 MiB; the extracted tree is larger. Expect a large image.
- **FUSE:** avoided by `--appimage-extract`. If `AppRun` still needs FUSE or a bundled library is missing at runtime, that is the failure to check in step 11.
- **License:** GitHub SPDX says `GPL-2.0`, while the linuxserver wrapper is `GPL-3.0`. Use the upstream project's license; confirm with the license file inside the AppImage (UNVERIFIED).
- Upstream installs `chromium`, `caja` and `mariadb-server`. Not needed for digiKam itself; leave out unless a test shows a missing dependency.
- Draft caveat "photo library must be mounted to persist": agreed. Document it in the app's notes; no image change.

## 11. Build and test steps

From `apps/digikam/`:

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Run on read-only rootfs with an empty volume:
   ```sh
   docker volume create digikam-probe-config
   docker run --rm -d --name digikam-probe --read-only --tmpfs /tmp \
     -v digikam-probe-config:/config digikam:9.1.0
   docker logs -f digikam-probe
   ```
   Expected readiness signal: UNVERIFIED until the display stack is chosen (it will be the stack's own "listening on" line plus the process still running). Fail on any fatal line or exit.
4. `forgetool containers test --image digikam:9.1.0 --config ./apps/digikam/container-test.yaml`
5. Clean up: `docker rm -f digikam-probe; docker volume rm digikam-probe-config`.

## 12. PR checklist

- Branch `feat/add-digikam`, commit `feat(digikam): add new container`, PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows status).
- Say what was not tested: arm64 not built; GUI behaviour and readiness not verified unless the run in step 3 was done; checksum not verified against upstream.
- Do not check "Built container locally" unless step 2 and step 4 actually ran.
