# static-web-server — implementation plan
> Source: ./draft.md · Target: apps/static-web-server/ · Difficulty: easy · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `2.44.3`, GitHub release `v2.44.3` published 2026-11-15. Draft chart tag `2.44.3` matches. |
| Renovate | `datasource=github-releases depName=static-web-server/static-web-server versioning=semver` |
| License | Apache-2.0 (GitHub SPDX). Source: https://api.github.com/repos/static-web-server/static-web-server |
| Source URL | https://github.com/static-web-server/static-web-server |
| amd64 download | `https://github.com/static-web-server/static-web-server/releases/download/v2.44.3/static-web-server-v2.44.3-x86_64-unknown-linux-gnu.tar.gz` |
| arm64 download | `https://github.com/static-web-server/static-web-server/releases/download/v2.44.3/static-web-server-v2.44.3-aarch64-unknown-linux-gnu.tar.gz` |
| Draft correction | The draft's amd64 link (`x86_64-unknown-illumos`) is an illumos build and must not be used. The arm64 link in the draft is the `-fips` variant; the plain `aarch64-unknown-linux-gnu` asset is used here. |
| Checksum source | `https://github.com/static-web-server/static-web-server/releases/download/v2.44.3/static-web-server-v2.44.3-SHA256SUM`. Values: x86_64 gnu `fb996f02936fc795026ae63b7027b9ab00b5389ff3a760f2ae2f3ca9a4a029b5`, aarch64 gnu `235938a683697fe267e3f26696d516622db77d8317c344542a22861fd7da0da1`. |
| Upstream Dockerfile reviewed | `docker/scratch/Dockerfile` (ref `501cb7fcb6a01a4e73e6d5f541559e3334c39976`): builds from `joseluisq/static-web-server:…-alpine`, final `FROM scratch`, `COPY … /usr/local/bin/static-web-server /`, `COPY ./docker/public /public`, `EXPOSE 80`, `STOPSIGNAL SIGQUIT`, `ENTRYPOINT ["/static-web-server"]`. No `USER`, no `VOLUME`. We take the binary only. |
| Env vars (real, from `src/settings/cli.rs` v2.44.3) | `SERVER_HOST` (default `::`), `SERVER_PORT` (default `80`), `SERVER_ROOT` (default `./public`), `SERVER_LOG_LEVEL` (default `error`), `SERVER_FALLBACK_PAGE`, `SERVER_ERROR_PAGE_404`, `SERVER_ERROR_PAGE_50X`, `SERVER_USE_RELATIVE_ROOT`, `SERVER_CORS_ALLOW_ORIGINS`, `SERVER_CORS_ALLOW_HEADERS`, `SERVER_THREADS_MULTIPLIER`, `SERVER_MAX_BLOCKING_THREADS`, `SERVER_LOG_WITH_ANSI`. Source: `gh api` on `src/settings/cli.rs?ref=v2.44.3`. |
| Port | 80/tcp upstream default. We use 8080 (see section 6). |
| Data/config write paths | None needed by the server. It reads from `SERVER_ROOT`. We place the web root under `/config/public`. |
| Dependencies | None. |
| arm64 | Yes (aarch64 gnu asset). |
| UNVERIFIED | static-web-server.net docs did not state default root, port or non-root guidance. The env var names come from source, not from the docs. |

## 2. Target layout

- `apps/static-web-server/Dockerfile`
- `apps/static-web-server/docker-bake.hcl`
- `apps/static-web-server/settings.yaml`
- `apps/static-web-server/container-test.yaml`
- `apps/static-web-server/start.sh`
- `apps/static-web-server/defaults/index.html`: a minimal page, seeded into `/config/public` only when that web root has no `index.html`. Reason: an empty web root returns 404 for `/`, which would make the readiness check unhelpful. Keep it small.

No `etc/`, `health/` or `root/`. No `DOWNSTREAM_CHANGES.md`: this image is not a `FROM` base.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`. The upstream image is `scratch`, but we need a `USER apps` runtime with `/config` and a glibc binary, which the ubuntu base provides. The gnu asset is glibc-linked, so ubuntu is the right base. Closest sibling: `apps/adguardhome-sync` (prebuilt release tarball on ubuntu).

## 4. Dockerfile

1. Header: `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Map `TARGETARCH` to the Rust triple: `amd64` → `x86_64`, `arm64` → `aarch64`; fail on anything else.
3. Download the tarball and `static-web-server-v${VERSION}-SHA256SUM` into `/tmp/sws`. Verify with `grep " static-web-server-v${VERSION}-${SWS_ARCH}-unknown-linux-gnu.tar.gz$" SHA256SUM | sha256sum -c -`.
4. Extract to `/tmp/sws`, `install -m 0755` the `static-web-server` binary to `/app/static-web-server`. The tarball layout (binary at root or in a subdirectory) is UNVERIFIED; confirm with `tar tzf` during the build step.
5. License: ship the Apache-2.0 license file to `/usr/share/licenses/static-web-server/`. Confirm the file name inside the tarball at build time (UNVERIFIED; the repo has a `LICENSE` file at its root, so `curl` it from `raw.githubusercontent.com/static-web-server/static-web-server/v${VERSION}/LICENSE` if the tarball lacks it).
6. `rm -rf /tmp/sws`, `chown -R apps:apps /app`, `chmod -R 755 /app`.
7. `ENV HOME=/config`.
8. Tail:

