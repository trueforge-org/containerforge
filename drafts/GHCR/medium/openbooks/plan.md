# openbooks — implementation plan
> Source: ./draft.md · Target: apps/openbooks/ · Difficulty: medium · Role (main) · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value | Source |
| --- | --- | --- |
| Latest release | v4.5.0, published 2023-01-08 (no newer release; draft tag 4.5.0 matches) | https://api.github.com/repos/evan-buss/openbooks/releases/latest |
| Renovate | UNVERIFIED: no renovate config checked for this repo. Planned: `datasource=github-releases depName=evan-buss/openbooks versioning=semver` (adguardhome-sync uses `datasource=github-releases depName=bakito/adguardhome-sync` without `versioning`) | — |
| License | MIT (SPDX `MIT`) | https://api.github.com/repos/evan-buss/openbooks/license |
| Source URL | https://github.com/evan-buss/openbooks | draft.md |
| amd64 download | https://github.com/evan-buss/openbooks/releases/download/v4.5.0/openbooks_linux (raw static Linux binary, no archive) | releases API above |
| arm64 download | None. `openbooks_linux_arm` exists but is 32-bit ARM (armv7), not aarch64. arm64 must be compiled | releases API above |
| Checksum source | None. No checksum assets are published for v4.5.0 | releases API above |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/evan-buss/openbooks/045410c2787860e3ce79ae66954e6c1723d185c1/Dockerfile: `FROM node:16 as web` (npm install + `npm run build` in `/web/server/app/`), `FROM golang as build` (`CGO_ENABLED=0`, `go install`, `go build` in `/go/src/cmd/openbooks/`), `FROM gcr.io/distroless/static as app` (copies only the binary to `/app`) | same |
| Upstream ENTRYPOINT | `["./openbooks", "server", "--dir", "/books", "--port", "80"]`, `EXPOSE 80`, `VOLUME ["/books"]`, no `USER`, no `CMD` | same |
| Port | Upstream listens on 80 (set by ENTRYPOINT flag). Draft says 8080 (inferred). Chart port UNVERIFIED (chart not fetched) | same |
| Downloads path | `--dir` flag (upstream `/books`). Draft's `/books/books` and `/books/logs` come from chart values, UNVERIFIED | same |
| Env vars | Upstream Dockerfile sets `BASE_PATH=/` and `CGO_ENABLED=0` (build only). No runtime env var list found in the fetched files: UNVERIFIED for any others | same |
| Dependencies | None. Downloads come from IRC networks and DCC; outbound IRC access needed (draft, UNVERIFIED) | draft.md |

## 2. Target layout

- `apps/openbooks/Dockerfile`
- `apps/openbooks/docker-bake.hcl`
- `apps/openbooks/settings.yaml`
- `apps/openbooks/container-test.yaml`
- `apps/openbooks/start.sh` (execs the server with `--dir /config/books`, `--port 8080`, `BASE_PATH` from env)

Not needed: `defaults/` (no seeded config), `etc/`, `health/`, `root/` (never used). No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for the final stage. The draft's "ubuntu alone is enough" is correct: the binary is static, so no runtime package is needed.

The arm64 build stage needs Go and Node. Use a separate build stage (`FROM` a Go image, version UNVERIFIED for this plan; pick the Go version from a sibling Go app or the go-runtime rules) and copy the output into the ubuntu final stage. Node for the web build: UNVERIFIED which Node major version works (upstream uses node:16, which is EOL). Plan to try node 22 LTS in the build stage and record the result.

Closest sibling: `apps/adguardhome-sync` (prebuilt binary in `/app`, `VOLUME /config`, `COPY --chmod=0755 . /`).

## 4. Dockerfile

Two paths in one file, selected by `TARGETARCH`:

