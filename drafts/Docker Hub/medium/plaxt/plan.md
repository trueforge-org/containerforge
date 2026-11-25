# plaxt — implementation plan
> Source: ./draft.md · Target: apps/plaxt/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No GitHub releases (`releases/latest` returns 404). Pin the commit fetched: `1607349dea8ce7fb3b8e7ccfb0370d8103d31d61` (committed 2024-11-13). Chart uses mutable `xanderstrike/goplaxt:latest`, which is that same push (Docker Hub last pushed 2024-11-13). |
| Renovate | UNVERIFIED for this repo (no releases). Use `// renovate: datasource=git-refs depName=https://github.com/XanderStrike/goplaxt currentValue=master` (precedent `apps/fenrus` plan; confirm against the existing repo convention before writing). |
| License | MIT (https://api.github.com/repos/XanderStrike/goplaxt/license, LICENSE.txt) |
| Source URL | https://github.com/XanderStrike/goplaxt |
| Download | Source tarball `https://github.com/XanderStrike/goplaxt/archive/${VERSION}.tar.gz` with VERSION = commit SHA. No release binary. |
| Checksum source | None published. The tarball is pinned by commit SHA (content-addressed). |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/XanderStrike/goplaxt/1607349dea8ce7fb3b8e7ccfb0370d8103d31d61/Dockerfile-amd64. Builder `FROM golang:1.12.7-alpine`, `RUN GO111MODULE=on CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /out/goplaxt-docker`; final `FROM scratch`, `ENTRYPOINT ["/app/goplaxt-docker"]`, no USER, `EXPOSE 8000`, `VOLUME /app/keystore/`, no ENV, static files in `./static`. |
| Env vars | None defined in the Dockerfile. UNVERIFIED: Trakt client ID, client secret and redirect URL names (the goplaxt source config was not fetched). |
| Ports | 8000 (EXPOSE). Matches the draft. |
| Data path | `/app/keystore/` (VOLUME upstream). Must persist (draft). |
| arm64 | No arm64 image published; Docker Hub `xanderstrike/goplaxt:latest` shows amd64 only (https://hub.docker.com/v2/repositories/xanderstrike/goplaxt/tags). Upstream hard-codes `GOARCH=amd64`, so arm64 needs `GOARCH` from `TARGETARCH`. |
| copy-from | no (upstream image is scratch with a Go static binary built for amd64 only; it is not an arm64 image, and it is not built on ubuntu. Source build is the path). |

## 2. Target layout

- `apps/plaxt/Dockerfile`
- `apps/plaxt/docker-bake.hcl`
- `apps/plaxt/settings.yaml`
- `apps/plaxt/container-test.yaml`
- `apps/plaxt/start.sh` (creates keystore dir in `/config`, then `exec`s the binary)

No `defaults/`, `etc/`, `health/` needed. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for both the build stage and the runtime stage (runtime image: none, the draft says ubuntu alone is enough). Closest sibling: `apps/pwndrop` (Go built with `golang-go` from apt in a `buildstage`, then `COPY --from=buildstage` into the ubuntu runtime).

Go-runtime rules apply: compile in a dedicated build stage, copy the binary into the runtime stage, `GOCACHE=/tmp/go-cache`, never compile in the runtime stage.

## 4. Dockerfile

1. `FROM <ubuntu> AS buildstage`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. `apt-get install -y --no-install-recommends golang-go ca-certificates curl` (Go toolchain from the Ubuntu 26.04 archive; UNVERIFIED which Go version this gives. The upstream `go.mod` must build with it: check the `go` directive in `go.mod` at the pinned commit before the first build).
3. `ENV GOCACHE=/tmp/go-cache GOPATH=/tmp/go GOFLAGS=-mod=mod`.
4. `curl -fL "https://github.com/XanderStrike/goplaxt/archive/${VERSION}.tar.gz" -o /tmp/plaxt.tar.gz && tar xzf /tmp/plaxt.tar.gz -C /tmp/src --strip-components=1`.
5. `cd /tmp/src && CGO_ENABLED=0 GOOS=linux GOARCH=${TARGETARCH} go build -ldflags="-s -w" -o /out/plaxt .` (main package path to confirm in the source tree; the upstream Dockerfile names `goplaxt-docker`, built from the repo root).
6. Runtime stage: `FROM <ubuntu>`, `ARG VERSION`, `USER root`, `mkdir -p /app/plaxt/static /usr/share/licenses/plaxt`, `COPY --from=buildstage /out/plaxt /app/plaxt/plaxt`, `COPY --from=buildstage /tmp/src/static /app/plaxt/static`, `COPY --from=buildstage /tmp/src/LICENSE.txt /usr/share/licenses/plaxt/LICENSE`. Licence file is from the same pinned source.
7. `chown -R apps:apps /app/plaxt && chmod -R 755 /app/plaxt`.
8. `ENV HOME=/config`, `ENV GOCACHE` is not needed at runtime.
9. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8000

VOLUME /config
WORKDIR /config
```

The keystore moves to `/config` (see section 9); upstream `VOLUME /app/keystore/` is not kept as-is.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "plaxt"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/XanderStrike/goplaxt currentValue=master
  default = "1607349dea8ce7fb3b8e7ccfb0370d8103d31d61"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/XanderStrike/goplaxt"
}
```

Four standard targets and `group "default"` as in `apps/adguardhome-sync/docker-bake.hcl`. `VERSION` is a commit SHA, so the renovate comment uses `git-refs`; the Dockerfile `ARG VERSION` must match. Run `docker buildx bake --print` from `apps/plaxt`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/XanderStrike/goplaxt"
ports:
  - port: 8000
    protocol: tcp
    required: false
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
```

No `dependencies:` (none in draft). Trakt client ID and secret env names are UNVERIFIED, so they are not listed until read from the source config. Do not invent them.

## 7. start.sh

```bash
#!/usr/bin/env bash

mkdir -p /config/keystore

cd /app/plaxt
exec /app/plaxt/plaxt
```

Idempotent: creates the keystore directory only if missing (keystore content is never overwritten). Writes only under `/config`; nothing written to `/app`. Keystore path mapping (`/app/keystore/` upstream to `/config/keystore`) is UNVERIFIED against the binary's hard-coded path: check the source for the keystore path before the first run. If the binary hard-codes `/app/keystore`, a symlink at build time (`ln -s /config/keystore /app/plaxt/keystore`) is the fallback; the symlink must exist in the image (not created at runtime in `/app`).

The server must bind `0.0.0.0:8000`; confirm the bind address in the source (UNVERIFIED).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json
timeoutSeconds: 120
tcp:
- port: '8000'
http:
- port: '8000'
  path: /
filePaths:
- /app/plaxt/plaxt
- /app/plaxt/static
- /usr/share/licenses/plaxt/LICENSE
```

Timeout: 120 (a small Go service). The `/` probe must return a response without Trakt credentials (UNVERIFIED that `/` returns 200; if not, use the status the app returns and keep the assertion real). Test runs with no env vars, so the code that needs Trakt credentials is not exercised: add the credential-dependent source files to `filePaths` and run that path yourself per the protocol.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/app/keystore/` (VOLUME upstream, must persist) | `/config/keystore` (persistent), with the symlink fallback described in section 7 if the path is hard-coded |
| Upstream runs as root (no USER) | `USER apps` in the final stage |
| Go build cache | `GOCACHE=/tmp/go-cache` in the build stage only |
| Draft security expectations (runAsUser 0, readOnlyRootFilesystem false, no privileged) | Reconciled: rootless `apps`, works with `--read-only --tmpfs /tmp`; keystore is the only persistent state, under `/config`. |

## 10. Risks, caveats and open questions

- **No release**: pinned to a commit; renovate must track `master` via `git-refs` (UNVERIFIED repo convention).
- **Go version**: upstream builder is Go 1.12 (2019 era). Ubuntu 26.04 `golang-go` version UNVERIFIED; check `go.mod` `go` directive at the pinned commit before the first build.
- **arm64**: upstream only builds amd64 (`GOARCH=amd64` hard-coded); the plan uses `TARGETARCH`. arm64 is not validated until built.
- **Keystore path**: hard-coded or configurable UNVERIFIED.
- **Env vars**: Trakt client ID, secret and redirect URL names UNVERIFIED. The redirect URL must be a public HTTPS address reachable from Trakt (draft caveat, not verified on a fetched page).
- **Credentials**: the keystore holds tokens; it must persist or users must re-authorise (draft caveat, confirmed by VOLUME).
- **Blockers**: none confirmed.

## 11. Build and test steps

From `apps/plaxt`:

1. `docker buildx bake --print`
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`
3. `docker volume create plaxt-probe-config`
4. `docker run --rm -d --name plaxt-probe --read-only --tmpfs /tmp -v plaxt-probe-config:/config plaxt:<VERSION>`
5. `docker logs -f plaxt-probe`: expected readiness line is the server's listen message on port 8000 (UNVERIFIED exact text; read it from the source). The process must still be running.
6. `forgetool containers test --image plaxt:<VERSION> --config ./container-test.yaml`
7. Clean up: `docker rm -f plaxt-probe; docker volume rm plaxt-probe-config`.

Arm64 only if an amd64-specific failure appears (the build may fail on arm64 with the upstream `GOARCH` hard-code; that is the reason to use `TARGETARCH`).

## 12. PR checklist

- Branch `feat/add-plaxt`, commit `feat(plaxt): add new container`, PR title the same, target `main`.
- PR body from `.github/PULL_REQUEST_TEMPLATE.md`, keeping its sections and checkboxes; only tick what was done.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only they can sign it).
- State what is untested: Trakt OAuth flow (no credentials), arm64 build, keystore path if unverified.
- Pre-completion checklist from `.github/copilot-instructions.md` (bake print, version alignment, rootless, empty `/config`, no DOWNSTREAM file needed).
