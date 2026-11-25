# shapeshifter-obfuscator — implementation plan
> Source: ./draft.md · Target: apps/shapeshifter-obfuscator/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | Latest upstream tag `v3.0.1` (published 2022-06-30), tag commit `401e1869e211f3dfbf627cd5e4d327ad3f91ea67`. Source: https://api.github.com/repos/OperatorFoundation/shapeshifter-dispatcher/releases and `/tags`. Upstream publishes no release assets. |
| Draft differences | Draft pins nothing (git clone, no ref). Draft says "Foundation: ubuntu", but the upstream image `juchong/shapeshifter-docker` is built on `FROM alpine`. We do not copy that base, we build on ubuntu. Draft port 1234 is an inference; upstream Dockerfile says `EXPOSE 2222/tcp`. |
| Renovate | Proposed: `datasource=git-tags depName=https://github.com/OperatorFoundation/shapeshifter-dispatcher versioning=semver`. UNVERIFIED against a live renovate run. |
| License | MIT (GitHub license API, `spdx_id` MIT: https://api.github.com/repos/OperatorFoundation/shapeshifter-dispatcher/license) |
| Source URL | https://github.com/OperatorFoundation/shapeshifter-dispatcher |
| Download | None. Source only, compiled in our build stage. |
| Checksum source | Git tag commit SHA `401e1869e211f3dfbf627cd5e4d327ad3f91ea67` (GitHub API). No sha256 published. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/juchong/shapeshifter-docker/d2857ae/Dockerfile: `FROM alpine`, `ENV ARGS=`, `ADD run.sh /run.sh`, `apk add git go netcat-openbsd`, `ENV GOROOT=/usr/lib/go GOPATH=/go PATH=/go/bin:$PATH`, `git clone .../shapeshifter-dispatcher.git` (unpinned), `go build && go install`, `EXPOSE 2222/tcp`, `VOLUME /config`, `CMD /run.sh`, no USER (runs as root). |
| Upstream run.sh | UNVERIFIED: not fetched. Its argument mapping (`ARGS`) and the listener flags are not confirmed. |
| arm64 | Go source; compiles for arm64 with `GOARCH` from buildx. No upstream arm64 claim checked. UNVERIFIED for runtime. |
| Dependencies | None documented. |

## 2. Target layout

- `apps/shapeshifter-obfuscator/Dockerfile`
- `apps/shapeshifter-obfuscator/docker-bake.hcl`
- `apps/shapeshifter-obfuscator/settings.yaml`
- `apps/shapeshifter-obfuscator/container-test.yaml`
- `apps/shapeshifter-obfuscator/start.sh`

No `defaults/`, `etc/` or `root/`. `defaults/` is only needed if we ship a config template, which is UNVERIFIED until the dispatcher CLI is read. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

- Final stage: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` (from `apps/adguardhome-sync/Dockerfile`).
- Build stage: Go toolchain in a dedicated stage (`FROM golang:<ver> AS build`), per `go-runtime.instructions.md`. The Go version must be read from the `go` directive in the dispatcher's `go.mod` at `v3.0.1`, which is UNVERIFIED (not fetched). Pin the digest at build time.
- Closest sibling: `apps/adguardhome-sync` (prebuilt Go binary on ubuntu, same layout).

## 4. Dockerfile

1. `FROM golang:<ver> AS build`, `ARG VERSION`, `ARG TARGETARCH`.
2. `RUN git clone --depth 1 --branch "v${VERSION}" https://github.com/OperatorFoundation/shapeshifter-dispatcher /src` (pinned tag; never the default branch as upstream does).
3. Verify the checked-out commit equals `401e1869e211f3dfbf627cd5e4d327ad3f91ea67` for v3.0.1, or fail the build (`test "$(git -C /src rev-parse HEAD)" = "<sha>"`). Store the expected sha in a build ARG only if the version is bumped by renovate with the sha (UNVERIFIED design; simpler: check tag resolves to expected sha).
4. `ENV GOCACHE=/tmp/go-cache GOPATH=/tmp/go` and `RUN cd /src && CGO_ENABLED=0 go build -o /out/shapeshifter-dispatcher ./...` (exact package path UNVERIFIED; upstream used `go build && go install` in repo root, so the main package is at repo root).
5. Final stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:...`, `ARG VERSION`, `USER root`.
6. `COPY --from=build /out/shapeshifter-dispatcher /app/shapeshifter-dispatcher` and `COPY --from=build /src/LICENSE /usr/share/licenses/shapeshifter-obfuscator/LICENSE`.
7. `chown -R apps:apps /app && chmod -R 755 /app`.
8. `ENV HOME=/config`.
9. Tail (same as siblings):

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 2222
VOLUME /config
```

`EXPOSE` is provisional: the port is `2222` per upstream Dockerfile, and must match the chart value (UNVERIFIED).

No apt packages are needed in the final stage (`git` is only needed in the build stage; install it there and not in final).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "shapeshifter-obfuscator"
}

