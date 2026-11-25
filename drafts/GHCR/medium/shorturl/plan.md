# shorturl — implementation plan
> Source: ./draft.md · Target: apps/shorturl/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v0.1.0` (latest release on the canonical host, dated 2017-09-02, marked Latest). Chart image tag `ghcr.io/nicholaswilde/shorturl:version-v0.1.0` matches. Source: https://git.mills.io/prologic/shorturl (repo page loads; release `v0.1.0`). |
| Canonical source | https://git.mills.io/prologic/shorturl. The GitHub path `https://github.com/prologic/shorturl` returns 404 (`gh api`), so the draft's note about the 404 is confirmed. The GitHub mirror `https://github.com/nicholaswilde/docker-shorturl` is the packaging repo, not the app. |
| Renovate | No GitHub repo to use `github-releases`. Proposed: `// renovate: datasource=git-tags depName=https://git.mills.io/prologic/shorturl versioning=semver`. UNVERIFIED that Renovate can read this Gitea host; if not, pin the tag and document it as manual. |
| License | MIT (repo page, README License section). |
| Source tarball | `https://git.mills.io/prologic/shorturl/archive/v0.1.0.tar.gz` returns HTTP 200 (checked with curl HEAD). |
| Checksum source | Upstream image Dockerfile verifies the tarball with `sha256sum -c` against a `CHECKSUM` build arg (nicholaswilde Dockerfile). The checksum value for `v0.1.0` is UNVERIFIED (not published on a fetched page); compute it locally from the downloaded tarball and pin it in `docker-bake.hcl` or the Dockerfile. |
| Ready-made binary | None (`-` in draft; no release assets). Compile from source. `amd64`: compile. `arm64`: compile (UNVERIFIED that the app builds on arm64). |
| copy-from | No. The upstream image `ghcr.io/nicholaswilde/shorturl` is built on Alpine/musl (`linuxserver/baseimage-alpine:3.14`), which does not run on glibc Ubuntu. |
| Upstream image Dockerfile reviewed | https://raw.githubusercontent.com/nicholaswilde/docker-shorturl/9362206/Dockerfile. Build stage `golang:1.14.15-alpine3.13`; downloads the tarball, verifies, runs `make TAG=$VERSION BUILD=dev build`; runtime `ghcr.io/linuxserver/baseimage-alpine:3.14`, binary to `/app/shorturl`, `root/` copied to `/`, `/data` created, `EXPOSE 8000/tcp`, `VOLUME /app /data`. No ENV, USER, ENTRYPOINT or CMD in the file (start scripts come from `root/`). |
| Port | `8000/tcp` per upstream image `EXPOSE`. The draft's `8080` is not confirmed; the app's own listen flag and default are UNVERIFIED (the upstream `Makefile` and `main.go` could not be read: git.mills.io serves a proof-of-work page to raw URLs). |
| Data path | `/data` in the upstream image (`VOLUME /data`). The draft proposes `/config`; the app's DB path flag is UNVERIFIED. |
| Env vars | None set by the upstream image Dockerfile. App flags/env UNVERIFIED. |
| Dependencies | None. |

## 2. Target layout

Files in `apps/shorturl/`:
- `Dockerfile`: required (build stage + final stage).
- `docker-bake.hcl`: required.
- `settings.yaml`: required.
- `container-test.yaml`: required.
- `start.sh`: required. The upstream `root/` s6 scripts are not copied; `start.sh` replaces them.
- `defaults/`: not needed unless a default config is needed (UNVERIFIED).
- `DOWNSTREAM_CHANGES.md`: not needed (not a `FROM` base).

Never use `root/`.

## 3. Base image

- Build stage: `ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`, `AS build`, with `golang-go` from apt (same approach as `apps/pwndrop/Dockerfile`). Go version: the apt version of `golang-go` on Ubuntu 26.04 is UNVERIFIED; the v0.1.0 tree is from 2017, so check whether it builds with a modern toolchain (it may need `GO111MODULE` handling or a GOPATH layout; the Makefile is UNVERIFIED). If modern Go fails, use a `golang:<ver>` build stage with a pinned digest and `COPY --from`.
- Final stage: the same ubuntu base. No runtime image needed (draft: `Runtime image: none`).
- Closest sibling for Go on ubuntu: `apps/pwndrop`.

## 4. Dockerfile

