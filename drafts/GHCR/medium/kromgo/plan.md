# kromgo — implementation plan
> Source: ./draft.md · Target: apps/kromgo/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `0.16.4` (GitHub release `0.16.4`, published 2026-11-13; tag has no `v` prefix). Matches the draft's chart image `ghcr.io/home-operations/kromgo:0.16.4`. |
| Renovate | `datasource=github-releases depName=home-operations/kromgo versioning=semver` (UNVERIFIED: renovate config of upstream not read; this is the standard pattern used by `apps/adguardhome-sync`). |
| License | AGPL-3.0 (GitHub SPDX `AGPL-3.0`, `gh api repos/home-operations/kromgo`). Exact `-only`/`-or-later` suffix UNVERIFIED; confirm against the LICENSE file before setting `LICENSE`. |
| Source URL | https://github.com/home-operations/kromgo |
| Download | No release assets. Source tarball `https://github.com/home-operations/kromgo/archive/refs/tags/${VERSION}.tar.gz`. Binary is compiled here for amd64 and arm64. |
| Per-arch | `compile` on both (no prebuilt executable upstream). |
| Checksum source | None published for the release or the tag archive. Plan: pin the tarball SHA-256 as a Dockerfile `ARG` computed once by the maintainer (UNVERIFIED value, must be computed at implementation time). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/home-operations/kromgo/5a14ed14fff8/Dockerfile. Three stages: `assets` on `node:${NODE_VERSION}-alpine` (`pnpm install --frozen-lockfile`, `go run ./cmd/genassets`); `builder` on `golang:${GO_VERSION}-alpine` (`go mod download`, `CGO_ENABLED=0 go build -ldflags "-s -w -X main.Version=${VERSION} -X main.Gitsha=${REVISION}" -trimpath -o /out/kromgo ./cmd/kromgo`); final `gcr.io/distroless/static:nonroot` with `ENTRYPOINT ["/kromgo"]`, no USER, no VOLUME, no ENV, `EXPOSE 8080/tcp 8081/tcp`. |
| Go requirement | `go.mod`: `module github.com/home-operations/kromgo`, `go 1.27.0` (gh api contents, ref 5a14ed14fff8). |
| Node/pnpm requirement | `package.json` (name `kromgo-assets`, Apache-2.0), `PNPM_VERSION` is a build ARG upstream (value UNVERIFIED). |
| Ports | Upstream `EXPOSE 8080/tcp 8081/tcp`. Draft's `8888` (metrics) is NOT confirmed by the Dockerfile and is dropped unless proven. |
| Env vars | UNVERIFIED: none confirmed. Upstream Dockerfile sets no ENV. Config and env names live in upstream README/config docs, not fetched. |
| Config path | Draft says `/config/config.yaml` (from the TrueCharts chart, not upstream). Upstream: UNVERIFIED how the binary locates its config (flag or env). |
| Dependencies | Prometheus endpoint, external and runtime-only (draft). Not a ContainerForge app. |

## 2. Target layout

- `apps/kromgo/Dockerfile`
- `apps/kromgo/docker-bake.hcl`
- `apps/kromgo/settings.yaml`
- `apps/kromgo/container-test.yaml`
- `apps/kromgo/start.sh` (exec the binary; no seeding needed unless upstream needs a default config, UNVERIFIED)

No `defaults/`: nothing is seeded (the operator writes `config.yaml`). No `etc/`, `health/` or `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

- Build stage and final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` (copied from `apps/hishtory-server/Dockerfile`, which builds a Go binary on this base and copies it into the final stage).
- Closest sibling: `apps/hishtory-server` (Go built in an ubuntu `AS builder` stage, `COPY --from=builder`).
- Go toolchain: `apps/ubuntu/docker-bake.hcl` sets `GO_VERSION` default `1.27.4`. `apps/ubuntu/Dockerfile` is single-stage and installs that Go (from dl.google.com, `GO_VERSION`) into the image, as `apps/hishtory-server` relies on, so the builder stage has it. Implementer must still check `go version` inside the builder and confirm it is `>= 1.27.0`.
- Node.js for the assets stage: `apps/ubuntu/Dockerfile` installs Node (`NODE_VERSION`, default 26.13.1 in `apps/ubuntu/docker-bake.hcl`, SHASUMS-verified) into `/usr/local`, so the builder stage has it; check that it satisfies the upstream pnpm lockfile needs (UNVERIFIED). Do not use the alpine images.

## 4. Dockerfile

