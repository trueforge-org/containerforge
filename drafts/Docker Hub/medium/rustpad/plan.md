# rustpad — implementation plan
> Source: ./draft.md · Target: apps/rustpad/ · Difficulty: medium · Role: main · Verified on 2026-11-25

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version to build | No GitHub release and no git tag exist (`/releases/latest` 404, `/tags` empty). Pin the commit the draft names: `54e4a9383c84d7317af42a7ddb177ce8bcba058d`. Docker Hub `ekzhang/rustpad` has only `latest` (last updated 2025-02-02). Source `main` was last pushed 2025-02-02. Release date of the pinned commit: UNVERIFIED (not fetched). |
| Renovate | `// renovate: datasource=git-refs depName=https://github.com/ekzhang/rustpad currentValue=main` (precedent: `apps/tvheadend`, `apps/fenrus` plan). |
| License | MIT (GitHub SPDX `MIT`; `LICENSE`: "MIT License, Copyright (c) 2021 Eric Zhang"). |
| Source URL | https://github.com/ekzhang/rustpad |
| Download | Source tarball `https://github.com/ekzhang/rustpad/archive/${VERSION}.tar.gz` (VERSION = commit SHA). No prebuilt binary is published. |
| Per-arch | No binary. Upstream README claims linux/amd64 and linux/arm64 for its image. We compile per arch. Per-arch digests of the Hub image: UNVERIFIED (not inspected). |
| Checksum source | None published. The tarball is content-addressed by the pinned commit SHA. |
| Upstream Dockerfile reviewed | https://raw.githubusercontent.com/ekzhang/rustpad/54e4a9383c84d7317af42a7ddb177ce8bcba058d/Dockerfile: stages `backend` (`rust:alpine`, `cargo test --release`, `cargo build --release`), `wasm` (`wasm-pack build rustpad-wasm`), `frontend` (`node:lts-alpine`, `npm ci`, `npm run check`, `npm run build`, `VITE_SHA` from `GITHUB_SHA`), final `FROM scratch` with `dist`, `rustpad-server`, `USER 1000:1000`, `CMD ["./rustpad-server"]`. |
| Port | 3030/tcp, `PORT` env overrides it (`main.rs`). Server binds `0.0.0.0` (`main.rs`), so no bind change is needed. |
| Env vars (real) | `PORT` (default `3030`), `EXPIRY_DAYS` (default `1`), `SQLITE_URI` (optional; unset means memory only), `RUST_LOG` (env_logger). `dotenv` is loaded, so a `.env` in the working directory is read too (`main.rs`, README). |
| Data path | Only when `SQLITE_URI` is set: the file given by the URI (chart: `sqlite:///persist/rustpad_db.db`). Nothing is written otherwise. |
| Workspace | Root `Cargo.toml` members: `rustpad-server`, `rustpad-wasm`; release profile `lto = true`. |
| Dependencies | None. SQLite is embedded and optional. |
| Chart | TrueCharts values (https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rustpad/values.yaml): `readOnlyRootFilesystem: false`, `runAsUser: 0`, `runAsGroup: 0`, persistence `/persist`, env `EXPIRY_DAYS=1`, `RUST_LOG=info`, `SQLITE_URI=sqlite:///persist/rustpad_db.db`. |

## 2. Target layout

- `apps/rustpad/Dockerfile`
- `apps/rustpad/docker-bake.hcl`
- `apps/rustpad/settings.yaml`
- `apps/rustpad/container-test.yaml`
- `apps/rustpad/start.sh` (short: sets the SQLite URI default and `exec`s the server)

No `defaults/`, `etc/`, or `health/` needed (no seeded config). No `root/`. No `DOWNSTREAM_CHANGES.md` (not a `FROM` base).

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454` for the build stage and the runtime stage. No runtime sibling is needed: the server is one native binary and the frontend is static files. Closest sibling for a build stage plus a runtime stage: `apps/pwndrop` (Go build stage, `COPY --from=buildstage`).

Note: upstream uses musl (`rust:alpine`) and `scratch`. We use glibc on ubuntu, so the binary is built for the target arch in the build stage.

## 4. Dockerfile

1. Build stage: `FROM <ubuntu> AS buildstage`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`.
2. Toolchain (apt, versions UNVERIFIED): `cargo`, `rustc`, `nodejs`, `npm`, `build-essential`, `pkg-config`, `libssl-dev` (if the server needs OpenSSL; check `Cargo.lock`). Do not install packages already in the base. Pin versions only if the apt candidates differ from what the build needs (UNVERIFIED which ones).
3. Rust target and wasm tooling: `wasm-pack` is needed for `rustpad-wasm` (upstream installs it with `wasm-pack/installer/init.sh`). Options, to decide in the build round (UNVERIFIED which works on ubuntu 26.04 apt):
   - (a) `rustup` with `rustup target add wasm32-unknown-unknown` and `cargo install wasm-pack --locked --version <pinned>`;
   - (b) apt packages, if they supply the `wasm32-unknown-unknown` std library.
   Either way, pin the wasm-pack version and check the installer's checksum or pin the crate version.
