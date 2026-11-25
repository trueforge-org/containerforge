# nullserv — implementation plan
> Source: ./draft.md · Target: apps/nullserv/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No release confirmed. `https://api.github.com/repos/bmrzycki/nullserv/releases/latest` returned HTTP 404. The draft's `v1.3.0` is UNVERIFIED. The upstream master Dockerfile is reachable, so the repo exists in some form. Pin a commit SHA instead of a tag (see section 10). |
| Chart image | `ghcr.io/k8s-at-home/nullserv:v1.3.0@sha256:0792c7e6d814bf292455da3f40aa5d56c465f2b5024e786ac3bf3dc3b16cc757` (TrueCharts values.yaml, https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/nullserv/values.yaml). The k8s-at-home image is not checked for arm64 (UNVERIFIED). |
| Renovate | `datasource=git-refs depName=https://github.com/bmrzycki/nullserv currentValue=master` (same pattern as `apps/tvheadend`, see `drafts/Docker Hub/medium/fenrus/plan.md`). |
| License | UNVERIFIED: LICENSE file not fetched. Check the repo root before writing the bake file. |
| Source URL | https://github.com/bmrzycki/nullserv |
| Download | None: no prebuilt binary is published (draft). Compile from source in a build stage. |
| Checksum source | None published. The source is pinned by commit SHA (content-addressed). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/bmrzycki/nullserv/master/Dockerfile . `FROM golang:alpine AS build-env`, `WORKDIR /go/src/app`, `COPY . .`, `RUN ./mkbuildinfo.sh && CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-w -extldflags "-static"' -o nullserv *.go`, `FROM scratch`, `COPY --from=build-env /go/src/app/nullserv /`, `ENTRYPOINT ["/nullserv"]`. No USER, EXPOSE, ENV or CMD. |
| Ports | Chart: service `main` port 10004 to targetPort 80; service `https` port 10005 to targetPort 443. The container port numbers 80 and 443 come from the chart (UNVERIFIED that the binary listens there). The draft's 8080 is contradicted by the chart. |
| Env vars | None found in the Dockerfile. Any flag or env the Go code reads is UNVERIFIED (source `*.go` not fetched). |
| Data path | Chart mounts `/config` (persistence `config`). The binary's own writes are UNVERIFIED. |
| Chart security | `runAsNonRoot: false`, `runAsUser: 0`, `runAsGroup: 0` (matches the draft). |

## 2. Target layout

- `apps/nullserv/Dockerfile`
- `apps/nullserv/docker-bake.hcl`
- `apps/nullserv/settings.yaml`
- `apps/nullserv/container-test.yaml`
- `apps/nullserv/start.sh` (only if a wrapper is needed for the port; otherwise `exec` the binary from the image command)

No `defaults/`, `etc/` or `health/` needed. No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

Build stage: `FROM docker.io/library/golang:<pinned-version>@sha256:<digest>` (an official Go builder, used as a dedicated build stage, per the go-runtime rule). Use the Go version from `apps/ubuntu/docker-bake.hcl` (`GO_VERSION` is `1.27.4` there) and a `golang` digest that the other ContainerForge Go builds use (see `apps/dexafix`, which is the closest Go sibling; its Dockerfile copies a prebuilt binary and does not compile, so copy only the stage layout, not the download). The digest is UNVERIFIED: resolve it with `docker buildx imagetools inspect` before writing.

Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` (the same digest `apps/valkey` and `apps/adguardhome-sync` use). Reason: the upstream `scratch` image has no user and no `/config` owner; the ContainerForge base gives `apps` and writable `/config`. Upstream's static binary runs on glibc Ubuntu because `CGO_ENABLED=0`.

## 4. Dockerfile

1. `FROM docker.io/library/golang:<pinned> AS build`, `ARG VERSION`, `WORKDIR /go/src/app`.
2. Fetch the source at the pinned commit: `RUN curl -fL https://github.com/bmrzycki/nullserv/archive/${VERSION}.tar.gz | tar xz -C /go/src/app --strip-components=1`. `VERSION` is a commit SHA (40 hex characters, see section 5). Do not fetch `master` at build time.
3. Build exactly as upstream does: `RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags '-w -extldflags "-static"' -o /out/nullserv *.go`. The `mkbuildinfo.sh` step runs only if the file exists in the archive (UNVERIFIED that it is needed).
4. Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`, `ARG VERSION`, `USER root`.
5. `COPY --from=build /out/nullserv /app/nullserv` and `COPY --from=build /go/src/app/LICENSE /usr/share/licenses/nullserv/LICENSE` (only if the LICENSE file exists: UNVERIFIED).
6. `chown -R apps:apps /app && chmod -R 755 /app`.
7. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE <port from section 10>
VOLUME /config
```

`ARG VERSION` must match the `VERSION` default in `docker-bake.hcl`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "nullserv"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/bmrzycki/nullserv currentValue=master
  default = "<40-character commit SHA from master, resolved at build time>"
}