1. `build-web` stage: Node, `npm ci && npm run build` on the upstream `web/server/app` folder (source from the tag, pinned by `ARG VERSION`).
2. `build-go` stage: Go, copies the source and the built web assets, `CGO_ENABLED=0 go build -o /out/openbooks ./cmd/openbooks`. Caches: `GOCACHE=/tmp/go-build`, `GOMODCACHE=/tmp/go-mod`.
3. Final ubuntu stage:
   - `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
   - amd64: `curl -fL -o /app/openbooks "https://github.com/evan-buss/openbooks/releases/download/v${VERSION}/openbooks_linux"`.
   - arm64: `COPY --from=build-go /out/openbooks /app/openbooks`.
   - Shell `case "$TARGETARCH" in amd64) ... ;; arm64) ... ;; esac` in a single `RUN` for amd64, and `COPY --from` for arm64 (use a `RUN` with `if` for the arm64 copy if `COPY --from` cannot be conditional).
   - License: upstream LICENSE file, copy to `/usr/share/licenses/openbooks/LICENSE` (fetch from the same tag in the build stage).
   - `chmod 0755 /app/openbooks && chown -R apps:apps /app`.
   - `ENV HOME=/config BASE_PATH=/`.
   - `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`, `WORKDIR /config`.

Note: `VERSION` in the amd64 URL is `v${VERSION}` for the GitHub tag. The asset name has no version in it, so the tag must be checked in the bake (VERSION `4.5.0`, URL uses `v4.5.0`).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "openbooks"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=evan-buss/openbooks versioning=semver
  default = "4.5.0"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/evan-buss/openbooks"
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

Validate with `docker buildx bake --print` from `apps/openbooks`. `VERSION` is `4.5.0`, matching the Dockerfile `ARG VERSION`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/evan-buss/openbooks"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: BASE_PATH
    default: "/"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

Port 8080 is a deliberate deviation from upstream's 80 (non-root cannot bind 80 without a capability). Only env vars the app reads are listed; `BASE_PATH` is set by the upstream Dockerfile, so it is kept only if the server reads it (UNVERIFIED, remove if not). `TZ` is a generic container var.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/books /config/logs

cd /config
exec /app/openbooks server \
  --dir /config/books \
  --port 8080
```

- Idempotent. Seeds nothing. Downloads go to `/config/books`. Logs go to `/config/logs` only if the server has a log flag (UNVERIFIED; check `openbooks server --help` in the probe run).
- Never writes to `/app`. No caches in `/config` (Go and Node caches are build-time only).
- Bind to all interfaces: server must listen on `0.0.0.0` or `:8080` (UNVERIFIED; check the probe log).
- `exec` for signal handling.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
filePaths:
- /app/openbooks
- /usr/share/licenses/openbooks/LICENSE
```

- `tcp` and `http` probes for the single declared port 8080.
- `filePaths` checks the binary and license. The server needs no env vars, so no required-env paths exist.
- `timeoutSeconds` 60 is an estimate; align with the closest Go sibling if one exists (UNVERIFIED).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/books` (`--dir`, VOLUME) | `--dir /config/books` in start.sh |
| `/books/logs` (chart PVC, UNVERIFIED) | `/config/logs` if the app has a log flag, else omitted |
| Go build caches | `/tmp` only, build stage only |
| Node/npm caches | `/tmp` only, build stage only |

Draft security expectations reconciled: the chart expects runAsUser 568 and no read-only rootfs. This image runs as `apps` (non-root) and is compatible with `--read-only --tmpfs /tmp`, which is stricter than the chart. No privileged mode. No extra capabilities needed for port 8080.

## 10. Risks, caveats and open questions

- No arm64 release binary. The arm64 build depends on the web build with Node. Upstream uses node:16 (EOL): UNVERIFIED that the web build works on a current Node. This is the main risk.
- Release is from 2023. No checksums. Pin by tag only, so the binary cannot be verified against a published checksum (UNVERIFIED alternative: compare the binary with a source build).
- Upstream port 80 vs planned 8080: confirm the chart's port mapping before merging.
- IRC/DCC needs outbound network and online IRC servers; the app is non-functional without them (external service, not testable in the container suite).
- `openbooks_linux_arm` is 32-bit; do not use it for `linux/arm64`.
- Blockers: none for amd64. arm64 is blocked until the compile path is verified.

## 11. Build and test steps

```sh
cd apps/openbooks
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name openbooks-probe --read-only --tmpfs /tmp \
  -v openbooks-probe-config:/config openbooks:4.5.0
docker logs -f openbooks-probe
forgetool containers test --image openbooks:4.5.0 --config ./apps/openbooks/container-test.yaml
docker rm -f openbooks-probe; docker volume rm openbooks-probe-config
```

Expected readiness signal: the server prints a listening line on port 8080 (exact text UNVERIFIED; take it from the first probe run) and the process stays up. Then build arm64 only if the amd64 path is green: `docker buildx bake --set image-local.platform=linux/arm64 image-local` (expected to be slow; record the result in the PR).

## 12. PR checklist

- Branch `feat/add-openbooks`, commit and PR title `feat(openbooks): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections and checkboxes, check only what applies.
- Notes section: `🤖 This PR is AI generated.` Do not add a "Generated with" or other tool attribution line (AGENTS.md).
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Tell the user; only the user can sign it; the `license/cla` check shows the status.
- State honestly what was not tested: arm64 build, IRC connectivity, the chart's port and PVC mapping, and the Renovate annotation (UNVERIFIED).
