# libreddit — implementation plan
> Source: ./draft.md · Target: apps/libreddit/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | `v0.30.1` (GitHub latest release, published 2023-03-11). The upstream project has had no release since. Repo last pushed 2025-02-15, not archived. |
| Draft tag | Draft names no tag. Chart image `docker.io/libreddit/libreddit:latest` is pinned by digest in the chart. Docker Hub `latest` (amd64) was last updated 2024-03-05. |
| Renovate | `// renovate: datasource=github-releases depName=libreddit/libreddit versioning=semver` |
| License | AGPL-3.0 (GitHub). `LICENSE` file in the repo. |
| Source URL | https://github.com/libreddit/libreddit (`SOURCE`). Draft's `spikecodes/libreddit` is the older location and is not used. |
| amd64 download | https://github.com/libreddit/libreddit/releases/download/v0.30.1/libreddit (8,503,616 bytes). Ready-made binary: amd64 = yes. |
| arm64 download | No release asset. Compile from source: https://github.com/libreddit/libreddit/archive/refs/tags/v0.30.1.tar.gz with cargo. amd64 yes, arm64 compile. |
| Checksum source | Release asset `libreddit.sha256`: `60dd0c785d2b49c628308b99b0e630c4d47584616318937acf3a083e39502035  libreddit`. A `libreddit.sha512` asset also exists. Verify the downloaded binary against the `.sha256` asset. |
| Upstream Dockerfile reviewed | `Dockerfile` at `spikecodes/libreddit@9b7ee50` and at `libreddit/libreddit` master (same content). Stage 1 `rust:alpine`, `apk add musl-dev`, `cargo build --target x86_64-unknown-linux-musl --release`. Stage 2 `alpine:latest`, `adduser libreddit`, `USER libreddit`, `EXPOSE 8080`, `HEALTHCHECK` with `wget http://localhost:8080/settings`, `CMD ["libreddit"]`. |
| Port | 8080 (upstream `EXPOSE 8080`). Chart service port `10257` maps to targetPort `8080`. |
| Env vars (real) | From upstream README, instance settings as `LIBREDDIT_{X}` and user defaults as `LIBREDDIT_DEFAULT_{Y}`. Listed in section 6. Exact defaults and the names of any instance-level variables (other than `LIBREDDIT_DEFAULT_*`) are UNVERIFIED in this run. |
| Data and config paths | None. No volume in the upstream Dockerfile. Config is env only. Chart has a configmap `libreddit` and no persistence. |
| Probe path | `/settings` (upstream HEALTHCHECK and chart probes). |
| Docker Hub | `libreddit/libreddit`: `latest` (amd64, 2024-03-05), `latest-arm` (arm64, 2023-11-29), `latest-armv7` (arm, 2024-03-05). These are separate tags and are not used as a copy source (see `copy-from`). |

## 2. Target layout

- `apps/libreddit/Dockerfile`
- `apps/libreddit/docker-bake.hcl`
- `apps/libreddit/settings.yaml`
- `apps/libreddit/container-test.yaml`
- `apps/libreddit/start.sh`

No `defaults/`, `etc/`, `health/` or `root/`: the app has no config files and no state. No `DOWNSTREAM_CHANGES.md`: nothing uses it as a `FROM` base.

## 3. Base image

```dockerfile
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454
```

A single static-or-glibc Rust binary runs directly on Ubuntu, so no runtime image is needed. The upstream runtime is `alpine:latest` (musl), which is not used. Closest sibling for a single-binary app: `apps/adguardhome-sync` (prebuilt tarball on ubuntu, `start.sh`, `exec`). Upstream `copy-from` is `no`: the binary is built in an Alpine (musl) image and that stage is not reused.

## 4. Dockerfile

1. `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. One build stage for both architectures inside `RUN`, with `case "${TARGETARCH}"`:
   - `amd64`: download the release binary and its `.sha256`, verify, install.
   - `arm64`: install the Rust toolchain from apt, build the tag with cargo, install.
3. Install the license from the tag.
4. `USER apps` and `COPY --chmod=0755 . /`.

```dockerfile
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
USER root

