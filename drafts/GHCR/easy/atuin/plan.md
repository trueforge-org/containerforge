# atuin — implementation plan
> Source: ./draft.md · Target: apps/atuin/ · Difficulty: easy · Role: main (sync server) · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | **v18.25.1** (published 2026-11-20T21:46:54Z, GitHub `releases/latest`). The draft pins v18.25.0 and chart tag 18.25.0; bump to 18.25.1 unless a reason to keep 18.25.0 is found. |
| Renovate | `// renovate: datasource=github-releases depName=atuinsh/atuin versioning=semver` |
| License | MIT (GitHub API `license.spdx_id` = MIT) |
| Source URL | https://github.com/atuinsh/atuin |
| Download (amd64) | https://github.com/atuinsh/atuin/releases/download/v18.25.1/atuin-server-x86_64-unknown-linux-gnu.tar.gz (HTTP 200, verified) |
| Download (arm64) | https://github.com/atuinsh/atuin/releases/download/v18.25.1/atuin-server-aarch64-unknown-linux-gnu.tar.gz (HTTP 200, verified) |
| Draft correction | The draft's arm64 URL `atuin-aarch64-unknown-linux-gnu.tar.gz` is the **CLI** tarball, not the server. Use the `atuin-server-aarch64-...` asset. |
| Checksums | Per-asset `<asset>.sha256` files, e.g. `.../atuin-server-x86_64-unknown-linux-gnu.tar.gz.sha256`. Values at v18.25.1: amd64 `b57b4ba721cbdfa1b281697e2147eb80f59903bf6a639189cc2a6d44d29ba86e`, arm64 `18b2c4dbfe697bd641108368e799c606e87a75022e85c056d02e022a1fbf270b`. The same values appear as GitHub API `digest` fields. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/atuinsh/atuin/d154a94090a7e390c1685c10252128545cdcacbd/Dockerfile: cargo-chef builder, `debian:bookworm-20261020-slim` runtime, user `atuin`, `ENV ATUIN_CONFIG_DIR=/config`, `ENV RUST_LOG=atuin_server=info`, `ENV TZ=Etc/UTC`, `ENTRYPOINT ["/usr/local/bin/atuin-server"]`, healthcheck on `${ATUIN_PORT:-8888}` path `/healthz`, no `EXPOSE`, no `VOLUME`. |
| Port | 8888/tcp (default, from the upstream healthcheck; `ATUIN_PORT` env name confirmed by that same healthcheck). |
| Env vars confirmed | `ATUIN_CONFIG_DIR` (=/config), `RUST_LOG`, `TZ`, `ATUIN_PORT` (healthcheck). |
| Env vars NOT confirmed | `ATUIN_DB_URI` (database URL), `ATUIN_HOST` (bind address), `ATUIN_OPEN_REGISTRATION`. **UNVERIFIED**: the atuin server config docs were not fetched in this run. Confirm each name and its default in `crates/atuin-server/src/settings.rs` (or the docs) before writing it into `settings.yaml`. |
| Checksum verification | Yes, use the upstream `.sha256` file (see Dockerfile step). |
| Data/config write paths | `/config` (ATUIN_CONFIG_DIR). No other writes expected; server state lives in PostgreSQL. |
| Dependencies | PostgreSQL (hard). `apps/postgresql` exists (✅). |

## 2. Target layout

- `apps/atuin/Dockerfile`
- `apps/atuin/docker-bake.hcl`
- `apps/atuin/settings.yaml`
- `apps/atuin/container-test.yaml`
- `apps/atuin/start.sh`

