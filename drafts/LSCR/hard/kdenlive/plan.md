# kdenlive — implementation plan
> Source: ./draft.md · Target: apps/kdenlive/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Ubuntu 26.04 (resolute) archive package `kdenlive` 4:25.12.3-0ubuntu1.1 on amd64 and arm64 (https://packages.ubuntu.com/resolute/kdenlive). Upstream release/tag: UNVERIFIED (not fetched in this run). |
| Difference from draft | The draft's Ubuntu archive route is confirmed. The upstream linuxserver image is NOT Ubuntu: it is built on `ghcr.io/linuxserver/baseimage-selkies:arch` (Arch Linux) and installs kdenlive with `pacman -Sy --noconfirm --needed kdenlive` (upstream Dockerfile at https://raw.githubusercontent.com/linuxserver/docker-kdenlive/f39884e7d1d55d31dd0babb973c1cb0ea066d84f/Dockerfile). The linuxserver image cannot be copied from (`COPY --from`) and is not used as a base. |
| Renovate | apt-managed; no Renovate datasource for the app itself. Pin the apt version and check it against the image's intent (UNVERIFIED how the repo tracks apt pins; see section 4). |
| License | UNVERIFIED (not fetched). KDE Kdenlive is GPL per the source repo; confirm from https://github.com/KDE/kdenlive before setting `LICENSE`. |
| Source URL | https://github.com/KDE/kdenlive (from draft) |
| Download | apt only: `kdenlive` from the Ubuntu archive. No release binary is used. |
| Checksum source | apt signed repository metadata (Ubuntu archive signatures). |
| Upstream Dockerfile reviewed | linuxserver `docker-kdenlive` Dockerfile at commit `f39884e7d1d55d31dd0babb973c1cb0ea066d84f`: one base `ghcr.io/linuxserver/baseimage-selkies:arch`, `curl` of a Kdenlive icon, `pacman` install of `kdenlive` (optional pin via `KDENLIVE_VERSION`), `COPY /root /`. ENTRYPOINT, CMD and USER are UNVERIFIED (not present in the file; inherited from the base). |
| Port | 3001 (EXPOSE in the upstream Dockerfile, the selkies web UI over TLS). The draft's 3000/http is UNVERIFIED on the upstream image; the Dockerfile confirms 3001 only. |
| Env vars (real) | `TITLE=Kdenlive`, `NO_GAMEPAD=true`, `PIXELFLUX_WAYLAND=true` (upstream Dockerfile). Other env the selkies base reads: UNVERIFIED. |
| Data path | `/config` (upstream `VOLUME /config`). |
| Ubuntu packages | `melt` and `frei0r-plugins` are inferred from the draft and UNVERIFIED against the Ubuntu archive. |

## 2. Target layout

- `apps/kdenlive/Dockerfile`
- `apps/kdenlive/docker-bake.hcl`
- `apps/kdenlive/settings.yaml`
- `apps/kdenlive/container-test.yaml`
- `apps/kdenlive/start.sh` (starts the desktop session and kdenlive, see section 7)
- `apps/kdenlive/etc/` or `defaults/` only if the desktop session needs a config file seeded into `/config` (decide during build; UNVERIFIED need)

No `root/` (never used). No `DOWNSTREAM_CHANGES.md`: not a `FROM` base.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. Ubuntu carries the kdenlive package for both arches. The draft's "runtime image: none" is confirmed. Closest siblings for a desktop image: `apps/kasmvnc` and `apps/rdesktop` (both ship a `root/` tree, which this plan must not copy: use `etc/` or `defaults/` instead). The linuxserver selkies base is NOT an option: it is Arch-based.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. `apt-get update && apt-get install -y --no-install-recommends kdenlive melt frei0r-plugins ffmpeg` (melt, frei0r-plugins and ffmpeg are inferred from the draft; confirm each against the archive). Pin `kdenlive=4:25.12.3-0ubuntu1.1` and check that pin against `VERSION` as `apps/valkey` does (the version in the bake file must match the pin).
3. Desktop/display stack: the chart expects a browser-accessed desktop. The upstream selkies base is Arch and is not available. The Ubuntu route needs a display server and a web streaming layer (VNC or selkies-style). This is an OPEN DESIGN QUESTION (see section 10), not resolved by this plan. Do not invent it: pick the approach used by `apps/kasmvnc` or `apps/rdesktop` after reading them.
4. License: copy kdenlive's `COPYING` (or the Ubuntu `/usr/share/doc/kdenlive/copyright`) into `/usr/share/licenses/kdenlive/`.
5. Cleanup: `rm -rf /tmp/* /var/lib/apt/lists/*`.
6. Environment: `ENV HOME=/config TITLE=Kdenlive NO_GAMEPAD=true`.
7. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /
WORKDIR /config

EXPOSE 3001
VOLUME /config
```

`PIXELFLUX_WAYLAND` is a selkies setting: include it only when the chosen streaming layer reads it (UNVERIFIED).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "kdenlive"
}

variable "VERSION" {
  // renovate: datasource=... depName=... (none confirmed; the version is an apt pin, see section 10)
  default = "25.12.3"
}

variable "LICENSE" {
  default = "UNVERIFIED"   # set from KDE Kdenlive's license (not fetched)
}

variable "SOURCE" {
  default = "https://github.com/KDE/kdenlive"
}

group "default" {
  targets = ["image-local"]
}

# image, image-local, image-all copied from apps/bazarr/docker-bake.hcl
```

`VERSION` must equal the apt pin in the Dockerfile. The renovate annotation is UNVERIFIED: no datasource is confirmed for an Ubuntu apt pin. Check how the repo tracks apt pins in `apps/valkey` before choosing one; do not invent a datasource. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/KDE/kdenlive"
ports:
  - port: 3001
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: TITLE
    default: "Kdenlive"
    required: false
  - name: NO_GAMEPAD
    default: "true"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Port 3001 is confirmed by the upstream EXPOSE only. Add `3000` only if the chosen streaming layer confirms it. `TITLE` and `NO_GAMEPAD` are confirmed upstream env; they only belong here if the Ubuntu port reads them (UNVERIFIED for the new stack). No dependencies.

## 7. start.sh

Plan only. The shape depends on the desktop stack (open question, section 10). Required properties regardless of the stack:

- `mkdir -p /config` and seed nothing unless a file is missing (idempotent, `/config` may be empty).
- Writes only to `/config` and `/tmp`, never `/app`.
- Read `TITLE`, `NO_GAMEPAD` from the environment with defaults matching `settings.yaml`.
- Bind the web listener to `0.0.0.0` on port 3001.
- End with `exec` of the final long-running process.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
- port: '3001'
http:
- port: '3001'
  path: /
  scheme: https
filePaths:
- /usr/bin/kdenlive
- /usr/bin/melt
- /usr/share/licenses/kdenlive/COPYING
```

`scheme` and `timeoutSeconds` are estimates; check the forgetool schema for the http field names and the timeout a desktop app needs (sibling `apps/kasmvnc`). The test runs with no env vars and no GPU, so hardware-encode paths are not tested (note this in the PR).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Kdenlive project and settings (`~/.config`, `~/.local`) | `HOME=/config` |
| Desktop session runtime (`XDG_RUNTIME_DIR`) | `/tmp/runtime-apps` (mode 0700, created at start) |
| Caches (`~/.cache`) | `/tmp` via `XDG_CACHE_HOME=/tmp/cache` |
| Render scratch | `/tmp` or a `/config` subfolder chosen by the user (UNVERIFIED size needs) |

The draft expectations: chart runs as UID 0 with `readOnlyRootFilesystem: false`, not privileged. This image runs as `apps` and should work with `--read-only --tmpfs /tmp` once the remaps above are in place. Hardware encode needs `/dev/dri` passthrough, which the chart does not set (draft caveat, UNVERIFIED for this stack).

## 10. Risks, caveats and open questions

- OPEN BLOCKER: the desktop and streaming layer. The upstream selkies base is Arch-only and not usable. The Ubuntu route needs a display server plus a web streaming layer (VNC, or selkies packaged for Ubuntu). This decides `start.sh`, the ports and the test. Decide before building; do not copy the selkies Arch image.
- Ubuntu package names `melt`, `frei0r-plugins`, `ffmpeg` are inferred, UNVERIFIED against the archive.
- Upstream release/tag and license are UNVERIFIED.
- arm64 kdenlive comes from the Ubuntu archive and may lag upstream (draft caveat, confirmed the arm64 build exists at 25.12.3).
- Video editing and rendering need substantial CPU, RAM and scratch disk (draft caveat).
- Hardware encode or decode needs device passthrough the chart does not set (draft caveat).
- Difficulty: hard. This is a desktop GUI with a display session, which the rest of ContainerForge does not yet have in one place.

## 11. Build and test steps

```sh
cd apps/kdenlive
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name kdenlive-probe --read-only --tmpfs /tmp \
  -v kdenlive-probe-config:/config kdenlive:25.12.3
docker logs -f kdenlive-probe
forgetool containers test --image kdenlive:25.12.3 --config ./apps/kdenlive/container-test.yaml
docker rm -f kdenlive-probe; docker volume rm kdenlive-probe-config
```

Readiness signal: the web streaming layer's listening line on port 3001 (exact text depends on the open stack decision; UNVERIFIED). Run an arm64 build only if the amd64 one fails on an arm64-specific cause.

## 12. PR checklist

- Branch `feat/add-kdenlive`, commit and PR title `feat(kdenlive): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA notice: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows status.
- Untested, to state honestly: the desktop session and streaming in a browser, hardware encode, arm64 runtime, the render path, and the port and probe choice.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile apt pin; no assertion weakened.
