# doublecommander — implementation plan
> Source: ./draft.md · Target: apps/doublecommander/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v1.2.11, published 2026-11-08T09:20:40Z. Source: https://api.github.com/repos/doublecmd/doublecmd/releases/latest |
| linuxserver tag in draft | `ghcr.io/linuxserver/doublecommander:latest` (tag/version not verified; no ghcr tag listing fetched). Upstream Dockerfile: https://raw.githubusercontent.com/linuxserver/docker-doublecommander/05e15297277457b38b1c99c2207185cf73873f15/Dockerfile |
| Renovate | UNVERIFIED: not fetched. Expected pattern: `datasource=github-releases depName=doublecmd/doublecmd versioning=semver` (confirm the tag format `v1.2.11` strips to `1.2.11` in the URLs). |
| License | GPL-2.0 (`doublecmd/doublecmd`, GitHub SPDX). linuxserver wrapper: GPL-3.0 (not shipped as the app license). |
| Source URL | https://github.com/doublecmd/doublecmd (docs https://doublecmd.github.io/doc/en/help.html, site https://doublecmd.sourceforge.io) |
| Download (amd64, gtk2) | https://github.com/doublecmd/doublecmd/releases/download/v1.2.11/doublecmd-1.2.11.gtk2.x86_64.tar.xz |
| Download (arm64, gtk2) | https://github.com/doublecmd/doublecmd/releases/download/v1.2.11/doublecmd-1.2.11.gtk2.aarch64.tar.xz |
| Other variants (confirmed assets) | `qt6.x86_64.tar.xz`, `qt6.aarch64.tar.xz`, `qt.*`, `gtk2.i386`, plus Windows/macOS builds. Pick one GUI toolkit only. |
| Checksum source | UNVERIFIED: no checksum or digest asset in the v1.2.11 release. Only the version pin and HTTPS protect integrity. |
| Upstream Dockerfile reviewed | `FROM ghcr.io/linuxserver/baseimage-selkies:debiantrixie`; `apt-get install -y doublecmd-gtk doublecmd-plugins` (Debian trixie repo, version not pinned; `ARG DOUBLECOMMANDER_VERSION` is unused); extra apt packages `arj libsmbclient libssh2-1 libunrar5 p7zip-full unace xz-utils zpaq`; icon from `raw.githubusercontent.com/linuxserver/docker-templates/...`; EXPOSE 3001; VOLUME `/config`; no USER (base default); env `TITLE=DoubleCommander`, `NO_GAMEPAD=true`, `PIXELFLUX_WAYLAND=true`. |
| Upstream base env (partial) | From the selkies README summary (https://raw.githubusercontent.com/linuxserver/docker-digikam/fd0663bebb867b7dba24c63d14e0493e7d94c0b9/README.md, same base family): `PUID`, `PGID`, `TZ`, `UMASK`, `CUSTOM_USER`, `PASSWORD`; ports 3000 (http, proxy it) and 3001 (https). Architecture: amd64 only (aarch64 dropped 25.11.24). |

## 2. Target layout

- `apps/doublecommander/Dockerfile`
- `apps/doublecommander/docker-bake.hcl`
- `apps/doublecommander/settings.yaml`
- `apps/doublecommander/container-test.yaml`
- `apps/doublecommander/start.sh`

No `defaults/` or `etc/` unless a seed config is needed (none is confirmed). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`, single stage.

Why: the release is a prebuilt tarball, so no compiler is needed. Ubuntu is the ContainerForge base for generic userland. Closest sibling for tarball-plus-apt on ubuntu: `apps/adguardhome-sync` (tarball download by `$TARGETARCH`) and `apps/xvfb` (display server on ubuntu). The upstream Debian trixie package set is not used (the base is Ubuntu 26.04).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`, `ENV HOME=/config TZ=Etc/UTC`.
2. Map the arch to the upstream asset name (confirmed names only):
   ```dockerfile
   RUN case "$TARGETARCH" in \
       amd64) DC_ARCH=x86_64 ;; \
       arm64) DC_ARCH=aarch64 ;; \
       *) echo "unsupported $TARGETARCH" && exit 1 ;; \
     esac && \
     curl -fL -o /tmp/doublecmd.tar.xz \
       "https://github.com/doublecmd/doublecmd/releases/download/v${VERSION}/doublecmd-${VERSION}.gtk2.${DC_ARCH}.tar.xz"
   ```
3. Extract into `/app/doublecommander`: `mkdir -p /app/doublecommander && tar -xJf /tmp/doublecmd.tar.xz -C /app/doublecommander --strip-components=1` (confirm the archive's top-level folder name on the first build; adjust `--strip-components`).
4. Install runtime libraries the binary needs, pinned or as the base allows. Start with the upstream extra list (`libsmbclient libssh2-1 libunrar5 p7zip-full xz-utils`); drop `unace`, `zpaq` and `arj` if the Ubuntu archive does not have them (UNVERIFIED availability on Ubuntu 26.04). Do NOT install `doublecmd-gtk` from Debian (wrong distro). Check the tarball's shared-library needs with `ldd` on the extracted binary, and install only what is missing.
5. Licenses: ship the upstream license file to `/usr/share/licenses/doublecommander/` (exact file name inside the tarball UNVERIFIED; find it during the build and fail if missing).
6. Cleanup: `rm -f /tmp/doublecmd.tar.xz`, `apt-get clean`, `rm -rf /var/lib/apt/lists/*`.
7. `chown -R apps:apps /app/doublecommander && chmod -R 755 /app/doublecommander`.
8. Tail:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /
   EXPOSE <ports from section 6>
   VOLUME /config
   ```

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "doublecommander"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=doublecmd/doublecmd versioning=semver
  default = "1.2.11"
}

variable "LICENSE" {
  default = "GPL-2.0"
}

variable "SOURCE" {
  default = "https://github.com/doublecmd/doublecmd"
}
```

Then the standard `image`, `image-local`, `image-all` (amd64 and arm64, both assets confirmed) and `default` group, copied from `apps/adguardhome-sync`. `VERSION` is `1.2.11` (no `v`), matching the Dockerfile `ARG`; the URLs add the `v` prefix. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/doublecmd/doublecmd"
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

Ports are open (section 10, blocker 1). Dependencies: none. Env: only variables that `start.sh` or the display stack really read. The upstream `TITLE`, `NO_GAMEPAD` and `PIXELFLUX_WAYLAND` belong to the Selkies base and are not declared unless the chosen stack uses them.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/doublecommander /tmp/cache

export XDG_CONFIG_HOME=/config XDG_CACHE_HOME=/tmp/cache
cd /app/doublecommander
exec ./doublecmd
```

Rules: idempotent, seeds nothing, never writes under `/app`. Double Commander keeps its configuration under the user's config directory; `XDG_CONFIG_HOME=/config` makes that persistent (UNVERIFIED: confirm the exact directory name the binary creates on first run and that it honours `XDG_CONFIG_HOME`). The display stack must be started first, in the same script, with the GUI process in the foreground. Bind servers to `0.0.0.0`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120   # UNVERIFIED: take the value from the sibling chosen in section 3
tcp:
- port: '3000'        # one tcp probe per port listed in settings.yaml
filePaths:
- /app/doublecommander/doublecmd
- /usr/share/licenses/doublecommander
```

Every port in `settings.yaml` gets a `tcp` probe. No env-dependent code path is known. The test runs without env vars, which is the normal start path here.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/config` (persistent home; upstream declares it as a volume) | `HOME=/config`, `XDG_CONFIG_HOME=/config` |
| `/tmp`, `/var/tmp`, apt lists (cleaned by upstream) | `/tmp` tmpfs under the protocol; apt lists removed in the same layer |
| `/usr/share/selkies/www/icon.png` (upstream icon download) | Not needed: the image has no web UI of its own. Drop it; do not copy the linuxserver icon. |
| Package install locations | Build-time only (`/usr`), read-only at runtime |
| X and desktop sockets | `/tmp/.X11-unix` on tmpfs (UNVERIFIED that the chosen stack needs nothing else) |

Security reconciliation (draft expectations to verify, not to copy):
- non-root: target is `USER apps`. The chart's `runAsUser 0` is not a requirement for us.
- read-only rootfs: target yes; the draft says no (chart value). Achieved by keeping writes to `/config` and `/tmp`.
- capabilities: the chart adds `SYS_CHROOT`, `KILL`, `NET_BIND_SERVICE` plus the common root caps. Target: none added. `NET_BIND_SERVICE` is unnecessary because the GUI does not bind a privileged port.
- privileged: no.
- extra persistence: none beyond `/config`. The user's browsed paths come from host mounts chosen by the user; they are not part of the image.

## 10. Risks, caveats and open questions

- **Blocker 1 (decision needed): display stack.** Double Commander is a GUI program, and the upstream image provides it through a Selkies browser desktop. ContainerForge has no equivalent base. Options: (a) Xvfb plus a remote-desktop server, following `apps/kasmvnc` and `apps/xvfb` (copy the pattern only; kasmvnc uses a `root/` tree this plan does not use). (b) Defer until a desktop base exists. Nothing should be built until one is chosen, because the ports, probes and readiness signal depend on it.
- **Headless use is pointless.** The app only helps when host paths are mounted. The image sees only what the user mounts; document this in the app notes.
- **No checksum upstream.** Integrity rests on the pinned version over HTTPS.
- **Blocker 2: arm64 UNVERIFIED at runtime.** Assets exist for both arches, but the GUI stack for arm64 is unverified.
- **Library availability:** `unace`, `zpaq` and `arj` on Ubuntu 26.04 UNVERIFIED; drop them if absent and note the lost archive formats.
- **Version drift:** the draft's `ghcr.io/linuxserver/doublecommander:latest` is not a pinned version. The plan pins 1.2.11 from the upstream release, not the linuxserver tag.
- **License:** upstream GPL-2.0 (GitHub SPDX). Confirm against the tarball's license file (UNVERIFIED).

## 11. Build and test steps

From `apps/doublecommander/`:

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Run on read-only rootfs with an empty volume:
   ```sh
   docker volume create doublecommander-probe-config
   docker run --rm -d --name doublecommander-probe --read-only --tmpfs /tmp \
     -v doublecommander-probe-config:/config doublecommander:1.2.11
   docker logs -f doublecommander-probe
   ```
   Expected readiness signal: UNVERIFIED until the display stack is chosen. Fail on any fatal line or an exit.
4. `forgetool containers test --image doublecommander:1.2.11 --config ./apps/doublecommander/container-test.yaml`
5. Clean up: `docker rm -f doublecommander-probe; docker volume rm doublecommander-probe-config`.

## 12. PR checklist

- Branch `feat/add-doublecommander`, commit `feat(doublecommander): add new container`, PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows status).
- Say what was not tested: arm64 not built or run; GUI behaviour and readiness not verified unless step 3 was done; no upstream checksum to compare against; Ubuntu package availability for the optional archive tools unverified.
- Do not check "Built container locally" unless steps 2 and 4 actually ran.