No `defaults/`, `etc/` or `health/` needed. No `root/` (never use it). No `DOWNSTREAM_CHANGES.md` (not used as a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` (brief's exact string; sibling Dockerfiles such as `apps/steamcmd` and `apps/valkey` use tag `26.4` with the same digest. Confirm which tag string to keep when the Dockerfile is written.)

Fits because it is a single native binary with no runtime language. Ubuntu supplies glibc, which the gnu tarball needs. Closest siblings: `apps/valkey` (prebuilt binary on ubuntu, `/config` data, pinned health dir) and `apps/adguardhome-sync` (prebuilt binary download with arch mapping).

## 4. Dockerfile

Single stage (no compile, so no build stage needed).

1. `ARG VERSION` (must equal `docker-bake.hcl` VERSION, `18.25.1`), `ARG TARGETARCH`.
2. `USER root` only for installs and the download.
3. Install packages only if the base lacks them: check `ca-certificates`, `curl` and `libssl3` first (the upstream runtime installs `ca-certificates curl libssl3`; the base may already have them). Use `apt-get install -y --no-install-recommends <missing>` and `rm -rf /var/lib/apt/lists/*`.
4. Arch mapping, with `case "${TARGETARCH}"`: `amd64` -> `x86_64`, `arm64` -> `aarch64`. Fail on anything else.
5. Download and verify, in `/tmp` only:
   ```sh
   asset="atuin-server-${arch}-unknown-linux-gnu.tar.gz"
   base="https://github.com/atuinsh/atuin/releases/download/v${VERSION}"
   cd /tmp
   curl -fsSL -o "${asset}" "${base}/${asset}"
   curl -fsSL -o "${asset}.sha256" "${base}/${asset}.sha256"
   sha256sum -c "${asset}.sha256"
   tar -xzf "${asset}" -C /tmp
   ```
   The `.sha256` file names the asset, so `sha256sum -c` works from `/tmp`. Check the tar's member name (`atuin-server`) before the install step.
6. Install the binary to `/app/atuin/atuin-server` (chmod 0755). Keep `/app` read-only compatible: no runtime writes there. Ship the license: `install -D -m 0644 <LICENSE from source> /usr/share/licenses/atuin/LICENSE` (the release tarball has no license; take it from the source tarball or the repo `LICENSE` file, or record as UNVERIFIED if neither is fetched).
7. `ENV ATUIN_CONFIG_DIR=/config RUST_LOG=atuin_server=info TZ=Etc/UTC`.
8. `mkdir -p /config && chown apps:apps /config`. Remove `/tmp/*` artifacts in the same `RUN`.
9. Final lines:
   ```dockerfile
   USER apps
   COPY --chmod=0755 . /
   EXPOSE 8888
   VOLUME /config
   WORKDIR /app/atuin
   ENTRYPOINT ["/start.sh"]
   ```
   `COPY --chmod=0755 . /` copies `start.sh` and the allow-listed paths. The app folder's `start.sh` is the entrypoint. Keep `ENTRYPOINT` on `/start.sh` for `exec` handoff.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "atuin"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=atuinsh/atuin versioning=semver
  default = "18.25.1"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/atuinsh/atuin"
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

Validate: `cd apps/atuin && docker buildx bake --print` must exit 0.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/atuinsh/atuin"
ports:
  - port: 8888
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: ATUIN_CONFIG_DIR
    default: "/config"
    required: false
  - name: RUST_LOG
    default: "atuin_server=info"
    required: false
  - name: ATUIN_PORT
    default: "8888"
    required: false
  # Add ATUIN_DB_URI (required, DB URL) and the bind-address variable only after verification (see section 1 UNVERIFIED rows).
volumes:
  - path: /config
    required: true
dependencies:
  - postgresql
```

Rules: `required: true` on `ATUIN_DB_URI` needs a default or start.sh handling. A DB URL cannot be defaulted safely; set it `required: true` and have `start.sh` fail with a clear message if it is empty. Do not list env names that were not confirmed.

## 7. start.sh

- `#!/usr/bin/env bash`, `set -euo pipefail`.
- `export ATUIN_CONFIG_DIR=/config`, `mkdir -p /config` (no-op if present).
- Require the DB URL: if `ATUIN_DB_URI` is empty, print an error to stderr and exit 1 (keeps the image from starting with a useless state; the test runs with no env, so this path is covered by `filePaths` only).
- Bind to all interfaces: set the bind-address variable to `0.0.0.0` (name UNVERIFIED, see section 1).
- No writes to `/app`. Caches and scratch use `/tmp` (not needed for atuin itself).
- Seed `/config/config.toml` only if missing, if the server reads one (UNVERIFIED; the server may run env-only).
- Final line: `exec /app/atuin/atuin-server start` (the `start` subcommand is UNVERIFIED: confirm with `atuin-server --help`; if the server takes no subcommand, use `exec /app/atuin/atuin-server`).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

filePaths:
- /start.sh
- /app/atuin/atuin-server
- /config
tcp:
- port: '8888'
  # narrowed: requires external postgresql; full functional test not feasible in single-container suite
```

- The image has no DB, so the server exits without `ATUIN_DB_URI`. Per the protocol's narrow exception (hard `dependencies:` on a DB, fails without it, no sidecar wiring in the test), the run check uses the process/port/file checks above, and the startup log must show the expected readiness line (UNVERIFIED wording; capture it on the first build).
- Consider `httpCommands` only if the server answers `/healthz` without a DB (UNVERIFIED; skip otherwise).
- `timeoutSeconds`: take it from a sibling of the same family (e.g. `apps/valkey`'s test file has none; use the forgetool default unless a value is confirmed).
- Add a comment at the narrowed assertions as above.

## 9. Rootless and read-only-rootfs adaptations

- Upstream runs as `atuin` (non-root). Here the final stage is `USER apps` (ContainerForge default, UID 568). Do not use UID 1000.
- Read-only rootfs: the binary is in `/app/atuin`, read-only at runtime. The only writable paths are `/config` (persistent) and `/tmp` (ephemeral). Upstream `/config` and `ATUIN_CONFIG_DIR` already match.
- `chown` the `/config` dir to `apps:apps` at build time so an empty volume works.
- No privileged, no extra persistence beyond `/config` (chart security expectations per draft: non-root yes, read-only yes, privileged no, confidence high).
- Downloads and extraction happen as root in `/tmp` and are deleted before `USER apps`.

## 10. Risks, caveats and open questions

- **Version bump**: draft pins 18.25.0; latest is 18.25.1. Confirm nothing in the draft depends on 18.25.0 specifically.
- **Unverified env names**: `ATUIN_DB_URI` and the bind-address variable are not confirmed (section 1). Do not ship names that are not checked against the server source.
- **Draft arm64 URL is wrong** (CLI tarball). Fixed in section 4.
- **DB dependency**: PostgreSQL must exist and migrations run at start (draft, inferred, UNVERIFIED on a fetched page). The first-start migration needs a reachable DB; the test cannot exercise it.
- **Registration**: sync server registration config is UNVERIFIED; clients must point at the server URL.
- **Blockers**: none found for amd64/arm64 (gnu builds published for both). No GPU, no privileged need.
- **Base tag string**: `26.04` (brief) vs `26.4` (siblings). Same digest; confirm.

## 11. Build and test steps

```sh
cd apps/atuin
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local

# Run check (fresh /config volume, read-only rootfs)
docker volume create atuin-probe-config
docker run --rm -d --name atuin-probe --read-only --tmpfs /tmp \
  -e ATUIN_DB_URI=<test-db-url> \
  -v atuin-probe-config:/config atuin:18.25.1
docker logs -f atuin-probe
docker rm -f atuin-probe; docker volume rm atuin-probe-config

# Test suite (mirrors CI)
forgetool containers test --image atuin:18.25.1 --config ./apps/atuin/container-test.yaml
```

- Expected readiness signal: a server "listening" line on port 8888 (exact wording UNVERIFIED; record it from the first run and use it in the PR).
- Without a DB the run is expected to exit with a clear error. The protocol's DB exception applies only with the narrowed tests described in section 8. Say so in the PR if the functional path was not run against a real PostgreSQL.
- Not tested locally in this planning step: nothing was built or run.

## 12. PR checklist

- Branch `feat/add-atuin`, commit `feat(atuin): add new container`, PR title matching.
- PR template at `.github/PULL_REQUEST_TEMPLATE.md`, sections and checkboxes kept; only tick what applies.
- Notes section: `🤖 This PR is AI generated.`
- CLA: tell the user to sign at https://cla-assistant.io/trueforge-org/containerforge (only the user can sign; `license/cla` check shows status).
- Say what was not tested (full DB-backed functional test, arm64 run, UNVERIFIED env names).
- Protocol checks: `docker buildx bake --print` passes; image-local build; empty `/config` start; `container-test.yaml` assertions pass; no assertion weakened; scratch containers and volumes removed.
- No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).
