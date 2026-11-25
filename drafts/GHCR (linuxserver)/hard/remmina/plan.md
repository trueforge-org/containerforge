# remmina — implementation plan
> Source: ./draft.md · Target: apps/remmina/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 1.4.43, taken from the Ubuntu archive: `remmina` 1.4.43+dfsg-0ubuntu0.26.04.2 (https://packages.ubuntu.com/resolute/remmina). The upstream GitHub "latest release" is v1.2.30 (2018-05-20, no assets) and is stale, so it is not the source. The linuxserver image tag `1.4.43` (Docker Hub) matches the same upstream line. |
| Renovate | UNVERIFIED: no renovate datasource was confirmed for an Ubuntu archive package. Choose one by checking how `apps/valkey` pins its apt version, then set it in `docker-bake.hcl`. |
| License | GPL-2.0 (GitHub API for FreeRDP/Remmina, `license.spdx_id`). |
| Source URL | https://github.com/FreeRDP/Remmina |
| Download / install | apt only. No release asset is published upstream. |
| Per-arch | amd64 and arm64 both via the Ubuntu archive. The arm64 package page was not checked separately (UNVERIFIED). |
| Checksum source | Ubuntu archive signed metadata (apt). Not fetched in this run. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/linuxserver/docker-remmina/9c34e90f8d44/Dockerfile: `FROM ghcr.io/linuxserver/baseimage-selkies:ubunturesolute`; apt installs `remmina` (pinned by build arg `REMMINA_RELEASE`), `librsvg2-common`, and plugins `exec`, `kiosk`, `kwallet`, `rdp`, `secret`, `spice`, `vnc`, `www`, `x2go`; `ENV TITLE=Remmina PIXELFLUX_WAYLAND=true`; `COPY /root /`; `EXPOSE 3001`; `VOLUME /config`. |
| Linuxserver image | `ghcr.io/linuxserver/remmina:1.4.43`; Hub amd64 digest `sha256:cede2f9fa868e20af73b103b0fa26e4fcd804e1c608985e00f3273fb826c3d51`, arm64 digest `sha256:bf18520fb8d58515194177786a1dedfef150142a9629aee52a700ee55b59f950` (https://hub.docker.com/v2/repositories/linuxserver/remmina/tags/1.4.43). |
| Env vars (real) | Only from the upstream Dockerfile: `TITLE`, `PIXELFLUX_WAYLAND`. The Selkies runtime variables are UNVERIFIED (not read from `baseimage-selkies`). |
| Ports | `EXPOSE 3001` upstream (the Selkies web UI). The draft's 3000 is not in upstream. Whether our image needs any port depends on the display stack chosen in section 10. |
| Data / config paths | `/config` (VOLUME). Remmina's own config directory under `$XDG_CONFIG_HOME` is UNVERIFIED. |
| Dependencies | None. |

## 2. Target layout

- `apps/remmina/Dockerfile`
- `apps/remmina/docker-bake.hcl`
- `apps/remmina/settings.yaml`
- `apps/remmina/container-test.yaml`
- `apps/remmina/start.sh`

No `root/` (reserved). No `defaults/` or `etc/` unless the display stack needs a config file, in which case add `etc/` and say why. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Ubuntu 26.04 (resolute) carries the Remmina package, so no runtime image is needed. The upstream `baseimage-selkies` is a linuxserver image, not a ContainerForge base, and is not reused. Closest sibling for the ubuntu-plus-apt pattern: `apps/adguardhome-sync`. The `apps/valkey` apt pin is the pattern for the version pin.

## 4. Dockerfile

1. `ARG VERSION=1.4.43`, with the bake default matching it (section 5).
2. `USER root`. Install in one layer, no recommends:
   `apt-get install -y --no-install-recommends remmina=${VERSION}+dfsg-0ubuntu0.26.04.2 remmina-plugin-rdp remmina-plugin-vnc librsvg2-common`. Pin the exact version and check it against `VERSION` (dockerfile rule). Add the display stack packages from section 10 once chosen, UNVERIFIED for names and availability on resolute.
3. `apt-get clean && rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*`.
4. Environment that moves state off read-only paths:
   `ENV XDG_CONFIG_HOME=/config/xdg XDG_CACHE_HOME=/tmp/cache XDG_RUNTIME_DIR=/tmp/runtime HOME=/config`.
5. License file: `/usr/share/licenses/remmina/LICENSE` (copy from the source tarball, or the package's copyright file, UNVERIFIED which is present in the package).
6. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /
   EXPOSE <port chosen in section 10>
   VOLUME /config
   ```
   `EXPOSE` is left open until section 10 is decided. Do not copy the upstream 3001 or the draft 3000 by default.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "remmina" }
variable "VERSION" {
  // renovate: <datasource chosen per section 1> depName=<package> versioning=loose
  default = "1.4.43"
}
variable "LICENSE" { default = "GPL-2.0-only" }
variable "SOURCE" { default = "https://github.com/FreeRDP/Remmina" }
```

Use the standard targets from `apps/adguardhome-sync`: `docker-metadata-action`, `image`, `image-local`, `image-all`, and `group "default" { targets = ["image-local"] }`. Check with `docker buildx bake --print`. The `LICENSE` value is `GPL-2.0-only` as the upstream license; confirm the exact SPDX id from the repo's COPYING file (UNVERIFIED, the GitHub API reported GPL-2.0).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/FreeRDP/Remmina"
ports: []        # filled in from section 10
env: []          # only vars start.sh reads; none confirmed yet
volumes:
  - path: /config
    required: true
dependencies: []
```

`ports` and `env` stay empty until section 10 settles the interface. Do not list the upstream `TITLE` or `PIXELFLUX_WAYLAND` vars, because the ContainerForge image does not read them.

## 7. start.sh

Intended flow (to confirm during the build):
- `mkdir -p /config/xdg/remmina /tmp/cache /tmp/runtime` and `chmod 0700 /tmp/runtime`. No writes to `/app`.
- Start the display server chosen in section 10 on a fixed display number, for example `Xvfb :99 -screen 0 <geometry> &`, then wait until the socket exists.
- Start the remote-access bridge from section 10, if one is used.
- `export DISPLAY=:99`, then `exec remmina` (or the wrapper that runs it, UNVERIFIED whether remmina needs a session D-Bus; if it does, start `dbus-run-session` first).
- Idempotent with an empty `/config`: create directories only, seed nothing.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
filePaths:
  - /usr/bin/remmina
  - /usr/share/licenses/remmina/LICENSE
```

Add a `tcp` and `http` probe for each port in `settings.yaml` once section 10 sets it. Test runs have no env vars, so the start path has to work without any.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Remmina config, profiles and secrets (under `$HOME`/`$XDG_CONFIG_HOME`) | `XDG_CONFIG_HOME=/config/xdg`, `HOME=/config` |
| Cache and runtime sockets | `/tmp/cache` and `/tmp/runtime` via `XDG_CACHE_HOME`/`XDG_RUNTIME_DIR` |
| Linuxserver `/root` overlay, s6 init (`/etc/s6-overlay`) | Not carried over. Replaced by `start.sh` |
| Selkies web desktop (`/usr/share/selkies`) | Not carried over. See section 10 |

Target user: `apps` (UID set by the base). The upstream TrueCharts values run as UID 0 with `readOnlyRootFilesystem: false` (draft). The plan is non-root and read-only compatible. No `privileged`, no extra capabilities.

## 10. Risks, caveats and open questions

- **Hard blocker: no headless mode.** Remmina is a GTK client and needs an X display to start. The linuxserver image provides one through the Selkies web stack, which is a different base and is not a ContainerForge base. Decide one of:
  - (a) Xvfb plus a VNC/web bridge (for example x11vnc and noVNC). Package names and availability on resolute are UNVERIFIED.
  - (b) Use Remmina only as a client library with no GUI. Not a valid deliverable for the chart's purpose.
  Recommended: (a), but do not build until the package list is verified.
- Chosen port(s) and the display server must be recorded in `settings.yaml` and `container-test.yaml` before any test is written.
- The draft's ports 3000 and 3001 are both inferred. Upstream has only `EXPOSE 3001` for the Selkies UI, which does not carry over.
- Remmina is a client: it needs network reach to the RDP or VNC targets it connects to. This is outside the container.
- Secret storage: the `secret` and `kwallet` plugins need a keyring or D-Bus. Only `secret` was in the upstream list; the plan keeps `secret` out until it is verified to work without a session bus (UNVERIFIED).
- Draft security expectations (UID 0, read-only off) are the chart's, not the image's. They are not to be copied.
- Blocker status: "no headless mode" and "display stack undecided" mean this is not ready for a build. Stop before section 4 until section 10(a) is verified.

## 11. Build and test steps

1. `cd apps/remmina && docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker run --rm -d --name remmina-probe --read-only --tmpfs /tmp -v remmina-probe-config:/config remmina:1.4.43`, then `docker logs -f remmina-probe`.
   Expected readiness signal: UNVERIFIED. Once the display server is chosen, it is the display server's ready line plus the remmina process still running with no fatal error.
4. `forgetool containers test --image remmina:1.4.43 --config ./apps/remmina/container-test.yaml`
5. Cleanup: `docker rm -f remmina-probe; docker volume rm remmina-probe-config`.
6. Arm64 only if an amd64 failure is arm64-specific.

## 12. PR checklist

- Branch: `feat/add-remmina`. Commit and PR title: `feat(remmina): add new container`.
- PR description: `🤖 This PR is AI generated.` in Notes. Use `.github/PULL_REQUEST_TEMPLATE.md` and check only the boxes that apply.
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (only they can sign). The `license/cla` check shows the status.
- Not tested: nothing built, nothing run, no display stack chosen. Say so in the PR. Do not check "Built container locally".
