# birdnet-go — implementation plan
> Source: ./draft.md · Target: apps/birdnet-go/ · Difficulty: hard · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `20261031`, the latest release (published 2026-10-31T07:31:46Z). Source: https://api.github.com/repos/tphakala/birdnet-go/releases/tags/20261031 (read with `gh api`). Draft tag matches. |
| Renovate | `// renovate: datasource=github-releases depName=tphakala/birdnet-go versioning=loose` (tags are date-style `20261031`, so `loose`, per the bake rule for non-semver tags; not confirmed on a page). |
| License | CC BY-NC-SA 4.0 (non-commercial, share-alike). Read from https://github.com/tphakala/birdnet-go/blob/main/LICENSE via `gh api repos/tphakala/birdnet-go/contents/LICENSE`. GitHub API reports `NOASSERTION`, so the SPDX id `CC-BY-NC-SA-4.0` is taken from the license text, not from GitHub. The user must decide whether a non-commercial license is acceptable for a ContainerForge image before PR. |
| Source URL | https://github.com/tphakala/birdnet-go |
| Download (linux) | amd64: `https://github.com/tphakala/birdnet-go/releases/download/20261031/birdnet-go-linux-amd64-20261031.tar.gz` (121973025 bytes). arm64: `https://github.com/tphakala/birdnet-go/releases/download/20261031/birdnet-go-linux-arm64-20261031.tar.gz` (118559861 bytes). |
| Checksum source | `checksums.txt` release asset. Confirmed lines (read via `gh api`): `c69a805ea92b359a1565deb05fc6b4cf97f72af71d87eb359a786ae5cb444bda  birdnet-go-linux-amd64-20261031.tar.gz`, `8a325fc1133804583d9c0f235cfd3b3d055b8558440c69268afde8d8ab85b132  birdnet-go-linux-arm64-20261031.tar.gz`. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/tphakala/birdnet-go/bc1e0de67d9a2292b4742a79f868a7720f8e6a12/Dockerfile. Build stage `golang:1.27-trixie`; runtime `debian:trixie-slim` (glibc). Runtime apt: `adduser`, `ca-certificates`, `libasound2`, `ffmpeg`, `procps`, `iproute2`, `curl`, `wget`, `tzdata`, `jq`, `gosu`, `tini`, `libnss-mdns`. Upstream runtime also downloads ONNX Runtime 1.25.1 (no checksum), TFLite C 2.17.1 (no checksum), OpenVINO 2026.2 (SHA256 checked), and amd64-only Intel NEO packages (SHA256 checked). ENTRYPOINT `/usr/bin/tini -s -- /usr/bin/entrypoint.sh /usr/bin/startup-wrapper.sh`; CMD `birdnet-go realtime`. |
| Ports (real) | Upstream EXPOSE `80 443 8080 8090`. Upstream Dockerfile comments name 8080 as the standard HTTP web interface port and its `HEALTHCHECK` probes `/health` on 8080 (checked); the draft's `8080` is therefore supported. Upstream `HEALTHCHECK` reads `BIRDNET_WEBSERVER_PORT` and `BIRDNET_SECURITY_TLSPORT`. |
| Runtime env vars (real) | From Dockerfile comments (not `ENV` lines): `BIRDNET_UID`, `BIRDNET_GID` (default `1000`), `BIRDNET_STARTUP_FAIL_DELAY` (default `10`), `TZ`, `BIRDNET_MODELPATH`, `BIRDNET_WEBSERVER_PORT`, `BIRDNET_SECURITY_TLSPORT`. Entrypoint scripts not fetched: UNVERIFIED behavior. |
| Volumes (upstream) | `VOLUME /config`, `VOLUME /data`, `WORKDIR /data`, `/data/clips` and `/data/models` created with mode `777`, models in `/models` (tflite on amd64, onnx on arm64). |
| Upstream user | No `USER` set; `BIRDNET_UID`/`BIRDNET_GID` used by upstream entrypoint to run as that user (UNVERIFIED how). |
| Arm64 | Upstream ships an arm64 tarball and onnx models for arm64. Hardware test not done in this run. |
| copy-from | The draft cites `ghcr.io/tphakala/birdnet-go:20261031`. UNVERIFIED: that image tag and per-arch publication were not fetched in this run. Not used by this plan. |

## 2. Target layout

