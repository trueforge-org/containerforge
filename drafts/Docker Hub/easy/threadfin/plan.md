# threadfin — implementation plan
> Source: ./draft.md · Target: apps/threadfin/ · Difficulty: easy · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | **1.2.37** (GitHub "Latest", tag `1.2.37` without a `v`, commit `c459dd5`, released 2025-09-11). It matches the draft. |
| Renovate | `datasource=github-releases depName=Threadfin/Threadfin versioning=semver` |
| License | MIT (GitHub shows "MIT license"; `LICENSE` at the tag returns 200). SPDX `MIT`. |
| Source URL | https://github.com/Threadfin/Threadfin |
| Download | `https://github.com/Threadfin/Threadfin/releases/download/1.2.37/Threadfin_linux_amd64` and `.../Threadfin_linux_arm64` (arm64 returns HTTP 200). The release also has `Threadfin_linux_amd64_glibc_2.31_compat`, `Threadfin_linux_arm`, darwin, freebsd and windows binaries. The assets are bare executables, not archives. |
| Checksum source | **None published**: the 9 binaries plus the source archives are the only assets. UNVERIFIED: whether a checksum is available elsewhere. |
| License file | Not in the release. Fetch it at build time from `https://raw.githubusercontent.com/Threadfin/Threadfin/${VERSION}/LICENSE`. |
| Upstream Dockerfile reviewed | Commit `c459dd5`: a `golang:1.23-bullseye` build with `CGO_ENABLED=0 go build ... threadfin.go` (a static binary), then an `ubuntu:24.04` runtime that installs `ffmpeg`, `vlc` and `jellyfin-ffmpeg7`. The entrypoint is `threadfin -port=${THREADFIN_PORT} -bind=${THREADFIN_BIND_IP_ADDRESS} -config=${THREADFIN_CONF} -debug=${THREADFIN_DEBUG}`. |
| Upstream image env (consumed by the upstream entrypoint, not by the binary) | `THREADFIN_PORT=34400`, `THREADFIN_BIND_IP_ADDRESS=0.0.0.0`, `THREADFIN_DEBUG=0`, `THREADFIN_CONF=/home/threadfin/conf`, `THREADFIN_TEMP=/tmp/threadfin`. |
| Binary flags | `-port`, `-bind`, `-config`, `-debug` (from the upstream entrypoint). `-branch` and `-dev` are also documented in the README. |
| Port | 34400/tcp (web UI, playlist, XMLTV and the HDHomeRun emulation API). |
| Paths | Config in `-config` (upstream default mount `/home/threadfin/conf`), plus a temp directory at `/tmp/threadfin` (the README's docker example mounts it read-write). UNVERIFIED: the binary's own temp and cache path logic. |

## 2. Target layout

```
apps/threadfin/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```

`start.sh` maps env vars to flags. No `defaults/`: Threadfin creates its settings in `-config` on first start (UNVERIFIED, test with an empty volume). Never use `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

The Go binary is prebuilt and static (upstream uses `CGO_ENABLED=0`), so no Go stage is needed. The `go-runtime` rules do not apply because we do not compile. Closest sibling: `apps/adguardhome-sync` (a Go release binary on ubuntu). The ubuntu base already provides `curl` and `ca-certificates`.

## 4. Dockerfile

1. `FROM` ubuntu (above); `ARG VERSION`; `ARG TARGETARCH` (BuildKit gives `amd64` or `arm64`, which matches the asset suffix directly).
2. `USER root`.
3. `ENV HOME=/config`.
4. `apt-get install -y --no-install-recommends ffmpeg && rm -rf /var/lib/apt/lists/*`. Upstream also ships `vlc` and the jellyfin `ffmpeg7`. This plan includes only distro `ffmpeg` (the draft calls it optional) and leaves out VLC. See section 10. The version is not pinned because it is a helper tool and not the app.
5. Download:
   ```sh
   curl -fsSL -o /app/threadfin "https://github.com/Threadfin/Threadfin/releases/download/${VERSION}/Threadfin_linux_${TARGETARCH}"
   chmod 755 /app/threadfin && chown root:root /app/threadfin
   mkdir -p /usr/share/licenses/threadfin
   curl -fsSL -o /usr/share/licenses/threadfin/LICENSE "https://raw.githubusercontent.com/Threadfin/Threadfin/${VERSION}/LICENSE"
   ```
   No checksum can be verified (none is published), so state this in the PR. Use `curl -f` so a 404 fails the build.
6. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 34400`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}
variable "APP" { default = "threadfin" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=Threadfin/Threadfin versioning=semver
  default = "1.2.37"
}
variable "LICENSE" { default = "MIT" }
variable "SOURCE"  { default = "https://github.com/Threadfin/Threadfin" }
```

The standard `group "default"` and the targets `image`, `image-local` and `image-all` (amd64 and arm64) come from `apps/adguardhome-sync/docker-bake.hcl`. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/Threadfin/Threadfin"
ports:
  - port: 34400
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: THREADFIN_PORT
    default: "34400"
    required: false
  - name: THREADFIN_BIND_IP_ADDRESS
    default: "0.0.0.0"
    required: false
  - name: THREADFIN_DEBUG
    default: "0"
    required: false
volumes:
  - path: /config
    required: true
```

The three `THREADFIN_*` names are the ones the upstream image's entrypoint reads, and `start.sh` reads them and turns them into flags (the binary itself reads no env vars, UNVERIFIED). If `THREADFIN_PORT` is changed, the test and `EXPOSE` no longer match, so keep the default. Dependencies: none. DVB and HDHomeRun sources are external.

## 7. start.sh

`#!/usr/bin/env bash`:

1. `mkdir -p /config /tmp/threadfin` (the first may already exist as a volume).
2. Defaults: `THREADFIN_PORT=${THREADFIN_PORT:-34400}`, `THREADFIN_BIND_IP_ADDRESS=${THREADFIN_BIND_IP_ADDRESS:-0.0.0.0}`, `THREADFIN_DEBUG=${THREADFIN_DEBUG:-0}`.
3. `export TMPDIR=/tmp` (keeps scratch space in `/tmp`).
4. `exec /app/threadfin -port="${THREADFIN_PORT}" -bind="${THREADFIN_BIND_IP_ADDRESS}" -config=/config -debug="${THREADFIN_DEBUG}"`.

No writes to `/app`, no seeding is needed, and a restart is idempotent. `start.sh` passes `-bind=0.0.0.0` by default, so other containers and clients should reach it (check with a request from a second container). No secrets are involved at first start (the web UI has its own user setup after startup).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

http:
- port: '34400'
  path: /web/

filePaths:
- /app/threadfin
- /usr/share/licenses/threadfin/LICENSE
```

The probe covers the only declared port. UNVERIFIED: the UI path (`/web/` is the xTeVe/Threadfin UI route, and `/` may redirect). If `/web/` does not return 200, fall back to a `tcp` probe on 34400 and record why. Timeout: use the 180 s default, as the Go siblings do. No env is required to start.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
|---|---|
| `/home/threadfin/conf` (settings, DB, cache) | `-config=/config` |
| `/home/threadfin/cache` | Inside `/config`. UNVERIFIED: confirm that the binary keeps its cache under `-config` and not under `$HOME`. |
| `/tmp/threadfin` | `/tmp` (tmpfs) |
| `/var/log/threadfin.log` (`THREADFIN_LOG`) | Not used: logs go to stdout. |
| Self-update (setting `ThreadfinAutoUpdate`, run at every start by `BinaryUpdate()`) | `/app` is root-owned and the rootfs is read-only, so the binary cannot be replaced. Updates happen by image tag. See section 10. |
| UID 31337 in the upstream image | UID 568 (`USER apps`) |

TrueCharts expectations reconciled: non-root and `readOnlyRootFilesystem true` both hold, and the chart's PVC at `/home/threadfin/conf` must be mounted at `/config` instead. The emptyDir `/tmp/threadfin` is covered by the `/tmp` tmpfs.

## 10. Risks, caveats and open questions

- No upstream checksum: the downloaded binary is verified only by TLS and the release tag.
- Self-update (checked in the 1.2.37 source): `ThreadfinAutoUpdate` defaults to `true`, and to `false` only if `/.dockerenv` exists. In Kubernetes that file is normally absent, so the app will try to download a newer release once one exists. UNVERIFIED: that the failed replacement on a read-only binary is harmless. Consider seeding or setting `ThreadfinAutoUpdate: false` in `/config/settings.json`, and test it.
- VLC and the jellyfin ffmpeg are not included. Users who select VLC as a stream buffer will not find it. The distro `ffmpeg` is at `/usr/bin/ffmpeg`, so the buffer settings in the UI should point there.
- The draft's ffmpeg caveat is covered: it is installed, which enlarges the image a little.
- Discovery (HDHomeRun, DVB) needs multicast or host networking, which is a deployment concern.
- First use is manual: add M3U/XMLTV sources in the UI (draft caveat), so nothing is preconfigured.
- No blockers: static Go binary on glibc, both arches, no GPU (the upstream NVIDIA variant is skipped), no privileged mode.

## 11. Build and test steps

```sh
cd apps/threadfin
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name threadfin-probe --read-only --tmpfs /tmp \
  -v threadfin-probe-config:/config -p 34400:34400 threadfin:1.2.37
docker logs -f threadfin-probe
curl -fsS -o /dev/null -w '%{http_code}\n' http://localhost:34400/web/
docker rm -f threadfin-probe; docker volume rm threadfin-probe-config
forgetool containers test --image threadfin:1.2.37 --config ./apps/threadfin/container-test.yaml
```

Readiness signal: the logs show the web server starting on port 34400 (the exact wording is UNVERIFIED) with no repeated errors about read-only paths, and the process stays up. Restart on the same volume to check idempotency.

## 12. PR checklist

- Branch `feat/add-threadfin`, commit and PR title `feat(threadfin): add new container`, target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md` and check only the boxes that apply.
- Put `🤖 This PR is AI generated.` in the Notes section.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it.
- State in the PR: no checksum available, VLC omitted, and the UI probe path.
- Untested at planning time: the build, both arches, the read-only run, `forgetool containers test`, and the ffmpeg buffer. Do not check "Built container locally" unless it was done.
