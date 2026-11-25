# homebridge — implementation plan
> Source: ./draft.md · Target: apps/homebridge/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Latest upstream release | homebridge `v2.5.0`, published 2026-11-01 (https://api.github.com/repos/homebridge/homebridge/releases/latest) |
| Draft image tag | `ghcr.io/homebridge/homebridge:2026-11-15`. Git tag `2026-11-15` exists on homebridge/docker-homebridge (commit `569c5f0648ee9a6f4fe841d4208cfcd8cec198b4`) (https://github.com/homebridge/docker-homebridge/tree/2026-11-15) |
| Plan version to build | `homebridge-apt-pkg` `v1.7.12` (latest release, published 2025-09-28, https://api.github.com/repos/homebridge/homebridge-apt-pkg/releases/latest). Which homebridge version this `.deb` wraps: UNVERIFIED. Which `.deb` the 2026-11-15 tag pins: UNVERIFIED (the Dockerfile takes `HOMEBRIDGE_APT_PKG_VERSION` as a build arg with no default). |
| Renovate | `datasource=github-releases depName=homebridge/homebridge-apt-pkg versioning=semver` (the `v` prefix is accepted by semver) |
| License | Homebridge core: Apache-2.0 (GitHub API, homebridge/homebridge). Upstream Dockerfile repo: GPL-3.0 (homebridge/docker-homebridge). License of `homebridge-apt-pkg`: UNVERIFIED. |
| Source URL | https://github.com/homebridge/homebridge |
| Download (amd64) | `https://github.com/homebridge/homebridge-apt-pkg/releases/download/v1.7.12/homebridge_v1.7.12_amd64.deb` (asset name confirmed in the release listing) |
| Download (arm64) | `https://github.com/homebridge/homebridge-apt-pkg/releases/download/v1.7.12/homebridge_v1.7.12_arm64.deb` (asset name confirmed) |
| Checksum source | None published as a checksum file. Each release ships a `.manifest` per arch, not a digest. The `.deb` is pinned by tag, so it is content-addressed only by GitHub's release. UNVERIFIED whether the `.manifest` files contain hashes. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/homebridge/docker-homebridge/2026-11-15/Dockerfile: `ARG BASE_IMAGE=ubuntu:24.04`; apt installs; s6-overlay `3.2.0.2` (`curl` without checksum); ffmpeg-for-homebridge tarball (`curl | tar`, no checksum); `.deb` installed with `apt-get install`; `COPY rootfs /`; `VOLUME /homebridge`; `EXPOSE 8581/tcp`; `ENTRYPOINT ["/init"]`; no `USER` line (runs as root). |
| Architectures | Upstream builds `x86_64`, `armv7l` and `aarch64`. Draft scope for ContainerForge: amd64 and arm64. arm64 `.deb` exists. |
| Port | `8581/tcp` (web UI, upstream EXPOSE). HAP `51826/tcp` and mDNS `5353/udp` from the draft are NOT in the upstream EXPOSE; UNVERIFIED (inferred from HomeKit behaviour only). |
| Data paths | Upstream `VOLUME /homebridge`; plugins under `/var/lib/homebridge/node_modules` (`UIX_CUSTOM_PLUGIN_PATH`); `npm_config_prefix=/opt/homebridge`; `HOME=/home/homebridge`. |
| Env vars (upstream) | `DEBIAN_FRONTEND`, `S6_OVERLAY_VERSION=3.2.0.2`, `S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0`, `S6_KEEP_ENV=1`, `ENABLE_AVAHI=1`, `USER=root`, `HOMEBRIDGE_APT_PACKAGE=1`, `UIX_CUSTOM_PLUGIN_PATH`, `PATH`, `HOME`, `npm_config_prefix`. Homebridge's own runtime flags (for example `-U` user storage path): UNVERIFIED for the `.deb` service script. |
| Dependencies | None (no database). |

## 2. Target layout

- `apps/homebridge/Dockerfile`
- `apps/homebridge/docker-bake.hcl`
- `apps/homebridge/settings.yaml`
- `apps/homebridge/container-test.yaml`
- `apps/homebridge/start.sh` (replaces s6 `/init`; homebridge is a single process, so no s6 tree)

No `defaults/` (the config is created by homebridge on first start, so seeding is a `start.sh` concern only if needed). No `etc/` (no s6 service tree). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Final and build stage: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`.

Draft proposed `python-node`. Not chosen: the homebridge runtime comes from the vendor `.deb`, and no Python code or Node build runs in this image. If the `.deb` depends on a system `node` that ubuntu does not supply, switch to `ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5`. Node presence in the `.deb` dependency tree: UNVERIFIED. Closest sibling: `apps/adguardhome-sync` (single binary on ubuntu, same `COPY --chmod` shape).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Map the architecture: `amd64` -> `amd64`, `arm64` -> `arm64` (the `.deb` suffix is `DEB_ARCH`). Fail the build on any other value.
3. Download and verify:
   ```dockerfile
   RUN curl -fL -o /tmp/homebridge.deb \
     "https://github.com/homebridge/homebridge-apt-pkg/releases/download/v${VERSION#v}/homebridge_v${VERSION#v}_${TARGETARCH}.deb"
   ```
   There is no published checksum to compare against. Record the source URL in a comment and rely on the tag pin.
4. `apt-get update && apt-get install -y --no-install-recommends /tmp/homebridge.deb && apt-get clean` (installing the local `.deb` pulls its dependencies). Then `rm -rf /var/lib/apt/lists/* /tmp/*`.
5. Use `ffmpeg-for-homebridge` only if the `.deb` does not bring ffmpeg. Its tarball is `ffmpeg-alpine-${FFMPEG_ARCH}.tar.gz` (musl, not glibc): it does NOT run on ubuntu. Do not port it. Camera streaming therefore needs the distro `ffmpeg` package: UNVERIFIED.
6. `ENV HOME=/config npm_config_prefix=/config/npm UIX_CUSTOM_PLUGIN_PATH=/config/node_modules PATH=/config/npm/bin:$PATH` so plugin installs land under `/config` and not under `/var/lib` or `/opt`. These paths are a design choice, not upstream behaviour: UNVERIFIED that the `.deb`'s homebridge honours them.
7. License: `COPY` the homebridge license from the `.deb` (`/usr/share/doc/homebridge/`) into `/usr/share/licenses/homebridge/` if present; otherwise record the Apache-2.0 notice from the upstream repo. UNVERIFIED path.
8. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8581`, `VOLUME /config`, `WORKDIR /config`.

Do NOT keep `USER root` in the final stage. Do NOT keep the s6-overlay install (see section 9).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "homebridge"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=homebridge/homebridge-apt-pkg versioning=semver
  default = "v1.7.12"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/homebridge/homebridge"
}

group "default" {
  targets = ["image-local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
  args = {
    VERSION = "${VERSION}"
  }
  labels = {
    "org.opencontainers.image.source" = "${SOURCE}"
    "org.opencontainers.image.licenses" = "${LICENSE}"
  }
}

target "image-local" {
  inherits = ["image"]
  output = ["type=docker"]
  tags = ["${APP}:${VERSION}"]
}

target "image-all" {
  inherits = ["image"]
  platforms = ["linux/amd64", "linux/arm64"]
}
```

The `VERSION` is the `homebridge-apt-pkg` tag, and `ARG VERSION` in the Dockerfile must match it. `LICENSE` must describe the software in the image. Homebridge core is Apache-2.0; if the `.deb` bundles GPL components, widen it: UNVERIFIED. Run `docker buildx bake --print` before commit.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/homebridge/homebridge"
ports:
  - port: 8581
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Port 8581 is the only confirmed port. 51826 (HAP) and 5353 (mDNS) are not listed because nothing confirms they are opened by this container (rule: do not list ports the container does not open). Add them only after a run shows them listening. Env vars: only `TZ` is confirmed as a common variable; no upstream app var is confirmed beyond `ENABLE_AVAHI`, which this image does not use.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/plugins /config/node_modules

cd /config
echo "Starting Homebridge on port 8581"
exec homebridge -U /config
```

- Idempotent: creates directories only; no seeding needed (homebridge writes `config.json` on first start: UNVERIFIED).
- No writes to `/app` (there is no `/app` in this image).
- Caches stay in `/tmp` (`npm_config_cache=/tmp/npm`, add to the Dockerfile `ENV`).
- `exec` the process so signals reach homebridge.
- The `-U` flag and binary path `homebridge` must be checked against the `.deb` (UNVERIFIED).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 240
tcp:
- port: '8581'
http:
- port: '8581'
  path: /
filePaths:
- /usr/share/licenses/homebridge/
- /config
```

Probe `/` on 8581 with HTTP and TCP, per the coverage minimum. The `http` path must return a status the test accepts: the first-run UI may redirect; confirm before setting it (UNVERIFIED). `timeoutSeconds` set high because the first start installs or initialises state; sibling reference: `apps/bookstack` uses 240. `filePaths` only lists files confirmed in section 4; drop the licenses entry if step 7 does not produce it.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/homebridge` (VOLUME) | `/config` (ContainerForge volume) |
| `/var/lib/homebridge/node_modules` (plugins, `UIX_CUSTOM_PLUGIN_PATH`) | `/config/node_modules` |
| `/opt/homebridge` (`npm_config_prefix`, Docker.manifest, source.sh) | `/config/npm` for installs; `/opt` no longer written |
| `/home/homebridge` (`HOME`) | `/config` |
| npm cache | `/tmp/npm` |
| s6-overlay `/run` and service dirs | not used; no s6 in this image |

Draft expectations reconciled: the chart forces root (`runAsUser 0`, `runAsNonRoot false`) and `readOnlyRootFilesystem false`. This image is designed for UID `apps` and `--read-only --tmpfs /tmp`, which is stricter than the chart. The chart's extra persistence `/homebridge` maps to `/config`; existing users must copy their `/homebridge` contents into the new `/config`.

Blockers for the rootless target (see section 10): avahi-daemon (`ENABLE_AVAHI=1` upstream) needs root and dbus. Without it, HomeKit discovery over mDNS does not work from this image. This is a real functional loss; document it as a known limitation rather than bypassing the rule.

## 10. Risks, caveats and open questions

- The `.deb` pinned by the 2026-11-15 tag is unknown; the plan uses v1.7.12, which may not be the same homebridge version. Check the `.deb` `Depends` and `Version` fields before pinning (UNVERIFIED).
- No published checksum for the `.deb`. Risk accepted and recorded.
- mDNS (avahi) requires root and dbus; the rootless image cannot run it. HomeKit accessories will only be discovered from the host network or with an mDNS reflector. This is a hard blocker for full HomeKit use in bridge networking (draft caveat, confirmed in principle).
- Plugins are installed at runtime from npm, so the container needs internet access and the first start is slow (draft caveat, plausible; UNVERIFIED).
- `ffmpeg-for-homebridge` is musl/alpine and cannot be copied to ubuntu; camera streaming needs a glibc ffmpeg (UNVERIFIED availability in 26.04).
- The `homebridge-apt-pkg` service may run as the `homebridge` user; if so, the process is not root in the upstream image either. Verify with the `.deb` service file (UNVERIFIED).
- Renovate will bump to every new `homebridge-apt-pkg` tag; the upstream image is pinned by a dated tag, so the update path is different (draft caveat).
- Difficulty stays `hard`: rootless and read-only rework, mDNS loss, and no published checksum.

## 11. Build and test steps

```sh
cd apps/homebridge
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name homebridge-probe --read-only --tmpfs /tmp \
  -v homebridge-probe-config:/config homebridge:v1.7.12
docker logs -f homebridge-probe
forgetool containers test --image homebridge:v1.7.12 --config ./apps/homebridge/container-test.yaml
docker rm -f homebridge-probe; docker volume rm homebridge-probe-config
```

Expected readiness signal: the homebridge startup banner and a line that the web UI is listening on port 8581 (exact text UNVERIFIED until the first run). Also verify: the process stays alive, no crash loop, and an empty `/config` seeds without errors. Run once more with the same volume to confirm restart keeps `config.json`. arm64: build only if the amd64 build fails for an arm64-specific reason (protocol).

## 12. PR checklist

- Branch `feat/add-homebridge`, commit and PR title `feat(homebridge): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Untested to state honestly: the `.deb` service behaviour, the HomeKit/mDNS path, plugin installs under `--read-only`, the arm64 build, and the exact readiness log line, until they are run.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no test assertion weakened.