variable "VERSION" {
  // renovate: datasource=git-tags depName=https://github.com/OperatorFoundation/shapeshifter-dispatcher versioning=semver
  default = "3.0.1"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/OperatorFoundation/shapeshifter-dispatcher"
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

Validate with `docker buildx bake --print` from `apps/shapeshifter-obfuscator`. `VERSION` is `3.0.1`, so the Dockerfile tags it `v${VERSION}`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/OperatorFoundation/shapeshifter-dispatcher"
ports:
  - port: 2222
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

Env vars: none confirmed. The draft's chart env values are not verified, so do not add env names until `run.sh` (or the dispatcher's flags) is read. Port 2222 is from upstream `EXPOSE`. `dependencies`: none (no sibling is required).

## 7. start.sh

Design (provisional, UNVERIFIED until the dispatcher CLI is read):

```bash
#!/usr/bin/env bash

mkdir -p /config
cd /config
# The dispatcher's listener, key and config flags come from its CLI help, which
# must be read before writing this file. The key material must persist in /config,
# so a fresh /config generates a new key on first run and keeps it afterwards.
exec /app/shapeshifter-dispatcher <flags-from-cli-help>
```

Rules to apply: idempotent, no writes to `/app`, key material only in `/config`, bind `0.0.0.0`, `exec` the final process. The listen address must be `0.0.0.0` (the server is used from other containers).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '2222'
filePaths:
- /app/shapeshifter-dispatcher
- /usr/share/licenses/shapeshifter-obfuscator/LICENSE
```

A `tcp` probe on 2222 covers the only port. The dispatcher needs a client and bridge to exchange traffic, so the test only checks that the listener is open. If the listener refuses connections without a valid handshake, the probe still passes at TCP level; that is acceptable under the protocol. `filePaths` gets the binary and the license. `timeoutSeconds` is a reasonable default; compare with a Go sibling during the build.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/config` (VOLUME, upstream) | Kept as `/config`. |
| Draft chart state `/state` (pvc) | Remap to `/config`. The chart's `/state` is not the image's convention. |
| Go build cache (`GOCACHE`, `GOPATH`) | Build stage only, under `/tmp`. Not in the final image. |
| Runtime as root | Upstream has no USER; ours runs as `apps` (568) via `USER apps`. The dispatcher must listen on 2222 (unprivileged port, OK). |
| Draft security expectations | Chart runs UID 0 and `readOnlyRootFilesystem: false`. Our image is compatible with `--read-only --tmpfs /tmp` if the dispatcher writes only to `/config`. Verify in step 11. |

## 10. Risks, caveats and open questions

- Upstream source is unpinned in the old Dockerfile, and `v3.0.1` dates from 2022. Check the tag builds with current Go. Blocker if it does not.
- The dispatcher CLI flags, the key file location and the `run.sh` behaviour are UNVERIFIED. This blocks `start.sh` and `settings.yaml` env entries. Read `shapeshifter-dispatcher` CLI help from the built binary first.
- Chart port and listener port must match on both sides. Silent failure on mismatch (draft caveat, confirmed as a risk).
- Tor-style pluggable transport: useful only with a matching client and bridge elsewhere (draft caveat, inferred, not tested here).
- No arm64 evidence. Go compiles for arm64, so expect it to work, but it is UNTESTED.
- Draft says "Upstream publishes no release assets": confirmed.
- Blockers: none confirmed. Possible blocker: Go version in `go.mod` not matching any available `golang` image.

## 11. Build and test steps

```sh
cd apps/shapeshifter-obfuscator
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name shapeshifter-obfuscator-probe --read-only --tmpfs /tmp \
  -v shapeshifter-obfuscator-probe-config:/config shapeshifter-obfuscator:3.0.1
docker logs -f shapeshifter-obfuscator-probe
forgetool containers test --image shapeshifter-obfuscator:3.0.1 --config ./apps/shapeshifter-obfuscator/container-test.yaml
docker rm -f shapeshifter-obfuscator-probe; docker volume rm shapeshifter-obfuscator-probe-config
```

Expected readiness signal: the dispatcher's own "listening" line (UNVERIFIED wording; capture the real line from the first run) and port 2222 open. Also run once with a fresh `/config` volume, then restart with the same volume to confirm key persistence.

## 12. PR checklist

- Branch `feat/add-shapeshifter-obfuscator`, commit and PR title `feat(shapeshifter-obfuscator): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep sections, check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it; `license/cla` shows the status.
- Say what was not tested: the Go build on arm64, the runtime with a real client and bridge, the chart port, and the run.sh behaviour.
- `docker buildx bake --print` passes; `VERSION` in bake equals the `ARG VERSION` in the Dockerfile.