1. Stage `build` `FROM <ubuntu>`, `ARG VERSION`, `ARG CHECKSUM`, `USER root`.
2. `apt-get update && apt-get install -y --no-install-recommends build-essential golang-go ca-certificates curl`. Pin `golang-go` if the apt version is too old (check against the build result).
3. `ENV GOCACHE=/tmp/go-build GOPATH=/tmp/go GOFLAGS=-mod=vendor` (or unset if the repo has no vendor dir; UNVERIFIED). `GOCACHE` must be `/tmp` per the Go runtime rules.
4. Fetch and verify: `curl -fL -o /tmp/shorturl.tar.gz https://git.mills.io/prologic/shorturl/archive/${VERSION}.tar.gz && echo "${CHECKSUM}  /tmp/shorturl.tar.gz" | sha256sum -c -`. Extract to `/tmp/src --strip-components=1`.
5. Build: `cd /tmp/src && make build` (upstream image runs `make TAG=$VERSION BUILD=dev build`; pass the same `TAG`). Output binary path UNVERIFIED; find it with `make`'s output and copy it to `/app/shorturl/shorturl`.
6. License: `install -D /tmp/src/LICENSE /usr/share/licenses/shorturl/LICENSE`.
7. Final stage `FROM <ubuntu>`, `ARG VERSION`, `USER root`. `COPY --from=build /app/shorturl/shorturl /app/shorturl/shorturl` and `COPY --from=build /usr/share/licenses/shorturl /usr/share/licenses/shorturl`. `chown -R apps:apps /app/shorturl && chmod -R 755 /app/shorturl`.
8. `ENV HOME=/config`. Caches to `/tmp` only.
9. Tail: `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8000`, `VOLUME /config`, `WORKDIR /config`.

Version alignment: `ARG VERSION` must equal the `docker-bake.hcl` default `v0.1.0`.

## 5. docker-bake.hcl

- `APP = "shorturl"`, `VERSION = "v0.1.0"` with the renovate annotation from section 1, `CHECKSUM` variable with the computed sha256 (UNVERIFIED value until computed), `LICENSE = "MIT"`, `SOURCE = "https://git.mills.io/prologic/shorturl"`.
- Four standard targets and `group "default" { targets = ["image-local"] }` as in `apps/adguardhome-sync/docker-bake.hcl`. Pass `CHECKSUM` in `args`.
- Validate: `cd apps/shorturl && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://git.mills.io/prologic/shorturl"
ports:
  - port: 8000
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

No app env vars are listed because none are confirmed (UNVERIFIED). Add the listen address/base-URL variable only after the app's flags are read. The base URL for generated short links is a required setting for correct links (draft, inferred) and must be listed once its name is confirmed.

## 7. start.sh

- `#!/usr/bin/env bash`, `mkdir -p /config`.
- Exec the binary with its data path under `/config` (flag name UNVERIFIED): `exec /app/shorturl/shorturl <flags>`.
- Listen on `0.0.0.0:8000` (set explicitly; do not rely on localhost defaults).
- Idempotent: only create dirs; the app creates its DB on first start.
- Never write to `/app`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '8000'
http:
- port: '8000'
  path: /
filePaths:
- /app/shorturl/shorturl
- /usr/share/licenses/shorturl/LICENSE
```

- `8000` has tcp and http probes. Confirm the `/` path returns 200; if the app returns a non-200 on `/`, pick a path that does (UNVERIFIED).
- No env vars are passed in tests; the app must start with defaults.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/data` (upstream DB volume) | `/config` (the draft's choice); persistent volume. |
| `/app` (upstream binary dir, `VOLUME /app`) | Read-only at runtime. Build-time only. Remove the upstream `VOLUME /app`. |
| Go build cache, module cache | `/tmp` (`GOCACHE`, `GOPATH`). |
| Upstream s6 `root/` services | Not copied. `start.sh` runs the binary as `apps`. |
| Upstream `abc` user (linuxserver) | Not used. The image runs as `apps`. |

## 10. Risks, caveats and open questions

- R1. The canonical repo is on git.mills.io, not GitHub. The GitHub path returns 404 (`gh api`). Renovate may not support the host (see section 1).
- R2. The upstream release is `v0.1.0` from 2017 and uses a 2014-style Makefile and a Go 1.14 build image. A modern Go toolchain may fail. Verify before pinning.
- R3. Checksum value for the tarball is not published on a fetched page; compute it from the downloaded tarball and record the method in the PR.
- R4. Port 8000 (upstream image) versus the draft's 8080: confirm the app's default listen port.
- R5. The draft's `/config` path versus upstream `/data`: confirm the DB path flag.
- R6. Base URL for short links must be configured (inferred).
- R7. Upstream image is musl/Alpine; the source build here is glibc Ubuntu, so the binary must be built in the build stage with the Ubuntu toolchain. No `COPY --from` of the upstream binary.
- No arm64 binary is published. arm64 is untested.
- Blockers: none confirmed. Source host reachability is confirmed (HTTP 200 on the tarball).

## 11. Build and test steps

From `apps/shorturl/`:
1. `docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker run --rm -d --name shorturl-probe --read-only --tmpfs /tmp -v shorturl-probe-config:/config shorturl:v0.1.0` then `docker logs -f shorturl-probe`. Expected readiness signal: a "listening" line (UNVERIFIED wording; set after the first run).
4. `forgetool containers test --image shorturl:v0.1.0 --config ./container-test.yaml`.
5. Cleanup: `docker rm -f shorturl-probe; docker volume rm shorturl-probe-config`.
6. arm64 only if amd64 fails for an arm64-specific reason.

## 12. PR checklist

- Branch `feat/add-shorturl`, commit `feat(shorturl): add new container`, PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; keep sections and checkboxes; check only what applies.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign it; the `license/cla` check shows status.
- Say what is not tested: arm64, the base-URL setting, anything not built locally.
- Check `docker buildx bake --print` was run and passed.