```dockerfile
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
```

No `apt-get` is needed, so no package pins apply.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "static-web-server"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=static-web-server/static-web-server versioning=semver
  default = "2.44.3"
}

variable "LICENSE" {
  default = "Apache-2.0"
}

variable "SOURCE" {
  default = "https://github.com/static-web-server/static-web-server"
}
```

Then the standard `group "default"`, `image`, `image-local` (`${APP}:${VERSION}`) and `image-all` (linux/amd64, linux/arm64) targets, copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `cd apps/static-web-server && docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/static-web-server/static-web-server"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - name: SERVER_PORT
    default: "8080"
    required: false
  - name: SERVER_HOST
    default: "0.0.0.0"
    required: false
  - name: SERVER_ROOT
    default: "/config/public"
    required: false
  - name: SERVER_LOG_LEVEL
    default: "error"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Port 8080 is a deliberate change from the upstream default 80: an unprivileged `apps` user cannot bind port 80 without a capability. Port 80 is listed in the draft as the default, so the chart's port must be mapped to 8080 when the chart is migrated (note for the PR). `SERVER_PORT` and `SERVER_ROOT` are read directly by the binary through clap, so `start.sh` only needs to set defaults.

## 7. start.sh

- `#!/usr/bin/env bash`, `set -euo pipefail`.
- `mkdir -p /config/public`.
- If `/config/public/index.html` is missing, copy `/defaults/index.html` into it. Never overwrite an existing file.
- Export defaults for `SERVER_HOST`, `SERVER_PORT`, `SERVER_ROOT` only if unset (the settings.yaml values).
- `cd /app` and `exec /app/static-web-server` (no extra flags; the binary reads `SERVER_*` env).
- Writes: only `/config`. Nothing in `/app`. No cache usage.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

tcp:
- port: '8080'

filePaths:
- /app/static-web-server
- /config/public/index.html
```

Only one port is declared, so one `tcp` probe covers it. Timeout: use a sibling value (no `timeoutSeconds` in `adguardhome-sync`, so leave the default). The `/config/public/index.html` check only passes if `start.sh` ran first; check forgetool's `filePaths` semantics during the build step (UNVERIFIED whether it runs the entrypoint).

## 9. Rootless and read-only-rootfs adaptations

- Runs as `apps` (UID from the base image). The draft's chart expectations (non-root, read-only rootfs) match the image.
- Port 80 is replaced by 8080 (section 6), which is the required rootless change.
- Web root moves from the chart's `/public` PVC to `/config/public`. The chart key `config` must map to `/config`.
- No write to `/app`. No write outside `/config` and `/tmp`.
- `--read-only --tmpfs /tmp` must work: the server writes nothing to disk by default.

## 10. Risks, caveats and open questions

- Draft amd64 link is wrong (illumos). Corrected in section 1.
- Draft arm64 link is the `-fips` variant; the plain gnu asset is used. Confirm that the non-fips build is the one the chart would have used (the chart pins the scratch image, so the plain gnu build is the closest equivalent).
- The `/config/public/index.html` seed is an invented default page. Keep it generic, with no branding.
- The `static-web-server` binary path inside the tarball is UNVERIFIED (see section 4).
- No blockers: no musl-only, GPU or privileged requirement; arm64 is available.

## 11. Build and test steps

1. `cd apps/static-web-server && docker buildx bake --print` (must exit 0).
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. `docker run --rm -d --name static-web-server-probe --read-only --tmpfs /tmp -v static-web-server-probe-config:/config static-web-server:2.44.3`, then `docker logs -f static-web-server-probe`. Expected readiness signal: a line containing `listening`/`serving` from the server (exact text UNVERIFIED; the server log level is `error` by default, so the readiness line may not print. If so, confirm with a TCP probe on 8080 instead).
4. Clean up: `docker rm -f static-web-server-probe; docker volume rm static-web-server-probe-config`.
5. `forgetool containers test --image static-web-server:2.44.3 --config ./apps/static-web-server/container-test.yaml`.
6. Repeat step 3 with an existing `/config/public/index.html` to confirm seeding is idempotent.

## 12. PR checklist

- Branch `feat/add-static-web-server`, commit `feat(static-web-server): add new container`, PR title the same.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; check only the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- State what was not tested: arm64 build (unless run), chart migration (port 80 → 8080 in the chart).