variable "LICENSE" {
  default = "<SPDX id from the upstream LICENSE file, UNVERIFIED>"
}

variable "SOURCE" {
  default = "https://github.com/bmrzycki/nullserv"
}
```

Then the `group "default"`, `target "image"`, `target "image-local"` and `target "image-all"` blocks copied verbatim from `apps/adguardhome-sync/docker-bake.hcl`. Fill `VERSION` with the commit SHA of `master` at the time of the PR (resolve it with `gh api repos/bmrzycki/nullserv/commits/master --jq .sha`; this is a read-only GET). Validate with `docker buildx bake --print` from `apps/nullserv`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/bmrzycki/nullserv"
ports:
  - port: <port from section 10>
    protocol: tcp
    required: false
env: []
volumes:
  - path: /config
    required: true
```

`env` is empty: no variable is confirmed (section 1). Add one only if the source shows it is read. `/config` is listed because the chart persists it, but the binary may not write there; if the source shows no state, drop the volume and record why in section 10.

## 7. start.sh

Not needed when the binary takes its port from a flag or env var that is set in the Dockerfile (`ENTRYPOINT ["/app/nullserv"]` with `CMD` for the flag). If a wrapper is needed for the port default, use:

```bash
#!/usr/bin/env bash

cd /app
exec /app/nullserv "$@"
```

Keep it idempotent: no writes to `/app`, no `/config` seeding (none needed while the app keeps no state). Listen on all interfaces; the binary's default bind address is UNVERIFIED.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 30
tcp:
- port: '<port from section 10>'
filePaths:
- /app/nullserv
```

Every port in `settings.yaml` needs a `tcp` probe (section 6). If the chart's second port (443) is confirmed, add a second `tcp` probe for it. `timeoutSeconds` is a placeholder: copy a sibling Go value (`apps/dexafix` has none; choose a value that the small static binary needs, and confirm it on the first run). An http probe is added only if the source shows an HTTP handler (UNVERIFIED).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| None found in the Dockerfile (scratch, no volumes). | Nothing to remap. |
| Chart `config` at `/config` | Keep as the only writable path; the binary is not known to write it. |
| Port binding on 80/443 | Non-root (`apps`) cannot bind below 1024 by default. Use a high port (see section 10). |

Draft expectations reconciled: chart runs as UID 0 (`runAsUser: 0`); this image runs as `apps` (568). `readOnlyRootFilesystem` is `true` in the chart and `privileged` is `false`: both are compatible with the plan, as the binary writes nothing. Verify with `--read-only --tmpfs /tmp` in section 11.

## 10. Risks, caveats and open questions

- **Version (blocker for the bake file):** no release exists (404). Use a pinned commit SHA. The draft's `v1.3.0` tag and the k8s-at-home image digest cannot be confirmed from the upstream source. Decide with the maintainer whether a commit-based app is acceptable (renovate bumps on every master push, noisy).
- **Port (decision needed):** the chart maps 80 and 443. Non-root cannot bind those. Read the `*.go` source at the pinned SHA and choose a high port (for example 8080 or 8443) if the port is configurable; if it is hard-coded to 80/443, this is a blocker for rootless and needs a `setcap` or a different design, which is out of scope here.
- **Chart vs draft:** the draft's port 8080 is wrong per the chart; the chart uses 80/443. Treat the draft port as UNVERIFIED.
- **Upstream removal:** the draft says the repo was removed. The Dockerfile at master was fetched, so the repo is reachable. The releases API is 404. Re-check the repo status before the PR.
- **License:** UNVERIFIED. The bake `LICENSE` label must match the upstream LICENSE file.
- **Behaviour:** the draft says clients must be pointed at the server by hand (DNS or resolver), so the test can only prove that the server listens, not that it answers clients (see the tcp note in `.github/instructions/container-test.instructions.md`).
- No blockers from musl (the build uses `CGO_ENABLED=0` on glibc Ubuntu), no GPU, no privileged need. arm64 is compiled natively by buildx.

## 11. Build and test steps

```sh
cd apps/nullserv
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name nullserv-probe --read-only --tmpfs /tmp \
  -v nullserv-probe-config:/config nullserv:<commit-sha>
docker logs -f nullserv-probe
forgetool containers test --image nullserv:<commit-sha> --config ./apps/nullserv/container-test.yaml
docker rm -f nullserv-probe; docker volume rm nullserv-probe-config
```

Expected readiness signal: the binary's listen log line for the chosen port (UNVERIFIED wording) and a listening socket on that port. The first start with an empty `/config` must succeed. Check the port from outside the container (`-p <host>:<port>`) to confirm it binds `0.0.0.0`, not localhost.

## 12. PR checklist

- Branch `feat/add-nullserv`, commit and PR title `feat(nullserv): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only the boxes that apply.
- Notes section contains `🤖 This PR is AI generated.`
- CLA notice: the contribution needs a signed CLA (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; the `license/cla` check shows the status.
- Say in the PR what is not tested: the port decision, the arm64 build, the release status (no tagged release exists), client-side DNS behaviour.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