Exact file list for `apps/birdnet-go/`:
- `Dockerfile`: required.
- `docker-bake.hcl`: required.
- `settings.yaml`: required.
- `container-test.yaml`: required.
- `start.sh`: required. Starts `birdnet-go realtime` (upstream CMD) and seeds `/config` on first run.
- `defaults/`: needed only if a default `birdnet-go` config is seeded to `/config` (reason: idempotent seeding rule). Source of the default config file is UNVERIFIED.
- `etc/`: not needed.
- `root/`: NEVER used.
- `DOWNSTREAM_CHANGES.md`: not needed.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`. Upstream runs on Debian trixie (glibc). Ubuntu 26.04 base is glibc too, so the release binary should run without a copy. Closest sibling: `apps/adguardhome-sync` (prebuilt tarball on ubuntu). Upstream `libasound2` and `ffmpeg` come from apt on the ubuntu base (package availability UNVERIFIED for 26.04).

## 4. Dockerfile

1. `ARG VERSION=20261031`, `ARG TARGETARCH`. `VERSION` must equal the bake default.
2. `USER root`.
3. Install runtime apt packages (check the ubuntu base first; install only what is missing): `libasound2t64` or `libasound2` (UNVERIFIED name on 26.04), `ffmpeg`, `tzdata`, `jq`, `procps`. Use `--no-install-recommends` and clean lists in the same `RUN`.
4. Download and verify: `curl -fL -o /tmp/birdnet-go.tar.gz "https://github.com/tphakala/birdnet-go/releases/download/${VERSION}/birdnet-go-linux-${TARGETARCH}-${VERSION}.tar.gz"` then fetch `checksums.txt` into `/tmp` and verify with `grep "birdnet-go-linux-${TARGETARCH}-${VERSION}.tar.gz" checksums.txt | sha256sum -c -`. Use `sha256sum -c` with the matching line only. Arch mapping: `TARGETARCH` `amd64` and `arm64` match the upstream names (no mapping needed).
5. Extract the tarball into `/app/birdnet-go` (`tar -xzf ... -C /app/birdnet-go --strip-components=1` or the layout the tarball has; the layout is UNVERIFIED, check once).
6. Ship the license: copy the CC BY-NC-SA text from the upstream repo's `LICENSE` (fetch it in the same step from `https://raw.githubusercontent.com/tphakala/birdnet-go/${VERSION}/LICENSE` or the tarball) to `/usr/share/licenses/birdnet-go/LICENSE`. The upstream tag `20261031` must exist for this URL (UNVERIFIED tag ref; use `main` if the tag path fails).
7. `chown -R apps:apps /app/birdnet-go && chmod -R 755 /app/birdnet-go`. The `apps` user is UID/GID 568 (from the ubuntu base).
8. Remove `/tmp/birdnet-go.tar.gz` and `checksums.txt` in the same `RUN`.
9. Environment: `ENV HOME=/config TZ=Etc/UTC BIRDNET_MODELPATH=/app/birdnet-go/models` (set the models path to a read-only location in `/app`; UNVERIFIED that the tarball contains models). Caches to `/tmp` only.
10. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
VOLUME /data
WORKDIR /config
```

Create `/data` owned by `apps` earlier in the build (as root) so the volume is writable on a read-only rootfs. `/app/birdnet-go/birdnet-go` assumes the tarball layout (UNVERIFIED). EXPOSE port is `8080` only in this plan (see section 10 for `80`, `443`, `8090`).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "birdnet-go"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=tphakala/birdnet-go versioning=loose
  default = "20261031"
}

variable "LICENSE" {
  default = "CC-BY-NC-SA-4.0"
}

variable "SOURCE" {
  default = "https://github.com/tphakala/birdnet-go"
}
```