RUN echo "*** Installing libreddit ${VERSION} (${TARGETARCH}) ***" && \
  mkdir -p /app/libreddit && \
  case "${TARGETARCH}" in \
    amd64) \
      curl -fsSL -o /tmp/libreddit \
        "https://github.com/libreddit/libreddit/releases/download/${VERSION}/libreddit" && \
      curl -fsSL -o /tmp/libreddit.sha256 \
        "https://github.com/libreddit/libreddit/releases/download/${VERSION}/libreddit.sha256" && \
      (cd /tmp && sha256sum -c libreddit.sha256) && \
      install -m 0755 /tmp/libreddit /app/libreddit/libreddit ;; \
    arm64) \
      apt-get update && \
      apt-get install -y --no-install-recommends cargo rustc && \
      mkdir -p /tmp/src && \
      curl -fsSL "https://github.com/libreddit/libreddit/archive/refs/tags/${VERSION}.tar.gz" \
        | tar xz -C /tmp/src --strip-components=1 && \
      (cd /tmp/src && cargo build --release --locked) && \
      install -m 0755 /tmp/src/target/release/libreddit /app/libreddit/libreddit ;; \
    *) echo "unsupported arch: ${TARGETARCH}" && exit 1 ;; \
  esac && \
  install -d /usr/share/licenses/libreddit && \
  curl -fsSL -o /usr/share/licenses/libreddit/LICENSE \
    "https://raw.githubusercontent.com/libreddit/libreddit/${VERSION}/LICENSE" && \
  chown -R root:root /app && chmod -R 755 /app && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/* /var/lib/apt/lists/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
WORKDIR /app/libreddit
```

- The `.sha256` file names `libreddit`, so verification runs in `/tmp` where the binary is named `libreddit`.
- The LICENSE download from the tag is UNVERIFIED for that path at `v0.30.1`; confirm in the build.
- arm64 `cargo` and `rustc` from Ubuntu 26.04 are UNVERIFIED: check the version against libreddit's requirements, and whether the tag ships `Cargo.lock` (the `--locked` flag needs it). If either is missing, pin a toolchain and say so.
- Does the amd64 release binary run on glibc Ubuntu? UNVERIFIED: the upstream Dockerfile builds a musl target, so the release asset is probably static. Check with `file` and `ldd` in the build.
- No `VOLUME`: the app is stateless.
- No `HEALTHCHECK`: the upstream one uses `wget`, which is UNVERIFIED in the base. The probe lives in `container-test.yaml` instead.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "libreddit"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=libreddit/libreddit versioning=semver
  default = "v0.30.1"
}

variable "LICENSE" {
  default = "AGPL-3.0"
}

variable "SOURCE" {
  default = "https://github.com/libreddit/libreddit"
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

Validate with `docker buildx bake --print` from `apps/libreddit`. The Dockerfile `ARG VERSION` must be `v0.30.1`, the same string.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/libreddit/libreddit"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - name: LIBREDDIT_DEFAULT_AUTOPLAY_VIDEOS
    default: ""
    required: false
  - name: LIBREDDIT_DEFAULT_COMMENT_SORT
    default: ""
    required: false
  - name: LIBREDDIT_DEFAULT_FRONT_PAGE
    default: ""
    required: false
  - name: LIBREDDIT_DEFAULT_HIDE_HLS_NOTIFICATION
    default: ""
    required: false
  - name: LIBREDDIT_DEFAULT_LAYOUT
    default: ""
    required: false
  - name: LIBREDDIT_DEFAULT_POST_SORT
    default: ""
    required: false
  - name: LIBREDDIT_DEFAULT_SHOW_NSFW
    default: ""
    required: false
  - name: LIBREDDIT_DEFAULT_THEME
    default: ""
    required: false
  - name: LIBREDDIT_DEFAULT_USE_HLS
    default: ""
    required: false
  - name: LIBREDDIT_DEFAULT_WIDE
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
```

- Empty `default` means "the app's own default applies". `start.sh` removes empty `LIBREDDIT_*` variables so the app sees them as unset (section 7). Confirm the app's own default for each variable from the README before the PR; UNVERIFIED in this run.
- The README's instance-level `LIBREDDIT_*` names are not listed here because they were not confirmed in this run. Add them only after checking the README.
- `volumes`: omitted. No state, no `/config`. Matches the chart (no persistence).
- No `dependencies`.

## 7. start.sh

```bash
#!/usr/bin/env bash

# An empty LIBREDDIT_* variable must count as unset
for var in $(env | grep -o '^LIBREDDIT_[A-Za-z0-9_]*'); do
  if [ -z "${!var}" ]; then
    unset "${var}"
  fi
done

cd /app/libreddit
exec /app/libreddit/libreddit
```

- Idempotent, no seeding, no writes at all. Nothing needs `/config`.
- `exec` hands PID 1 to the binary.
- Binds all interfaces: UNVERIFIED default bind address in the source. Check with `ss -ltn` in the container and a connect from outside the container. If it binds only to localhost, the fix is a configured address (flag or env name to be taken from the README), not a hack.
- The loop is needed because `env` lists empty variables, and libreddit may fail to parse an empty boolean. UNVERIFIED whether this matters; keep the guard unless the README says otherwise.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '8080'
http:
- port: '8080'
  path: /settings
filePaths:
- /app/libreddit/libreddit
- /usr/share/licenses/libreddit/LICENSE
```

- `timeoutSeconds: 60`: a Rust binary starts in well under a second. No sibling precedent was checked; adjust only if the run needs it.
- `/settings` is the upstream health path (HEALTHCHECK and chart probes), so it is a real probe.
- The `/settings` probe needs no Reddit access, so it does not depend on Reddit being reachable.
- The test runs with no env vars: the required-env paths are not used (no var is required).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| None in the Dockerfile. No volume, no `/data`. | Nothing to remap. |
| Temporary build files | `/tmp`, removed in the same `RUN` layer. |
| Chart security | Chart uses common defaults: non-root (UID 568 default), `readOnlyRootFilesystem: true`, not privileged, no extra persistence. |

Reconciled with the draft: the image runs as `apps` and needs only `/tmp` if anything at all. Read-only rootfs is expected to work and is proven in section 11. Not privileged. No extra capabilities. No `/config` volume. The chart matches this image without change apart from the image tag.

## 10. Risks, caveats and open questions

- **Upstream is stale.** Last release 2023-03, last push 2025-02-15. Reddit has changed its API and access rules, so the front end may fail to load content even when the container is healthy. This is the main product risk, not a build risk. Say so in the PR.
- **Probe is not a content check.** `/settings` shows the app is up, not that Reddit works. The test cannot prove content loads.
- **arm64 compile.** Cargo build on arm64 is slow and depends on the Ubuntu 26.04 rust toolchain (UNVERIFIED version and `Cargo.lock`). If the build fails, the arm64 image is not published; record it as an open issue rather than hacking around it.
- **Binary linkage.** UNVERIFIED whether the amd64 release asset is static. If it needs glibc symbols not in the base, the run will show it; then switch to the compile path for amd64 too.
- **Renovate.** `github-releases` only tracks the amd64 tag. The arm64 build uses the same tag, so one bump covers both.
- **Blockers:** none for the build. Access to Reddit is an external dependency and may block usefulness.

## 11. Build and test steps

```sh
cd apps/libreddit
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name libreddit-probe --read-only --tmpfs /tmp \
  -v libreddit-probe-config:/config libreddit:v0.30.1
docker logs -f libreddit-probe
forgetool containers test --image libreddit:v0.30.1 --config ./apps/libreddit/container-test.yaml
docker rm -f libreddit-probe; docker volume rm libreddit-probe-config
```

The `-v` volume is harmless but not needed (no `/config`). It is kept so that the protocol's empty-`/config` step is the same for every app. Drop it if the protocol is changed.

Expected readiness signal: the libreddit startup line (exact text UNVERIFIED) with port 8080 and no panic. Then `curl -fsS http://localhost:<mapped>/settings` returns 200. Check `ss -ltn` for `0.0.0.0:8080` (or `[::]:8080`), and connect from the host with `-p 8080:8080` to prove it is not bound to localhost.

## 12. PR checklist

- Branch `feat/add-libreddit`, commit and PR title `feat(libreddit): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`, keep its sections, check only the boxes that apply.
- Notes section includes `🤖 This PR is AI generated.`
- CLA: a signed Contributor License Agreement is required (https://cla-assistant.io/trueforge-org/containerforge). Only the user can sign it. The `license/cla` check shows the status.
- Say in the PR what is untested: the arm64 cargo build (toolchain and lockfile), the `--read-only` run, the bind address, the README defaults for each `LIBREDDIT_DEFAULT_*` variable, and whether the front end loads Reddit content.
- `docker buildx bake --print` passes; bake `VERSION` equals Dockerfile `ARG VERSION`; no assertion weakened.
