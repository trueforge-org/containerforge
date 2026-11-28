# handbrake — implementation plan
> Source: ./draft.md · Target: apps/handbrake/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Draft container | `ghcr.io/jlesage/handbrake:v26.09.1` (upstream image, not TrueCharts-owned) |
| Upstream Dockerfile | https://raw.githubusercontent.com/jlesage/docker-handbrake/v26.09.1/Dockerfile (fetched) |
| Upstream base | `jlesage/baseimage-gui:alpine-3.20-v4.14.0`, Alpine/musl, so its binaries cannot be copied onto glibc Ubuntu |
| Upstream build | Two Alpine 3.20 build stages (`handbrake`, `cpu_features`) using `/build/build.sh`, then the GUI base image |
| Upstream packages | 31 Alpine packages via `add-pkg` (gtk4.0, gst-plugins-good, gst-libav, x264-libs, libvpx, libdvdcss, pciutils, bash, expect, xdpyinfo, ...) |
| Upstream volumes | `/storage`, `/output`, `/watch`, `/trash` |
| Upstream env (selection) | `HANDBRAKE_GUI=1`, `DISABLE_GLX=1`, `AUTOMATED_CONVERSION=1`, `AUTOMATED_CONVERSION_WATCH_DIR=AUTO`, `AUTOMATED_CONVERSION_OUTPUT_DIR=/output`, `AUTOMATED_CONVERSION_PRESET="General/Very Fast 1080p30"`, `AUTOMATED_CONVERSION_FORMAT=mp4`, `AUTOMATED_CONVERSION_TRASH_DIR=/trash`, `AUTOMATED_CONVERSION_CHECK_INTERVAL=5` |
| Upstream ARG | `HANDBRAKE_VERSION=1.11.2`, source tarball URL built from it |
| Upstream USER / ENTRYPOINT / EXPOSE | Not set in this Dockerfile (inherited from baseimage-gui) |
| Latest stable HandBrake | Tag `1.11.2`, published 2026-06-07, not a prerelease (GitHub API, `gh api repos/HandBrake/HandBrake/releases/latest`) |
| Linux assets for 1.11.2 | Only `HandBrake-1.11.2-source.tar.bz2` (+ `.sig`) and `HandBrake-1.11.2-x86_64.flatpak` (+ `.sig`). No standalone Linux binary for amd64 or arm64. |
| Draft binary links | **Correction:** the draft's `HandBrake-1.11.2-x86_64-Win_GUI.zip` and `...-arm64-Win_GUI.zip` are Windows builds. They cannot be used on Linux. |
| Checksums | Detached `.sig` files per asset. No sha256 digest field returned by the API for this release. Source tarball checksum file: UNVERIFIED. |
| License | UNVERIFIED: GitHub license API returns `NOASSERTION` for HandBrake/HandBrake. GPL-2.0 is from memory, not fetched. Read the repo `LICENSE` before setting `LICENSE` in bake. |
| Renovate | Proposed `datasource=github-releases depName=HandBrake/HandBrake versioning=loose` (tags have no `v` prefix). Not checked against a live config. |
| Ubuntu packages | Draft says `handbrake` and `handbrake-cli` exist in the Ubuntu archive. UNVERIFIED in this run (no archive index fetched). |
| Source | https://github.com/HandBrake/HandBrake |
| Docs | https://handbrake.fr/docs/ |

## 2. Target layout

- `apps/handbrake/Dockerfile`
- `apps/handbrake/docker-bake.hcl`
- `apps/handbrake/settings.yaml`
- `apps/handbrake/container-test.yaml`
- `apps/handbrake/start.sh` (starts the GUI or the automated conversion watcher, and seeds `/config` on first run)
- `defaults/` only if a seed file is needed (for example an openbox or GUI config; `apps/kasmvnc` ships openbox config under `root/defaults/`, which is not to be copied). Reason: the upstream GUI needs an X session config. Never use `root/`.