4. Environment: `ENV CARGO_HOME=/tmp/cargo RUSTUP_HOME=/tmp/rustup CARGO_TARGET_DIR=/tmp/target npm_config_cache=/tmp/npm`. Keep every cache in `/tmp`.
5. Fetch source: `mkdir -p /tmp/src && curl -fL https://github.com/ekzhang/rustpad/archive/${VERSION}.tar.gz | tar xz -C /tmp/src --strip-components=1`.
6. Wasm and frontend (upstream builds these with `--platform=amd64`; the output is architecture-neutral, so building it once on any arch is fine; decide in the round):
   - `cd /tmp/src/rustpad-wasm && wasm-pack build` (outputs `/tmp/src/rustpad-wasm/pkg`).
   - `cd /tmp/src && npm ci`, then `ARG GITHUB_SHA` -> `ENV VITE_SHA=${GITHUB_SHA}`, `npm run check` and `npm run build`. The build output is `dist/`.
   - Pass `GITHUB_SHA` from the bake target as `args`; default to `unknown` when unset (UNVERIFIED that the Vite build accepts an empty value).
7. Server: `cd /tmp/src && cargo build --release -p rustpad-server` (crate name from `use rustpad_server` in `main.rs`; UNVERIFIED exact package name in `Cargo.toml`). Skip `cargo test` in the image build (CI covers it); the protocol does not require it.
8. Runtime stage: `FROM <ubuntu>`, `ARG VERSION`, `USER root`, install any shared libs the binary needs (determine with `ldd`; UNVERIFIED, likely none beyond glibc and libssl if linked dynamically).
9. Layout: `mkdir -p /app/rustpad`; `COPY --from=buildstage /tmp/src/dist /app/rustpad/dist`; `COPY --from=buildstage /tmp/target/release/rustpad-server /app/rustpad/rustpad-server`; `chown -R root:root /app/rustpad && chmod -R 755 /app/rustpad`. Upstream serves `dist` relative to the working directory (UNVERIFIED in `rustpad-server/src/lib.rs`; check in the build round), so `WORKDIR /app/rustpad`.
10. License: `COPY --from=buildstage /tmp/src/LICENSE /usr/share/licenses/rustpad/LICENSE`.
11. Final: `USER apps`, `COPY --chmod=0755 . /`, `ENV PORT=3030 EXPIRY_DAYS=1 RUST_LOG=info`, `EXPOSE 3030`, `VOLUME /config`, `WORKDIR /app/rustpad`, and `start.sh` as the entry (see section 7).

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" {
  default = "rustpad"
}

variable "VERSION" {
  // renovate: datasource=git-refs depName=https://github.com/ekzhang/rustpad currentValue=main
  default = "54e4a9383c84d7317af42a7ddb177ce8bcba058d"
}

variable "LICENSE" {
  default = "MIT"
}

variable "SOURCE" {
  default = "https://github.com/ekzhang/rustpad"
}

group "default" {
  targets = ["image-local"]
}

target "image" { ... }        // args.VERSION, OCI labels source and licenses (copy from apps/bazarr)
target "image-local" { ... }  // inherits image, output type=docker, tags ${APP}:${VERSION}
target "image-all" { ... }    // inherits image, platforms linux/amd64 and linux/arm64
```

Copy the four targets from `apps/bazarr/docker-bake.hcl`. The `VERSION` default must match the commit in the Dockerfile's `ARG VERSION`. Validate with `docker buildx bake --print` from `apps/rustpad/`.

Note: the bake tag `${VERSION}` is a 40-character SHA. If the tag is too long for ContainerForge conventions, use a short SHA only after checking the sibling pattern (UNVERIFIED convention); default to the full SHA.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/ekzhang/rustpad"
ports:
  - port: 3030
    protocol: tcp
    required: false
env:
  - name: PORT
    default: "3030"
    required: false
  - name: EXPIRY_DAYS
    default: "1"
    required: false
  - name: SQLITE_URI
    default: "sqlite:///config/rustpad_db.db"
    required: false
  - name: RUST_LOG
    default: "info"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```

Discipline: `SQLITE_URI` is read by the app (`main.rs`), so it stays. Its default is set in `start.sh` as well (see section 7). `PORT` must match the `ports` entry. `dependencies: []` because nothing external is required.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -eu

# SQLite snapshot file on the persistent volume by default.
# An empty SQLITE_URI means memory only: the server treats an unset variable as "no database",
# but an empty value would make Database::new("") fail, so unset it.
if [ -z "${SQLITE_URI:-}" ]; then
    if [ "${SQLITE_URI+set}" = "set" ]; then
        unset SQLITE_URI
    else
        export SQLITE_URI="sqlite:///config/rustpad_db.db"
    fi
fi
export PORT="${PORT:-3030}"
export EXPIRY_DAYS="${EXPIRY_DAYS:-1}"
export RUST_LOG="${RUST_LOG:-info}"

