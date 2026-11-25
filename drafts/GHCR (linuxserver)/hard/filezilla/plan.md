# filezilla — implementation plan
> Source: ./draft.md · Target: apps/filezilla/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | 3.69.6 (Ubuntu 26.04 "resolute" archive package `3.69.6-1`, section universe). Source: https://packages.ubuntu.com/resolute/filezilla. Upstream release page (filezilla-project.org) not fetched: UNVERIFIED as the latest upstream release. |
| linuxserver tag in draft | `ghcr.io/linuxserver/filezilla:3.69.6` (tag not verified against a ghcr listing). Upstream Dockerfile: https://raw.githubusercontent.com/linuxserver/docker-filezilla/ad89ad1bdd0f2bad2d7dd8a68a3f989c3449949f/Dockerfile |
| Renovate | UNVERIFIED: not fetched. The app is installed from apt, so there is no release asset to track; choose a renovate pattern from a sibling that pins an apt package (`apps/valkey` is the precedent for a pinned apt version). |
| License | UNVERIFIED: the Ubuntu package page does not state the license (it links to a copyright file). The upstream FileZilla license is expected to be GPL-2.0-or-later, but this was NOT confirmed on a fetched page. Confirm with the package copyright file before setting `LICENSE`. |
| Source URL | https://filezilla-project.org (docs https://wiki.filezilla-project.org/Documentation) |
| Download / install | apt package `filezilla` pinned to `3.69.6-1` on ubuntu resolute. Architectures: amd64 and arm64 both listed (https://packages.ubuntu.com/resolute/filezilla). No separate download URL. |
| Checksum source | apt repository signature (Ubuntu archive). Not separately fetched. |
| Upstream Dockerfile reviewed | `FROM ghcr.io/linuxserver/baseimage-selkies:ubunturesolute`; `apt-get install --no-install-recommends filezilla${FILEZILLA_VERSION:+=$FILEZILLA_VERSION}` (pin via build arg); `EXPOSE 3001`; `VOLUME /config`; env `TITLE=Filezilla`, `NO_GAMEPAD=true`, `PIXELFLUX_WAYLAND=true`; icon from `raw.githubusercontent.com/linuxserver/docker-templates/...`; cleanup removes `/config/.cache` and `/config/.launchpadlib`; no USER (base default). |
| Upstream base env (partial) | From the selkies README summary (https://raw.githubusercontent.com/linuxserver/docker-digikam/fd0663bebb867b7dba24c63d14e0493e7d94c0b9/README.md, same base family): `PUID`, `PGID`, `TZ`, `UMASK`, `CUSTOM_USER`, `PASSWORD`; ports 3000 (http, proxy it) and 3001 (https). Architecture: amd64 only (aarch64 dropped 25.11.24). This contradicts the Ubuntu arm64 package for FileZilla, which is a base-image limit, not an app limit. |

## 2. Target layout

- `apps/filezilla/Dockerfile`
- `apps/filezilla/docker-bake.hcl`
- `apps/filezilla/settings.yaml`
- `apps/filezilla/container-test.yaml`
- `apps/filezilla/start.sh`

No `defaults/` (no seed config is confirmed). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`, single stage.

Why: the app is one apt package on Ubuntu 26.04, which matches the base. Closest sibling for a display-based app on ubuntu: `apps/xvfb` (apt install of a display package, `USER apps`, `COPY --chmod=0755 . /`). The Selkies base is NOT used (no ContainerForge equivalent, runs as root; see section 10).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`, `ENV HOME=/config TZ=Etc/UTC`.
2. Install the pinned package, with no recommends:
   ```dockerfile
   RUN apt-get update && \
     apt-get install -y --no-install-recommends filezilla=${VERSION}-1 && \
     apt-get clean && rm -rf /var/lib/apt/lists/*
   ```
   Pin the version to the bake `VERSION` (`3.69.6`) and the full package version (`3.69.6-1`). If the bake and the package version are kept as separate values, the Dockerfile must still fail when they disagree; add a check `dpkg -s filezilla | grep -q "^Version: ${VERSION}-"`.
3. The upstream `FILEZILLA_VERSION` build-arg pattern is replaced by the fixed pin above; do not keep an optional unpinned install.
4. Licenses: copy the package copyright file to `/usr/share/licenses/filezilla/` (`cp /usr/share/doc/filezilla/copyright /usr/share/licenses/filezilla/LICENSE`; confirm the path on the first build).
5. Permissions: the binary is a system package in `/usr/bin`, so nothing under `/app` is needed. Create `/app` empty only if the Dockerfile convention requires it (check `apps/xvfb`, which has no `/app` content).
6. Tail:
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
  default = "filezilla"
}

variable "VERSION" {
  // renovate: UNVERIFIED datasource for an apt package pin (see section 1); pin to the Ubuntu archive version
  default = "3.69.6"
}

variable "LICENSE" {
  default = "UNVERIFIED"
}

variable "SOURCE" {
  default = "https://filezilla-project.org"
}
```

`LICENSE` must not be set until the copyright file confirms it. Then the standard `image`, `image-local`, `image-all` and `default` group, copied from `apps/adguardhome-sync`. `image-all` may list `linux/amd64` and `linux/arm64`, because the apt package lists both (the base image's arm64 status still gates it, section 10). Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://filezilla-project.org"
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

Ports are open (section 10, blocker 1). Dependencies: none. Env: only what `start.sh` or the display stack reads. Do not declare the upstream `TITLE`, `NO_GAMEPAD` or `PIXELFLUX_WAYLAND` unless the chosen stack uses them.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/filezilla /tmp/cache

export HOME=/config XDG_CONFIG_HOME=/config XDG_CACHE_HOME=/tmp/cache
exec filezilla
```

Rules: idempotent, seeds nothing, never writes under `/app`. FileZilla stores site list and settings under `~/.config/filezilla` (UNVERIFIED on first run); `XDG_CONFIG_HOME=/config` keeps them in the persistent volume. The draft says credentials are saved under `/config`; confirm that FileZilla's site manager writes there and note the file (sensitive: must persist, must not be logged). The display stack must start first, in the same script, with `filezilla` in the foreground (`exec` only for the last process). Bind any server to `0.0.0.0`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120   # UNVERIFIED: take the value from the sibling chosen in section 3
tcp:
- port: '3000'        # one tcp probe per port listed in settings.yaml
filePaths:
- /usr/bin/filezilla
- /usr/share/licenses/filezilla/LICENSE
```

Every port in `settings.yaml` gets a `tcp` probe. The test runs without env vars, the normal start path. `filePaths` checks the binary from the package and the license file.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/config` (volume; saved sites and settings) | `HOME=/config`, `XDG_CONFIG_HOME=/config` (persistent, required) |
| `/config/.cache`, `/config/.launchpadlib` (removed by upstream cleanup) | `XDG_CACHE_HOME=/tmp/cache`; no launchpad cache is needed |
| `/tmp`, `/var/tmp`, apt lists | `/tmp` tmpfs under the protocol; apt lists removed in the same layer |
| Icon download to `/usr/share/selkies/www/icon.png` | Not needed (no web UI of our own). Drop it. |
| X and desktop sockets | `/tmp/.X11-unix` on tmpfs (UNVERIFIED that the chosen stack needs nothing else) |

Security reconciliation (draft expectations to verify, not to copy):
- non-root: target `USER apps`. The chart's `runAsUser 0` is not a requirement for us.
- read-only rootfs: target yes; the draft says no (chart value).
- privileged: no. Add no capabilities.
- extra persistence: `/config` only. Saved FTP credentials are stored there and need the volume to persist. Protect them with the volume's permissions; do not write them into the image or logs.

## 10. Risks, caveats and open questions

- **Blocker 1 (decision needed): display stack.** FileZilla is a GUI client. The upstream image provides it through a Selkies browser desktop, which ContainerForge does not have. Options: (a) Xvfb plus a remote-desktop server, following `apps/kasmvnc` and `apps/xvfb` (copy the pattern only; kasmvnc's `root/` tree is not used here). (b) Defer until a desktop base exists. Nothing should be built until this is chosen, because ports, probes and readiness depend on it.
- **Credentials at rest:** saved site passwords are stored by FileZilla under `/config`. Document that the volume holds secrets. Do not log them or add them to `settings.yaml` defaults.
- **Blocker 2: base arm64.** The Ubuntu package exists for arm64, but the linuxserver base dropped aarch64. Our base is Ubuntu 26.04 (`ghcr.io/trueforge-org/ubuntu`); arm64 is UNVERIFIED until built. Try an arm64 build before claiming support; if it is not built, say so in the PR.
- **License unknown:** do not set `LICENSE` until the copyright file is read. Upstream is expected to be GPL-2.0-or-later (UNVERIFIED).
- **Version source:** the draft's `3.69.6` matches the Ubuntu archive package; the upstream release page was not fetched, so the "latest upstream" claim is UNVERIFIED.
- **Renovate:** no datasource confirmed; the apt pin will need a manual or custom renovate rule.

## 11. Build and test steps

From `apps/filezilla/`:

1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. Run on read-only rootfs with an empty volume:
   ```sh
   docker volume create filezilla-probe-config
   docker run --rm -d --name filezilla-probe --read-only --tmpfs /tmp \
     -v filezilla-probe-config:/config filezilla:3.69.6
   docker logs -f filezilla-probe
   ```
   Expected readiness signal: UNVERIFIED until the display stack is chosen. Fail on any fatal line or an exit.
4. `forgetool containers test --image filezilla:3.69.6 --config ./apps/filezilla/container-test.yaml`
5. Clean up: `docker rm -f filezilla-probe; docker volume rm filezilla-probe-config`.

## 12. PR checklist

- Branch `feat/add-filezilla`, commit `feat(filezilla): add new container`, PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; the `license/cla` check shows status).
- Say what was not tested: arm64 not built or run; GUI behaviour and readiness not verified unless step 3 was done; license not confirmed from the copyright file; upstream release page not checked.
- Do not check "Built container locally" unless steps 2 and 4 actually ran.