No `DOWNSTREAM_CHANGES.md` (nothing uses this as a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`

Why: the upstream `jlesage/baseimage-gui` is Alpine. The GUI and VNC layer must come from a glibc base. Closest sibling for a GUI on ubuntu: `apps/kasmvnc` (ubuntu 26.04 build stages, python-node final stage, openbox installed via apt; its openbox config lives in a legacy `root/defaults/` tree, which must not be copied: put any seed files in `defaults/` instead).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Install toolchain and runtime packages with `apt-get install -y --no-install-recommends` (pin against `VERSION` only if the package version is taken from the same release line; check `apt-cache policy handbrake-cli` at build time, UNVERIFIED version).
3. Preferred path (lowest risk): `apt-get install handbrake-cli handbrake` from the Ubuntu archive, instead of building from source. Expected Ubuntu version will differ from 1.11.2; record the actual version in `/etc` metadata or the image label and document the difference in `10. Risks`.
4. Fallback path (if apt versions are too old): download `HandBrake-${VERSION}-source.tar.bz2` from `https://github.com/HandBrake/HandBrake/releases/download/${VERSION}/`, extract to `/tmp/src`, build with its documented build script (UNVERIFIED: exact build command and build dependencies for Ubuntu 26.04), install `HandBrakeCLI` and `ghb` under `/usr/local/bin`.
5. License: `COPY` or `install` the upstream `LICENSE` to `/usr/share/licenses/handbrake/`.
6. `ENV HOME=/config XDG_CACHE_HOME=/tmp/.cache XDG_RUNTIME_DIR=/tmp/.XDG DISABLE_GLX=1` (caches to `/tmp`).
7. `chown -R apps:apps /app && chmod -R 755 /app` only for files the image installs under `/app`.
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 5800
EXPOSE 5900
VOLUME /config
```

`settings.yaml` lists only 5800; if `5900` is exposed it needs its own `settings.yaml` entry and `tcp` probe. Ports `5800` and `5900` are the upstream noVNC and VNC ports (draft, not confirmed in the Dockerfile; UNVERIFIED for this build). Only include `5900` if the GUI layer actually exposes VNC.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "handbrake"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=HandBrake/HandBrake versioning=loose
  default = "1.11.2"
}

variable "LICENSE" {
  default = "GPL-2.0-only"   // UNVERIFIED: confirm against the repo LICENSE before use
}

variable "SOURCE" {
  default = "https://github.com/HandBrake/HandBrake"
}
```

Add the four standard targets and the `default` group copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/HandBrake/HandBrake"
ports:
  - port: 5800
    protocol: tcp
    required: false
env:
  - name: AUTOMATED_CONVERSION
    default: "0"   # upstream default is 1; the default here must match whatever start.sh implements (UNVERIFIED, start.sh not written)
    required: false
  - name: AUTOMATED_CONVERSION_PRESET
    default: "General/Very Fast 1080p30"
    required: false
  - name: AUTOMATED_CONVERSION_FORMAT
    default: "mp4"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Upstream env names above are from the jlesage Dockerfile and must match what the app reads; keep the list to what `start.sh` actually uses. `/output` and `/storage` are upstream media paths, not `/config`: do not list them as `volumes` unless `start.sh` uses them. Dependencies: none.

## 7. start.sh

- Seed `/config` only when missing: create `/config/.config` and copy `/defaults/*` files if absent. Never overwrite.
- Create `/tmp` scratch dirs for `XDG_RUNTIME_DIR` and cache.
- Start the chosen process with `exec` (GUI X session or `HandBrakeCLI`-based watcher). The GUI process must bind 0.0.0.0 for the noVNC/VNC port (UNVERIFIED which flag controls this in the chosen stack).
- No writes to `/app`.

Exact command: UNVERIFIED until the GUI stack is chosen.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 180
tcp:
- port: '5800'
```

Add a `tcp` probe for every port in `settings.yaml`. Add `filePaths` for `/usr/bin/HandBrakeCLI` (or the path actually installed) and `/usr/share/licenses/handbrake/LICENSE`. `timeoutSeconds: 180` is a guess: `apps/kasmvnc` (GUI family) sets no `timeoutSeconds`, so UNVERIFIED.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/config` (settings, GUI state) | Keep as the persistent volume. |
| `HOME`, `XDG_RUNTIME_DIR`, caches | `/tmp` (`XDG_RUNTIME_DIR=/tmp/.XDG`, `XDG_CACHE_HOME=/tmp/.cache`). |
| `/output`, `/watch`, `/storage`, `/trash` (upstream media paths) | Not `/config`. Document as user-supplied bind mounts. UNVERIFIED whether they must be writable by `apps` UID. |
| Chart security: `runAsUser 0`, `readOnlyRootFilesystem false`, extra capabilities `NET_BIND_SERVICE`, `KILL`, VAAPI device | **Reconcile:** ContainerForge requires `USER apps` and read-only rootfs. The chart values are a draft expectation to verify, not a requirement to copy. VAAPI needs a `/dev/dri` device passed in by the user, which is outside the image. |

## 10. Risks, caveats and open questions

- **Blocker: GUI over VNC on a read-only rootfs is unproven.** The upstream image relies on a full Alpine GUI base (`jlesage/baseimage-gui`). Rebuilding that stack on ubuntu is substantial. Confirm that the `apps/kasmvnc` pattern covers it before starting.
- **Blocker: no Linux prebuilt binary.** Linux amd64 and arm64 require either the Ubuntu apt packages (version not verified) or a source build of 1.11.2 (build deps unverified).
- Ubuntu apt HandBrake may lag 1.11.2; codec and preset output can differ (draft caveat, not verified).
- CPU-heavy transcodes need scratch space; `/tmp` is ramdisk-style and may be too small. Document the need for a writable bind mount.
- arm64 runtime not verified.
- Draft's license value is unverified.

## 11. Build and test steps

```sh
cd apps/handbrake
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name handbrake-probe --read-only --tmpfs /tmp \
  -v handbrake-probe-config:/config handbrake:1.11.2
docker logs -f handbrake-probe
forgetool containers test --image handbrake:1.11.2 --config ./apps/handbrake/container-test.yaml
docker rm -f handbrake-probe; docker volume rm handbrake-probe-config
```

Expected readiness signal: UNVERIFIED until the GUI stack is chosen. Use the success criteria in the build-test protocol.

## 12. PR checklist

- Branch `feat/add-handbrake`, commit `feat(handbrake): add new container`.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only they can sign it).
- PR description: `🤖 This PR is AI generated.` in Notes, PR template kept.
- State what was not tested: bake, build, run and forgetool test are not run in this planning step.
- Do not tick "Built container locally" until the image is built.
