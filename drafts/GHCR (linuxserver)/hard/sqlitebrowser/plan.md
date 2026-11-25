# sqlitebrowser — implementation plan
> Source: ./draft.md · Target: apps/sqlitebrowser/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 3.13.1. Upstream latest release v3.13.1, published 2024-10-16 (https://api.github.com/repos/sqlitebrowser/sqlitebrowser/releases/latest). Ubuntu archive has `sqlitebrowser` 3.13.1-1 (https://packages.ubuntu.com/resolute/sqlitebrowser). |
| Renovate | `datasource=github-releases depName=sqlitebrowser/sqlitebrowser versioning=semver` for the AppImage. The apt version is pinned separately (see section 4). |
| License | MPL-2.0 OR GPL-3.0-or-later (bi-licensed, from https://raw.githubusercontent.com/sqlitebrowser/sqlitebrowser/master/LICENSE). GitHub's API reports `NOASSERTION`, so it does not detect a single SPDX id. Use the bi-licence text in `LICENSE` as `MPL-2.0 OR GPL-3.0-or-later`. |
| Source URL | https://github.com/sqlitebrowser/sqlitebrowser |
| Download amd64 | AppImage (confirmed asset name): https://github.com/sqlitebrowser/sqlitebrowser/releases/download/v3.13.1/DB.Browser.for.SQLite-v3.13.1-x86.64-v2.AppImage |
| Download arm64 | No Linux arm64 AppImage in the release asset list. The `-arm64.zip` and `.msi` assets are Windows/other and do not apply. Use `apt:sqlitebrowser` on arm64 (UNVERIFIED arm64 build on the archive page, not checked per-arch). |
| Checksum source (amd64) | UNVERIFIED: no checksum or signature file in the release asset list. Pin the AppImage by SHA-256 computed at build time and record it in the Dockerfile with a comment, or find an upstream checksum before building. |
| Checksum source (apt) | Ubuntu archive signed metadata. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/linuxserver/docker-sqlitebrowser/07d24df2caea/Dockerfile: `FROM ghcr.io/linuxserver/baseimage-rdesktop-web:bionic`; installs `sqlitebrowser=${SQLITEB_VERSION}` from the linuxgndu PPA (bionic); `COPY /root /`; `EXPOSE 3000`; `VOLUME /config`. No env vars set. |
| Linuxserver image | `ghcr.io/linuxserver/sqlitebrowser:18.04.1`; Hub amd64 digest `sha256:31135df4aa664337dce1f57abd88a7e9fb61a576fad6e5987311ca8596d8a379` (https://hub.docker.com/v2/repositories/linuxserver/sqlitebrowser/tags/18.04.1). |
| Env vars (real) | None set by the upstream Dockerfile. |
| Ports | `EXPOSE 3000` upstream, the rdesktop-web UI. The draft's 3001 is not in upstream. Whether our image needs any port depends on section 10. |
| Data / config paths | `/config` (VOLUME). The SQLite files the user opens must be bind-mounted; the app cannot see paths outside its mounts. |
| Dependencies | None. |

## 2. Target layout

- `apps/sqlitebrowser/Dockerfile`
- `apps/sqlitebrowser/docker-bake.hcl`
- `apps/sqlitebrowser/settings.yaml`
- `apps/sqlitebrowser/container-test.yaml`
- `apps/sqlitebrowser/start.sh`

No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base). `etc/` only if the display stack needs a config file, with the reason recorded.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Ubuntu 26.04 is the base for every ContainerForge runtime image. The upstream bionic base and PPA are not reused. Closest sibling for the apt install pattern: `apps/adguardhome-sync` (prebuilt binary on ubuntu).

## 4. Dockerfile

Two install paths, selected by `TARGETARCH`:

1. `ARG VERSION=3.13.1`, `ARG TARGETARCH`, `ARG APPIMAGE_SHA256=<amd64 sha256, computed and recorded>`.
2. `USER root`.
3. amd64: download the AppImage to `/tmp/sqlitebrowser.AppImage`, verify the SHA-256, then extract it so no FUSE is needed at runtime: `./sqlitebrowser.AppImage --appimage-extract` (AppImages support this, UNVERIFIED for 3.13.1 on this base). Move `squashfs-root` to `/app/sqlitebrowser/` and link the binary to `/usr/local/bin/sqlitebrowser`.
4. arm64: `apt-get install -y --no-install-recommends sqlitebrowser=3.13.1-1` and check the version matches `VERSION` (dockerfile rule). Pin the exact package version. If the arm64 version differs, stop and record it.
5. Shared runtime packages needed by Qt (UNVERIFIED which ones are missing on resolute). Install only what the first run reports missing, and record each one.
6. `apt-get clean && rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*`.
7. License file: `/usr/share/licenses/sqlitebrowser/LICENSE` (MPL-2.0 and GPL-3.0 texts from the source repo, `LICENSE-MPL-2.0`, `LICENSE-GPL-3.0`).
8. Environment that moves state off read-only paths:
   `ENV XDG_CONFIG_HOME=/config/xdg XDG_CACHE_HOME=/tmp/cache XDG_RUNTIME_DIR=/tmp/runtime HOME=/config`.
9. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /
   EXPOSE <port chosen in section 10>
   VOLUME /config
   ```

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "sqlitebrowser" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=sqlitebrowser/sqlitebrowser versioning=semver
  default = "3.13.1"
}
variable "LICENSE" { default = "MPL-2.0 OR GPL-3.0-or-later" }
variable "SOURCE" { default = "https://github.com/sqlitebrowser/sqlitebrowser" }
```

Standard targets and default group copied from `apps/adguardhome-sync`. Check with `docker buildx bake --print`. `ARG VERSION` in the Dockerfile matches the bake default.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/sqlitebrowser/sqlitebrowser"
ports: []        # filled in from section 10
env: []          # none read by start.sh
volumes:
  - path: /config
    required: true
dependencies: []
```

Ports stay empty until section 10 settles the interface. Do not list the draft's 3000/3001 without a confirmed listener.

## 7. start.sh

Intended flow (to confirm during the build):
- `mkdir -p /config/xdg /tmp/cache /tmp/runtime` and `chmod 0700 /tmp/runtime`. No writes to `/app`.
- Start the display server chosen in section 10 on a fixed display number, then wait for its socket.
- Start the remote-access bridge from section 10, if one is used.
- `export DISPLAY=:99`, then `exec sqlitebrowser`. Qt may need `QT_QPA_PLATFORM=offscreen` only for headless use; that is UNVERIFIED for this app.
- Idempotent with empty `/config`: create directories only, seed nothing.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
filePaths:
  - /usr/local/bin/sqlitebrowser
  - /usr/share/licenses/sqlitebrowser/LICENSE
```

Add a `tcp` and `http` probe per port in `settings.yaml` once section 10 sets it. Test runs have no env vars and no mounted database, so the start path must work without either.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Config (`~/.config/sqlitebrowser`) | `XDG_CONFIG_HOME=/config/xdg`, `HOME=/config` |
| Cache and runtime sockets | `/tmp/cache`, `/tmp/runtime` |
| Linuxserver `/root` overlay and s6 init | Not carried over. Replaced by `start.sh` |
| AppImage self-extraction at runtime (FUSE) | Not used. The AppImage is extracted at build time |
| Draft's rdesktop-web UI | Not carried over. See section 10 |

Target user: `apps`. The TrueCharts values run as UID 0 with `readOnlyRootFilesystem: false`; the plan is non-root and read-only compatible, with no `privileged` and no extra capabilities.

## 10. Risks, caveats and open questions

- **Hard blocker: no headless mode.** sqlitebrowser is a Qt GUI and needs an X display. The upstream image provides one through rdesktop-web, which is not a ContainerForge base. Decide one of:
  - (a) Xvfb plus a VNC/web bridge. Package names and availability on resolute are UNVERIFIED.
  - (b) Run Qt offscreen with no UI. Not a valid deliverable for the chart's purpose.
  Recommended: (a), but do not build until the package list is verified.
- **AMD64 and ARM64 differ.** amd64 uses the 3.13.1 AppImage and arm64 uses the Ubuntu apt build, so the two architectures may ship different builds. Record the version seen on each and note any mismatch in the PR.
- **Checksum for the AppImage is UNVERIFIED.** The release has no signature or checksum file. Pin by a SHA-256 computed at build time and say so in the PR; do not claim an upstream checksum.
- **Data gotcha:** SQLite files are invisible unless bind-mounted. Document this in the PR and in the settings description.
- The draft's ports 3000 (inferred) and 3001 (inferred) are not confirmed. Upstream is `EXPOSE 3000`, which belongs to the rdesktop-web UI and does not carry over.
- Draft security expectations (UID 0, read-only off) are the chart's, not the image's. They are not to be copied.
- Blocker status: "no headless mode" and "display stack undecided" mean this is not ready for a build. Stop before section 4 until section 10(a) is verified.

## 11. Build and test steps

1. `cd apps/sqlitebrowser && docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name sqlitebrowser-probe --read-only --tmpfs /tmp -v sqlitebrowser-probe-config:/config sqlitebrowser:3.13.1`, then `docker logs -f sqlitebrowser-probe`.
   Expected readiness signal: UNVERIFIED. Once the display server is chosen, it is the display server's ready line plus the sqlitebrowser process still running with no fatal error.
4. `forgetool containers test --image sqlitebrowser:3.13.1 --config ./apps/sqlitebrowser/container-test.yaml`
5. Cleanup: `docker rm -f sqlitebrowser-probe; docker volume rm sqlitebrowser-probe-config`.
6. Arm64 only if an amd64 failure is arm64-specific.

## 12. PR checklist

- Branch: `feat/add-sqlitebrowser`. Commit and PR title: `feat(sqlitebrowser): add new container`.
- PR description: `🤖 This PR is AI generated.` in Notes. Use `.github/PULL_REQUEST_TEMPLATE.md` and check only the boxes that apply.
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (only they can sign). The `license/cla` check shows the status.
- Not tested: nothing built, nothing run, no display stack chosen, AppImage checksum not upstream. Say so in the PR. Do not check "Built container locally".