Then the default group, `image`, `image-local` and `image-all` targets from `apps/adguardhome-sync/docker-bake.hcl`. `LICENSE` must match the software: `CC-BY-NC-SA-4.0` from the license text (UNVERIFIED that the SPDX identifier is accepted by the repo's label checks). Validate with `docker buildx bake --print` from `apps/birdnet-go/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/tphakala/birdnet-go"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: BIRDNET_WEBSERVER_PORT
    default: "8080"
    required: false
volumes:
  - path: /config
    required: true
  - path: /data
    required: false
```

Only real env vars are listed. `BIRDNET_UID` and `BIRDNET_GID` are read by upstream entrypoint; add them only after the non-root behavior is confirmed (section 9). `dependencies:` none. Audio capture device is a host-side requirement, not a setting.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -eu

mkdir -p /config /data/clips /data/models /tmp/birdnet-go
# Seed default config only when missing (path and content UNVERIFIED)
# cp -n /defaults/<file> /config/<file> 2>/dev/null || true

export BIRDNET_WEBSERVER_PORT="${BIRDNET_WEBSERVER_PORT:-8080}"
cd /config
exec /app/birdnet-go/birdnet-go realtime
```

Key points:
- Idempotent: `mkdir -p` and `cp -n` only. Never overwrites `/config`.
- Writes only to `/config`, `/data` (volume) and `/tmp`. Never `/app`.
- The `/data` dirs are created by `start.sh` (upstream created them at build time with mode 777; not kept).
- Binds to all interfaces: the web server must listen on `0.0.0.0`. Check the bind address in the default config (UNVERIFIED).
- `exec` the final process so signals reach it.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 180
tcp:
- port: '8080'
http:
- port: '8080'
  path: /health
filePaths:
- /app/birdnet-go/birdnet-go
- /usr/share/licenses/birdnet-go/LICENSE
```

`/health` is the upstream healthcheck path (from Dockerfile). Port `8080` is inferred; if the probe fails, check the real port from the first log (protocol: section 11). `timeoutSeconds: 180` because the first start loads large models (see section 10); confirm against a sibling. Without an audio device the app may not reach ready; that is a known caveat, not a reason to weaken the probe (see section 10).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/config` (VOLUME) | `/config`, unchanged. Persistent config and state. |
| `/data` (VOLUME, `WORKDIR`) and `/data/clips`, `/data/models` | Keep `/data` as a volume; create the subdirs in `start.sh`. Do not make `/data` a `/config` symlink (not needed). |
| `/models` (copied model files) | Move under `/app/birdnet-go/models` (read-only). |
| `/usr/bin/entrypoint.sh`, `/usr/bin/startup-wrapper.sh` | Not used. `start.sh` replaces them. Upstream user switching (`gosu`, `BIRDNET_UID`) is NOT carried over: the image runs as `apps` (568). |
| `/etc/nsswitch.conf` rewrite (mDNS) | Not carried over (needs root write to `/etc`). UNVERIFIED that mDNS is needed for this app. |
| `/tmp` | Caches and scratch only. |

Security expectations from the draft: non-root (default 568), read-only rootfs yes, privileged no. This plan keeps those. Extra persistence: `/config` and `/data`. Audio device access (`/dev/snd` or USB mic) needs a group or device mapping on the host and is NOT granted by this image (UNVERIFIED: group id needed).

## 10. Risks, caveats and open questions

- License blocker: CC BY-NC-SA 4.0 is non-commercial and share-alike. The user must decide whether to ship this image. Note it in the PR.
- Hardware blocker: live audio capture (ALSA or USB mic) needs a host device. Without it the app runs but detects nothing (draft inference). Test runs have no device, so the readiness signal will not prove detection.
- Ports: upstream EXPOSE is `80 443 8080 8090`. This plan opens only `8080` (inferred web UI). Confirm the real default port in the default config before adding more.
- Upstream entrypoint (`entrypoint.sh`, `startup-wrapper.sh`) and the `reset_auth.sh` script were NOT fetched. Their behavior (UID drop, config seeding, auth) is UNVERIFIED. Read them before finalizing `start.sh`.
- ONNX Runtime and TFLite C downloads in upstream have no checksum. This plan uses the release tarball, which is checksum-verified. Whether the tarball bundles the libraries is UNVERIFIED. If it does not, the app will fail at first start and the plan must add the libraries with checksums that upstream does not publish (flag to user).
- Image size: tarball is ~120 MB; the first start loads models. Startup timing is UNVERIFIED (hence `timeoutSeconds: 180`).
- arm64 is not tested. Upstream ships arm64 tarball and onnx models.
- copy-from is NOT used (the draft's `ghcr.io/tphakala/birdnet-go:20261031` was not verified as published).
- Upstream `HEALTHCHECK` port reading (`BIRDNET_WEBSERVER_PORT`, `BIRDNET_SECURITY_TLSPORT`) suggests the port can be changed; the plan's `8080` default must match the app.
- Chart values (`readOnlyRootFilesystem` default, non-root default 568) are from the draft and were not re-fetched.

## 11. Build and test steps

From `apps/birdnet-go/`:

1. `docker buildx bake --print`.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker run --rm -d --name birdnet-go-probe --read-only --tmpfs /tmp -v birdnet-go-probe-config:/config birdnet-go:20261031`. Then `docker logs -f birdnet-go-probe`. Readiness signal: the app's web server "listening" line and `8080` open. Expect "no audio device" messages: treat as a warning, not a fatal error, only if the process stays alive. Cleanup: `docker rm -f birdnet-go-probe; docker volume rm birdnet-go-probe-config`.
4. `forgetool containers test --image birdnet-go:20261031 --config ./apps/birdnet-go/container-test.yaml`.
5. Repeat with an empty `/config` every round.

Not tested: arm64 build, real audio capture, model load on arm64, `/health` response body.

## 12. PR checklist

- Branch: `feat/add-birdnet-go`.
- Commit: `feat(birdnet-go): add new container`.
- PR title: `feat(birdnet-go): add new container`.
- PR body: use `.github/PULL_REQUEST_TEMPLATE.md`. Check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign; the `license/cla` check shows status.
- Tell the user about the CC BY-NC-SA 4.0 license and the audio device caveat in the PR.
- Untested list: arm64, audio capture, models on arm64, port 80/443/8090, any UNVERIFIED value.
- Do NOT check "Built container locally" unless section 11 was run.
