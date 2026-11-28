# gatus — implementation plan
> Source: ./draft.md · Target: apps/gatus/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | v5.38.0, published 2026-10-28 (https://api.github.com/repos/TwiN/gatus/releases/latest). Matches the draft tag `ghcr.io/twin/gatus:v5.38.0`. |
| Renovate | `datasource=github-releases depName=TwiN/gatus versioning=semver` (proposed; not checked against renovate config). |
| License | Apache-2.0 (GitHub SPDX `Apache-2.0`, https://api.github.com/repos/TwiN/gatus). |
| Source URL | https://github.com/TwiN/gatus |
| Module | `github.com/TwiN/gatus/v5`, `go 1.26.3` (https://api.github.com/repos/TwiN/gatus/contents/go.mod). |
| Per-arch download | None. The release has zero assets. Build from the source tarball `https://github.com/TwiN/gatus/archive/refs/tags/v${VERSION}.tar.gz` (bake `VERSION` is `5.38.0` without the `v`) for amd64 and arm64. |
| Checksum source | None published on the release. The tarball is pinned by tag; verify the tag resolves to the expected commit (`d255d0cd4d69ce818574cfdb3a7e82407e6559d7` is the commit the draft traced, UNVERIFIED that v5.38.0 points at it). |
| Upstream Dockerfile reviewed | https://api.github.com/repos/TwiN/gatus/contents/Dockerfile?ref=d255d0cd4d69ce818574cfdb3a7e82407e6559d7 : `golang:alpine` builder, `CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o gatus .`, final `FROM scratch`, copies the binary to `/gatus`, `config.yaml` to `/config/config.yaml`, the CA bundle. `ENV GATUS_CONFIG_PATH=""`, `GATUS_LOG_LEVEL="INFO"`, `PORT="8080"`, `EXPOSE ${PORT}`, `ENTRYPOINT ["/gatus"]`. No `USER`, no `VOLUME`. |
| Port | 8080/tcp. The README config table gives `web.port` default `8080`. |
| Env vars (real, from README) | `GATUS_CONFIG_PATH` (config file, or a directory of `*.yaml`/`*.yml`), `GATUS_LOG_LEVEL` (`DEBUG`, `INFO`, `WARN`, `ERROR`, `FATAL`). Config files also expand `$VAR` and `${VAR}`. |
| Upstream `PORT` env | Set in the upstream Dockerfile and used for `EXPOSE`. Whether the binary reads it at runtime: UNVERIFIED (README documents `web.port` in the config file only). Do not list `PORT` in `settings.yaml` unless confirmed. |
| Data path | `storage.type` `memory` (default), `sqlite` or `postgres`. For `sqlite`, `storage.path` must be non-blank (README storage section). |
| Dependencies | `postgresql` is optional (ContainerForge `apps/postgresql` exists, so it is marked ✅). The `gatus-sidecar` is not ContainerForge (see section 10). |
| Sidecar license | `gatus-sidecar` (https://github.com/home-operations/gatus-sidecar) is AGPL-3.0, not part of this plan. |
| Architectures | amd64 and arm64 both compile from source. `CGO_ENABLED=0` gives a static binary. |
| Image copy source | `ghcr.io/twin/gatus:v5.38.0` is a scratch image. Its per-arch manifests were not inspected: UNVERIFIED. Copying from it is possible but this plan builds from source instead (section 4). |

## 2. Target layout

- `apps/gatus/Dockerfile`
- `apps/gatus/docker-bake.hcl`
- `apps/gatus/settings.yaml`
- `apps/gatus/container-test.yaml`
- `apps/gatus/start.sh`
- `apps/gatus/defaults/config.yaml` (seed for `/config/config.yaml` when missing; a minimal config with `web.port: 8080`, one example endpoint, and `storage.type: sqlite` with `storage.path: /config/data/gatus.db`)

No `etc/`, `health/` or `root/`. No `DOWNSTREAM_CHANGES.md` (gatus is not used as a `FROM` base). `defaults/` is needed because the config must be seeded into `/config` on first start, and `include/.dockerignore` allows `defaults/`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` for the final stage. The build stage is described in section 4.

Closest sibling: `apps/pwndrop` (ubuntu build stage, then runtime stage with `COPY --from=buildstage`). The brief's build-stage rule applies: Go is compiled in a stage and copied into the final stage.

## 4. Dockerfile

1. Build stage: `FROM <go-builder> AS buildstage` with `ARG VERSION` and `USER root`. Go version must satisfy `go 1.26.3`. The base is UNVERIFIED for this plan: use an official Go image tag that provides 1.26.x (for example `golang:1.26`-based, check the tag exists before pinning), or Ubuntu with a Go toolchain that is at least 1.26.3. Pin the digest once chosen.
2. In the build stage: `curl -fL "https://github.com/TwiN/gatus/archive/refs/tags/v${VERSION}.tar.gz" -o /tmp/gatus-src.tar.gz`, `tar xzf ... -C /tmp/gatus --strip-components=1`.
3. Set build caches to `/tmp`: `ENV GOCACHE=/tmp/go-cache GOMODCACHE=/tmp/go-mod`.
4. Build: `cd /tmp/gatus && CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /app/gatus/gatus .` (keeps the upstream `CGO_ENABLED=0` static build; `go mod tidy -diff` is a check only).
5. Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:...` with `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
6. `COPY --from=buildstage /app/gatus/gatus /app/gatus/gatus`. Upstream places the binary at `/gatus`; we keep it under `/app/gatus/` so `/app` stays read-only at runtime.
7. License: `COPY --from=buildstage /tmp/gatus/LICENSE /usr/share/licenses/gatus/LICENSE` (copied in the build stage or the final stage, as the file exists in the tarball).
8. `chown -R apps:apps /app/gatus && chmod -R 755 /app/gatus` (only if the binary is copied as root).
9. `ENV HOME=/config GATUS_LOG_LEVEL=INFO`. `GATUS_CONFIG_PATH` is set in `start.sh` (see section 7) and is not hard-coded here.
10. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
WORKDIR /app/gatus
```

`/config/data` is created by `start.sh` before the first start (sqlite file path, section 6).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "gatus"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=TwiN/gatus versioning=semver
  default = "5.38.0"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/TwiN/gatus"
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
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
```

Renovate note: `VERSION` is `5.38.0` (no `v`), so the Dockerfile must prefix `v` when it builds the tag URL (`refs/tags/v${VERSION}.tar.gz`). Use `${VERSION}` in the URL with the `v` added explicitly. Validate with `docker buildx bake --print` in `apps/gatus/`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/TwiN/gatus"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - name: GATUS_CONFIG_PATH
    default: "/config/config.yaml"
    required: false
  - name: GATUS_LOG_LEVEL
    default: "INFO"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
opt_dependencies:
  - name: postgresql   # ✅ apps/postgresql exists
```

`GATUS_CONFIG_PATH` is read by the binary (README). Its default matches `start.sh`. `postgresql` is optional only, so it is not a hard `dependencies` entry. `opt_dependencies` with `- name:` entries follows `apps/babybuddy/settings.yaml`.

## 7. start.sh

```bash
#!/bin/sh
set -eu

CONFIG_FILE="${GATUS_CONFIG_PATH:-/config/config.yaml}"

mkdir -p /config/data
if [ ! -s "${CONFIG_FILE}" ]; then
  echo "Seeding default config to ${CONFIG_FILE}"
  cp /defaults/config.yaml "${CONFIG_FILE}"
fi

export GATUS_CONFIG_PATH="${CONFIG_FILE}"
echo "Starting gatus with config ${GATUS_CONFIG_PATH}"
exec /app/gatus/gatus
```

- Idempotent: the seed runs only when the file is missing or empty; existing user config is never overwritten.
- Nothing writes to `/app`. The sqlite file is under `/config/data`.
- `exec` hands PID 1 to the binary.
- The binary binds to the `web.port` in the config (8080). The seeded config sets `web.address: 0.0.0.0` (verify the key name against the README before shipping; UNVERIFIED key name in this plan).
- Default config is copied from `defaults/config.yaml`; check that `/defaults/` is the path the `COPY . /` step produces (it is, because `.` is the app folder).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '8080'
http:
- port: '8080'
  path: /health
```

- Every port in `settings.yaml` has a probe (8080).
- `timeoutSeconds`: use the sibling value (check `apps/bazarr/container-test.yaml`).
- Test runs without env vars. The default config is seeded, so the default path is tested. `filePaths` should include `/config/config.yaml` and `/app/gatus/gatus` (existence checks).
- `/health` is the gatus health endpoint path; confirm in the README before shipping (UNVERIFIED in this plan; if it is not documented, use only the `tcp` probe).

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as root with a scratch image. Our final stage runs as `apps` (`USER apps`). The binary needs no privileges and binds to 8080 (above 1024).
- Read-only rootfs: `/app` is not written at runtime. The config and sqlite data go to `/config`. Go caches are in `/tmp` at build time only.
- Upstream chart security expectations (from the draft, `charts/stable/gatus`): non-root (runAsUser 568), readOnlyRootFilesystem true, privileged false. These match this plan.
- Draft other-security: the chart sets pod sysctl `net.ipv4.ping_group_range "0 2147483647"` so ICMP checks work unprivileged. Not reproducible in the image; document that users running ICMP endpoints must set it (or `CAP_NET_RAW`) at runtime. UNVERIFIED which gatus needs.
- Extra persistence: none beyond `/config`. The draft's sidecar pvc is out of scope.
- Upstream `PORT` env is ignored unless confirmed (section 1).

## 10. Risks, caveats and open questions

- Go toolchain: `go 1.26.3` needs a matching build-stage image. Confirm the chosen tag exists and pin its digest; if only older Go is available, the build will fail and the plan must be revisited.
- Sidecar: the chart's `gatus-sidecar` (https://github.com/home-operations/gatus-sidecar, AGPL-3.0) has no ContainerForge app. Drop it from this container. The sidecar is a separate app, if wanted later.
- Config: the user must write monitor definitions in `/config/config.yaml`. The seeded default only proves that the process starts.
- `web.address` and the `/health` path are unverified in this plan. Check both against the upstream README before the build.
- `PORT` env handling is unverified (see section 1).
- No blockers for amd64 or arm64: pure Go, `CGO_ENABLED=0`.

## 11. Build and test steps

From `apps/gatus/`:

```sh
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name gatus-probe --read-only --tmpfs /tmp \
  -v gatus-probe-config:/config gatus:5.38.0
docker logs -f gatus-probe
docker rm -f gatus-probe; docker volume rm gatus-probe-config
forgetool containers test --image gatus:5.38.0 --config ./apps/gatus/container-test.yaml
```

Expected readiness signal: the log line that gatus prints on start (confirm the exact text on the first run and record it here). The container must still be running after startup.

Run once with an empty `/config` and once more on a restart with the same volume.

## 12. PR checklist

- Branch: `feat/add-gatus`.
- Commit: `feat(gatus): add new container`.
- PR title: `feat(gatus): add new container`.
- PR description: Notes section contains `🤖 This PR is AI generated.`, uses `.github/PULL_REQUEST_TEMPLATE.md`, and only checked boxes that apply.
- CLA: tell the user the PR needs a signed CLA at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- Untested: arm64 build and the upstream `/health` probe until built; say so in the PR if not run.
- Checklist: bake print passes, image-local amd64 builds, container starts read-only with empty `/config`, `container-test.yaml` passes, no assertion weakened.