1. Build stage `FROM <ubuntu> AS builder`, `ARG VERSION`, `ARG TARGETARCH`, `ARG KROMGO_SHA256` (pinned tarball checksum, UNVERIFIED value), `USER root`.
2. `apt-get install -y --no-install-recommends ca-certificates curl` (only what the base lacks; check first).
3. Node is already in the base (see section 3); then `npm install --global --ignore-scripts pnpm@<PNPM_VERSION>` with the version pinned as an ARG (value to be taken from upstream `Dockerfile` ARG default, UNVERIFIED).
4. `curl -fL -o /tmp/kromgo.tar.gz https://github.com/home-operations/kromgo/archive/refs/tags/${VERSION}.tar.gz`, then `echo "${KROMGO_SHA256}  /tmp/kromgo.tar.gz" | sha256sum -c -`, then `mkdir -p /build/kromgo && tar xzf /tmp/kromgo.tar.gz -C /build/kromgo --strip-components=1`.
5. In `/build/kromgo`: `pnpm install --frozen-lockfile` (with `STORE_DIR=/tmp/pnpm-store`), `go run ./cmd/genassets`. Env: `GOPATH=/tmp/go GOCACHE=/tmp/go-build GOMODCACHE=/tmp/go/pkg/mod`.
6. `CGO_ENABLED=0 go build -ldflags "-s -w -X main.Version=${VERSION}" -trimpath -o /out/kromgo ./cmd/kromgo`. Upstream also injects `main.Gitsha`; the tarball has no git history, so omit it (UNVERIFIED that `Gitsha` is required at runtime).
7. Final stage `FROM <ubuntu>`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`:
   - `COPY --from=builder /out/kromgo /app/kromgo` and `chown apps:apps /app/kromgo && chmod 0755 /app/kromgo`.
   - License: `COPY --from=builder /build/kromgo/LICENSE /usr/share/licenses/kromgo/LICENSE`.
8. `ENV HOME=/config` (matches `apps/adguardhome-sync`), no ENV for caches in the final stage.
9. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080 8081
VOLUME /config
```

`EXPOSE` lists both upstream ports. The build stage keeps its caches in `/tmp` only.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "kromgo"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=home-operations/kromgo versioning=semver
  default = "0.16.4"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/home-operations/kromgo"
}
```

`group "default"`, `target "image"`, `image-local`, `image-all` copied from `apps/adguardhome-sync/docker-bake.hcl`. `image` passes `args = { VERSION = "${VERSION}" }` and the two OCI labels. Validate with `docker buildx bake --print`. If Node or pnpm versions are ARGs, add matching `variable` defaults with renovate annotations (`datasource=docker depName=docker.io/library/node` or the pnpm github-releases equivalent).

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/home-operations/kromgo"
ports:
  - port: 8080
    protocol: tcp
    required: false
  - port: 8081
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Env: only `TZ` is listed, because no upstream env var is confirmed (see section 1). Add more only after the upstream README/source is read. `dependencies: []`: Prometheus is external, not a ContainerForge app. Port 8081 is included because upstream `EXPOSE` lists it; it is not confirmed as a served port (UNVERIFIED). Confirm ports from upstream source before committing.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config

cd /config
exec /app/kromgo
```

Idempotent. Seeds nothing (`cp -n` only if upstream ships a default config, which is UNVERIFIED). No writes to `/app`. Config flag/env name to be filled in once upstream is confirmed (UNVERIFIED). `exec` keeps PID 1 signal handling.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '8080'
- port: '8081'
filePaths:
- /app/kromgo
- /usr/share/licenses/kromgo/LICENSE
```

Every `settings.yaml` port has a `tcp` probe. `timeoutSeconds` value taken from `apps/adguardhome-sync` family (UNVERIFIED; adjust to sibling Go apps). Risk: `kromgo` may exit without a `config.yaml` and a Prometheus endpoint; the test runs with no env and no config, so this must be checked during the run step (section 11) before the tcp probes are trusted.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Go build cache, module cache, pnpm store (build stage only) | `/tmp/go-build`, `/tmp/go`, `/tmp/pnpm-store` |
| Runtime writes | UNVERIFIED: none expected; binary is stateless. Check logs on `--read-only`. |
| Config | `/config` (operator-managed). Not written by the app. |

Upstream runs as distroless `:nonroot` (UID 65532). ContainerForge runs as `apps`, and the chart uses `runAsUser 568`, which aligns with `apps`. `readOnlyRootFilesystem` is compatible: `/app` is read-only and the app writes nothing. Not privileged.

## 10. Risks, caveats and open questions

- Ports: draft listed 8888 (metrics); upstream `EXPOSE` lists 8080 and 8081 only. 8888 dropped.
- Startup without config: UNVERIFIED whether `kromgo` runs without a `config.yaml` and a reachable Prometheus. If it exits, the protocol's "still running" criterion fails and this is a blocker, not a DB exception (no DB dependency). Resolve before the test is written.
- Go version: upstream `go 1.27.0`. Build stage must have Go >= 1.27.0 (ubuntu bake default 1.27.4). Verify.
- Node/pnpm inside the build stage: assets are required by `cmd/genassets`; Node comes from the ubuntu base, pnpm must be pinned.
- `Gitsha` omitted: the tarball has no `.git`. Version string reports `0.16.4` only.
- Config format tied to the 0.16.x line; a future bump may change the schema.
- No arm64 run validated; `compile` on both architectures.
- Chart `settings`: `config.yaml` at `/config/config.yaml` is from the TrueCharts chart (not upstream); confirm the upstream default path.

Blockers: none confirmed yet. Gating item is the startup-without-config question.

## 11. Build and test steps

```sh
cd apps/kromgo
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name kromgo-probe --read-only --tmpfs /tmp \
  -v kromgo-probe-config:/config kromgo:0.16.4
docker logs -f kromgo-probe
forgetool containers test --image kromgo:0.16.4 --config ./apps/kromgo/container-test.yaml
docker rm -f kromgo-probe; docker volume rm kromgo-probe-config
```

Expected readiness signal: an HTTP listen line on 8080 (exact text UNVERIFIED, to be read from upstream source). The container must stay running with an empty `/config`.

## 12. PR checklist

- Branch `feat/add-kromgo`, commit and PR title `feat(kromgo): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required at https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it; the `license/cla` check shows the status.
- Untested to state honestly: the build on arm64, the runtime on `--read-only` with a real Prometheus, the probe results, the tarball checksum value.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
