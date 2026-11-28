# bitmagnet — implementation plan
> Source: ./draft.md · Target: apps/bitmagnet/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Draft pins container `ghcr.io/bitmagnet-io/bitmagnet:v0.10.1`. The latest GitHub release is `v0.10.0` (published 2025-03-02). `v0.10.1` is not a stable release; only the prerelease `v0.10.1-beta.1` (2026-05-21) exists (re-checked via `gh api`). Plan uses `0.10.0` (verified). DECISION NEEDED: confirm `v0.10.1` is not a release before building 0.10.0. Source: https://api.github.com/repos/bitmagnet-io/bitmagnet/releases/latest (read with `gh api`). |
| Renovate | `datasource=github-releases depName=bitmagnet-io/bitmagnet versioning=semver`. |
| License | MIT (GitHub SPDX `MIT`). Source: https://api.github.com/repos/bitmagnet-io/bitmagnet |
| Source URL | https://github.com/bitmagnet-io/bitmagnet |
| Per-arch download | amd64: https://github.com/bitmagnet-io/bitmagnet/releases/download/v0.10.0/bitmagnet_0.10.0_linux_x86_64.tar.gz · arm64: https://github.com/bitmagnet-io/bitmagnet/releases/download/v0.10.0/bitmagnet_0.10.0_linux_arm64.tar.gz. Draft's `.apk` links also exist, but the plan uses the tarballs to avoid apk extraction. |
| Checksum source | Published: https://github.com/bitmagnet-io/bitmagnet/releases/download/v0.10.0/bitmagnet_0.10.0_checksums.txt. sha256 `bitmagnet_0.10.0_linux_x86_64.tar.gz` = `6908f74f60019585ce498dca1914538ffe2c75270c21be6244e16d62f55e9072`; `bitmagnet_0.10.0_linux_arm64.tar.gz` = `bd1afbd5c4fa27b9b480e24b5bcace19d7094e83b617fd25b1af7c61a5541f81`. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/bitmagnet-io/bitmagnet/main/Dockerfile: build stage `golang:1.23.6-alpine3.20`, final stage `alpine:3.20`. Builds a stripped binary with a version injected via ldflags. Final stage copies `/usr/bin/bitmagnet`, `ENTRYPOINT ["bitmagnet"]`, no `CMD`, no `USER` (runs as root), no `EXPOSE`, no `VOLUME`, no `ENV`. Musl build, so not usable with `COPY --from` on Ubuntu. |
| Ports | Draft infers 3333/http (web UI) and 3334/udp (DHT). UNVERIFIED: no fetched page confirmed them, and the upstream Dockerfile has no `EXPOSE`. |
| Env vars | UNVERIFIED: the upstream Dockerfile sets none, and docs.bitmagnet.io was not fetched. Database variable names (the draft's `POSTGRES_*` guess) are not confirmed. |
| Database | PostgreSQL, external. The draft says migrations run on boot (inferred, UNVERIFIED). |
| arm64 | Release tarball for `linux_arm64` exists. |

## 2. Target layout

- `apps/bitmagnet/Dockerfile`
- `apps/bitmagnet/docker-bake.hcl`
- `apps/bitmagnet/settings.yaml`
- `apps/bitmagnet/container-test.yaml`
- `apps/bitmagnet/start.sh`

No `defaults/`, `etc/` or `health/` until the DB variables are verified. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`

Fits because the upstream binary is a static Go build and runs on glibc Ubuntu. Closest sibling: `apps/adguardhome-sync` (prebuilt tarball, `TARGETARCH`, `/app/<app>`). The database sibling is `apps/postgresql` (exists, `dependencies` target).

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Map `amd64` to `x86_64` and `arm64` to `arm64` in a shell `case`. Unknown arch fails the build.
3. Download `bitmagnet_${VERSION}_linux_${ARCH}.tar.gz` and `bitmagnet_${VERSION}_checksums.txt` from the `v${VERSION}` release. Check with `grep "bitmagnet_${VERSION}_linux_${ARCH}.tar.gz" checksums.txt | sha256sum -c -`. Fail on mismatch.
4. Extract only the `bitmagnet` binary into `/app/bitmagnet/`. Ship upstream's LICENSE (MIT text) to `/usr/share/licenses/bitmagnet/LICENSE` if the archive has one. UNVERIFIED: whether the tarball carries a LICENSE; if not, copy it from the source tag and say so in the PR.
5. `chown -R apps:apps /app/bitmagnet && chmod -R 755 /app/bitmagnet`, remove `/tmp` download files.
6. Final stage: `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 3333` (confirm first, see section 10), `VOLUME /config`.
7. No apt packages. The upstream `curl` and `iproute2-ss` are only used for the image's own health, not needed here (UNVERIFIED: no healthcheck in the draft).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "bitmagnet"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=bitmagnet-io/bitmagnet versioning=semver
  default = "0.10.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/bitmagnet-io/bitmagnet"
}
```

- The `VERSION` default must match the `v0.10.0` release and the `ARG VERSION` in the Dockerfile.
- Four standard targets and the default group as in `apps/adguardhome-sync/docker-bake.hcl`; `image-all` platforms `linux/amd64` and `linux/arm64`.
- Validate with `docker buildx bake --print` from `apps/bitmagnet/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/bitmagnet-io/bitmagnet"
ports:
  - port: 3333
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - name: postgresql
```

- Port 3333 is UNVERIFIED (draft-inferred). Do not merge with it unless the upstream or docs confirm it. The UDP 3334 DHT port is left out: forgetool probes are tcp/http only, and the draft's 3334/udp is UNVERIFIED.
- `dependencies: postgresql` (`apps/postgresql` exists). Hard dependency per the draft.
- DB env vars (`POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB` or the real names): UNVERIFIED. Add only the names the bitmagnet config reader actually uses, with the defaults the `postgresql` sibling sets (`POSTGRES_DB` default `MYPOSTGRESDB`, `POSTGRES_USER` default `MYPOSTGRESUSER`, `POSTGRES_PASSWORD` required in the sibling).

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail

mkdir -p /config /tmp/bitmagnet-cache
cd /config

export HOME=/config
export TMPDIR=/tmp

exec /app/bitmagnet/bitmagnet
```

- Idempotent; nothing is seeded. Writes only to `/config` and `/tmp`.
- DB credentials (UNVERIFIED names): apply from environment on every start, not written to files. Pass them to the process only.
- Listen address (UNVERIFIED): confirm the web server binds to `0.0.0.0` on port 3333. If it binds to localhost, the config knob must be set in `start.sh`.
- `exec` keeps the binary as PID 1 handoff target.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '3333'
http:
- port: '3333'
  path: /
filePaths:
- /app/bitmagnet/bitmagnet
- /start.sh
```

- Database narrowing: the protocol's exception applies only if all three criteria hold. A hard dependency on a DB is met (draft). "Will not start without the DB" is UNVERIFIED, and a full functional test with a sidecar DB is not feasible with the single-container suite. Decide after the run in section 11: if the process exits without the DB, apply the exception with the required comment `# narrowed: requires external postgresql; full functional test not feasible in single-container suite`. If it stays up and serves without a DB, no narrowing is needed.
- Probes must match only the ports confirmed in `settings.yaml`. Do not keep the http probe on `/` unless its status is confirmed.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Binary install in `/usr/bin` (upstream, root) | `/app/bitmagnet/bitmagnet` built into the image, read-only at runtime. |
| Config and state (none confirmed) | `HOME=/config`. Persistent state only if the app writes any: UNVERIFIED. |
| Temp and caches | `/tmp` (`TMPDIR=/tmp`). |
| Draft security expectations | Runs as `apps` (chart default 568), `readOnlyRootFilesystem` compatible with `--read-only --tmpfs /tmp`, not privileged, no extra persistence (draft). |

Upstream runs as root; this image does not.

## 10. Risks, caveats and open questions

- Version mismatch (blocker until decided): the draft's `v0.10.1` tag is not a stable GitHub release (only the prerelease `v0.10.1-beta.1` exists). Build `0.10.0` or find the correct release. The chart tag must match what this image ships.
- Ports 3333 and 3334 are unverified; `EXPOSE` and `settings.yaml` ports wait for confirmation (docs.bitmagnet.io was not fetched).
- DB variables, migrations on boot, and whether the app exits without a DB are UNVERIFIED. These decide the database narrowing in section 8.
- DHT crawler is CPU, memory and bandwidth heavy and needs inbound UDP to be useful (draft, inferred). The UDP port cannot be probed by forgetool tcp/http, so it is documented only in the PR.
- Upstream linux builds are `.apk` in the release; this plan uses tarballs (draft caveat avoided).
- No blockers beyond the version and the unverified facts above. arm64 tarball exists; not musl-only; no GPU or privileged needs.

## 11. Build and test steps

```sh
cd apps/bitmagnet
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

docker volume create bitmagnet-probe-config
docker run --rm -d --name bitmagnet-probe --read-only --tmpfs /tmp \
  -v bitmagnet-probe-config:/config bitmagnet:0.10.0
docker logs -f bitmagnet-probe      # check the process stays up and what it logs without a database

forgetool containers test --image bitmagnet:0.10.0 --config ./apps/bitmagnet/container-test.yaml

docker rm -f bitmagnet-probe
docker volume rm bitmagnet-probe-config
```

- Run a second pass with a real `postgresql` container (`apps/postgresql` image) on the same network to confirm the readiness line (UNVERIFIED wording) and migrations. Use that pass to resolve the narrowing question.
- Readiness signal: process alive, a listening or started line for port 3333 (UNVERIFIED), no fatal error.

## 12. PR checklist

- Branch `feat/add-bitmagnet`, commit `feat(bitmagnet): add new container`, PR title the same, target `main`.
- PR body uses `.github/PULL_REQUEST_TEMPLATE.md`; check only applicable boxes.
- Notes section contains `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` shows status).
- State untested items honestly: `v0.10.1` vs `0.10.0`, ports, DB variables, the narrowing decision, arm64 runtime.
- `docker buildx bake --print` passes; bake `VERSION` equals the Dockerfile `ARG VERSION`; no assertion weakened.