cd /app/rustpad
exec ./rustpad-server
```

The `${SQLITE_URI+set}` test separates "unset" (use the default file) from "set but empty" (memory only, as the protocol's step 4 checks). Keep this logic; it is the only way to honour both cases.

Rules: no seeding needed (empty `/config` is fine; the SQLite file is created by the app, UNVERIFIED that sqlx creates a missing file with the `sqlite:///path` URI; check in the round). No write to `/app`. No cache in `/config`. `exec` for PID 1. The app binds `0.0.0.0` itself.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 60
tcp:
- port: '3030'
http:
- port: '3030'
  path: /
filePaths:
- /app/rustpad/rustpad-server
- /app/rustpad/dist/index.html
- /usr/share/licenses/rustpad/LICENSE
```

- `tcp` and `http` probes on 3030 (the only port in `settings.yaml`). `http` `/` should return 200 with the `dist` index; confirm in the round.
- The test runs with no env vars, so `SQLITE_URI` defaults to the `/config` file (the SQLite code path is exercised by the default). Also run the memory-only path (`SQLITE_URI` unset-and-empty) manually in the protocol's step 3 with `-e SQLITE_URI=` to cover the empty-value branch, because the test cannot set it.
- `timeoutSeconds`: compile-time is not part of the test; startup is fast. Use 60 unless a sibling of the same family says otherwise (UNVERIFIED sibling).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| Chart `/persist` (SQLite `rustpad_db.db`) | `/config` (default `SQLITE_URI` in `start.sh` and `settings.yaml`). |
| Upstream runs as `1000:1000` (scratch) and the chart runs as root | Runtime is `USER apps`. The binary is `root:root` 755 under `/app/rustpad`, not writable at runtime. |
| `readOnlyRootFilesystem: false` in the chart | Not needed: the only writable path is `/config`. Run the probe with `--read-only --tmpfs /tmp`. |
| Build caches (`CARGO_HOME`, `RUSTUP_HOME`, npm cache) | `/tmp` only, build stage only, never in the final image. |
| Logs | stdout/stderr via `env_logger`. No log file. |

Security expectations from the draft (non-root: no; read-only rootfs: no; privileged: no) are overridden by this plan: the image runs non-root (`apps`) and read-only capable. The chart's root override is a TrueCharts choice, not a requirement of the app.

## 10. Risks, caveats and open questions

- No release or tag: every update is a new commit. The git-refs renovate precedent tracks `main`. Decide with the maintainers whether pinning a commit is acceptable (the repo has been idle since 2025-02-02; no release process exists).
- Toolchain: the ubuntu 26.04 apt `cargo`/`rustc` version may be older than `Cargo.lock` or the crates require (UNVERIFIED). If so, use rustup with a pinned toolchain. Record the result.
- wasm32 target and `wasm-pack` installation: see section 4 step 3 (UNVERIFIED path).
- Node: the frontend needs Node LTS. Ubuntu apt Node may be older than `package.json` requires (UNVERIFIED `engines`). Check `package.json`; if needed, take Node from the `python-node` sibling's installation method (UNVERIFIED that it has Node, check `apps/changedetection`).
- arm64: the upstream claim exists (README) but the arm64 build is not tested. The draft says arm64 is untested. Do not claim arm64 until a build succeeds.
- Build cost: Rust release build with `lto = true` plus wasm-pack plus Vite is slow and RAM-heavy. Expect a long first build.
- Persistence: without `SQLITE_URI`, documents expire in memory. With it, documents are snapshotted to `/config`. The chart's default is persistent; keep that default.
- Blockers: none known. The draft's `FROM` and security expectations are re-checked and changed in section 9.

## 11. Build and test steps

From `apps/rustpad/`:

1. `docker buildx bake --print`: must exit 0.
2. `docker buildx bake --set image-local.platform=linux/amd64 image-local`.
3. Empty `/config` start, read-only:
   ```sh
   docker volume create rustpad-probe-config
   docker run --rm -d --name rustpad-probe --read-only --tmpfs /tmp \
     -v rustpad-probe-config:/config rustpad:<version>
   docker logs -f rustpad-probe   # expect a readiness line (listening / serving on 3030)
   ```
   Pass: the container stays running and logs a readiness signal with no panic. Then `docker rm -f rustpad-probe; docker volume rm rustpad-probe-config`.
4. Memory-only path: `docker run ... -e SQLITE_URI= rustpad:<version>` and check for a clean start (covers the empty-value branch).
5. `forgetool containers test --image rustpad:<version> --config ./container-test.yaml`. If `forgetool` is unavailable, check the 3030 port and `/` by hand per the protocol.
6. Note in the PR that arm64 was not built unless step 2 is repeated for arm64.

## 12. PR checklist

- Branch `feat/add-rustpad` from `main`; commit `feat(rustpad): add new container`; PR title the same.
- PR body from `.github/PULL_REQUEST_TEMPLATE.md`, every section and checkbox kept; only tick the boxes that apply.
- Notes section: `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge. Only the user can sign; the `license/cla` check shows status.
- Say what was not tested: arm64 build, the upstream `cargo test` suite, and any path not run in step 3 or 4. Do not tick "Built container locally" unless step 2 passed.
- No `DOWNSTREAM_CHANGES.md` (rustpad is not a `FROM` base).
