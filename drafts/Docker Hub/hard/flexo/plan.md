# flexo — implementation plan

> Source: ./draft.md · Target: apps/flexo/ · Difficulty: hard (no upstream Dockerfile; Rust source build; cache layout) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | 1.6.14 (git tag `1.6.14`, commit `e51893d678ba64b6806e4416de7026a769a992e5`, `flexo/Cargo.toml` version 1.6.14; matches the draft). The GitHub "Latest release" object is only 1.6.10 (2025-04-24), because newer versions are tags without release objects |
| Renovate | `datasource=github-tags depName=nroi/flexo versioning=semver` (tags have no `v` prefix). Do not use `github-releases`: it would lag at 1.6.10 |
| License | MIT (GitHub API `MIT`, `LICENSE` file in repo root). Bake `MIT` |
| Source URL | https://github.com/nroi/flexo (tarball `https://github.com/nroi/flexo/archive/refs/tags/${VERSION}.tar.gz`; Cargo project in subdirectory `flexo/`) |
| Per-arch downloads | None. Compile on amd64 and arm64 (draft: compile; copy-from only exists for amd64 `nroi/flexo:1.6.14` and is not used) |
| Checksum source | None for source tags. `Cargo.lock` (24,249 bytes) is committed, so build with `cargo build --release --locked` to pin dependencies |
| Upstream Dockerfile | None in the repo (draft confirms: only test fixtures under `flexo/tests/docker-test-local`). Docker usage documented in the wiki page "Flexo with Docker" and README |
| Cargo deps | curl 0.4 (needs libcurl dev + openssl dev), libc, http, rand, serde, toml, crossbeam, httparse, walkdir, log, chrono, humantime, env_logger, glob, regex, httpdate, uuid. The latest commit (2026-11-14) notes "Adds openssl 4 support" and bumps Rust to 1.96 in test Dockerfiles |
| Config | Two modes, chosen in `mirror_config.rs::load_config`: if ANY env var starting with `FLEXO_` is set, config comes ONLY from env; otherwise from `/etc/flexo/flexo.toml`. In env mode, `.unwrap()` is called on these (so all must be set or flexo panics): `FLEXO_CACHE_DIRECTORY`, `FLEXO_MIRRORLIST_FALLBACK_FILE`, `FLEXO_PORT`, `FLEXO_MIRROR_SELECTION_METHOD`, `FLEXO_MIRRORS_PREDEFINED`, and for `auto`: `FLEXO_MIRRORS_AUTO_HTTPS_REQUIRED`, `_IPV4`, `_IPV6`, `_MAX_SCORE`, `_NUM_MIRRORS`, `_MIRRORS_RANDOM_OR_SORT`, `_TIMEOUT`. Optional: `FLEXO_LISTEN_IP_ADDRESS`, `FLEXO_CONNECT_TIMEOUT`, `FLEXO_CUSTOM_REPO`, `FLEXO_LOW_SPEED_LIMIT`, `FLEXO_LOW_SPEED_LIMIT_FORMATTED`, `FLEXO_LOW_SPEED_TIME_SECS`, `FLEXO_MAX_SPEED_LIMIT`, `FLEXO_MIRRORLIST_LATENCY_TEST_RESULTS_FILE`, `FLEXO_NUM_VERSIONS_RETAIN`, `FLEXO_REFRESH_LATENCY_TESTS_AFTER`, `FLEXO_MIRRORS_AUTO_ALLOWED_COUNTRIES`, `FLEXO_MIRRORS_AUTO_MIRRORS_BLACKLIST`, `FLEXO_MIRRORS_AUTO_MIRRORS_STATUS_JSON_ENDPOINT(_FALLBACKS)`. Values are parsed as TOML (strings need quotes only per the type helper; comma lists for countries) |
| Default config (`flexo/conf/flexo.toml`) | `cache_directory="/var/cache/flexo/pkg"`, `mirrorlist_fallback_file="/var/cache/flexo/state/mirrorlist"`, `mirrorlist_latency_test_results_file="/var/cache/flexo/state/latency_test_results.json"`, `listen_ip_address="127.0.0.1"` (must become `0.0.0.0`), `port=7878`, `mirror_selection_method="auto"`, `num_versions_retain=3`, `[mirrors_auto]` with `https_required=true`, `ipv4=true`, `ipv6=false`, etc. The remaining `[mirrors_auto]` defaults (max_score, num_mirrors, timeout, random_or_sort) are in the file but were not all read (UNVERIFIED values) |
| Runtime behaviour | Cache dir and subdirs are created on demand (`create_dir_unless_exists`). Uncacheable temp files go to the hard-coded `/tmp/flexo/uncacheable`. Binds `listen_ip_address:port` (default 0.0.0.0 in code if unset). Cache purge runs `/usr/bin/flexo_purge_cache` (a bash script in the repo root) which needs `paccache` or `scruffy` and the env vars `FLEXO_CACHE_DIRECTORY` and `FLEXO_NUM_VERSIONS_RETAIN`; failure only logs a warning |
| scruffy | https://github.com/nroi/scruffy: GPL-2.0 (GitHub API), no releases, tag `0.2.0`, `Cargo.toml` shows version 0.1.0 (mismatch, UNVERIFIED which to pin) |
| Port | 7878/tcp (README, `flexo.toml`) |
| Binary names | Cargo package `flexo` in `flexo/`; installed by Arch package as `/usr/bin/flexo` (inferred) |

## 2. Target layout

```
apps/flexo/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh            defaults all FLEXO_* env vars, then execs flexo
  scripts/flexo_purge_cache   copy of upstream script (only if not shipped from the tarball in the build stage)
```

No `defaults/` needed (config comes from env mode, so no file seeding). No `root/`. No `DOWNSTREAM_CHANGES.md`. `scripts/` is only used if the purge script is not taken from the source tarball in the Dockerfile; prefer copying it from the tarball.

## 3. Base image

Build stage: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS build` with Rust installed from apt (`cargo rustc`; Ubuntu 26.04's rustc must be recent enough for the dependency set, UNVERIFIED; upstream tests use Rust 1.96, so if apt is older, install via `rustup` pinned to 1.96 with checksum, or use a `rust:1.96` build image). Final stage: the same ubuntu line. No Rust base exists in this repo (`go-runtime` rules are analogous: compile in a build stage, copy with `COPY --from=`). Closest sibling: `apps/adguardhome-sync` for the final layout; `apps/kasmvnc` for build-stage patterns.

## 4. Dockerfile

1. Build stage: `ARG VERSION`, `USER root`; `apt-get install -y --no-install-recommends cargo rustc pkg-config libssl-dev libcurl4-openssl-dev ca-certificates curl build-essential`. `ENV CARGO_HOME=/tmp/cargo CARGO_TARGET_DIR=/tmp/target`.
2. `curl -fL https://github.com/nroi/flexo/archive/refs/tags/${VERSION}.tar.gz | tar xz --strip-components=1 -C /src`; `cd /src/flexo && cargo build --release --locked`; strip the binary.
3. Optional second build: scruffy (`git clone` at a pinned tag/commit; add its own `SCRUFFY_VERSION` ARG and renovate comment), `cargo build --release --locked`. Needed because flexo's purge relies on `paccache` or `scruffy`, and `paccache` is Arch-only. Decision: include scruffy so the cache is bounded; set bake `LICENSE` to `MIT AND GPL-2.0-only` and ship both license files. If this is unwanted, document that the cache grows without bound.
4. Final stage: `ARG VERSION`, `USER root`; `apt-get install -y --no-install-recommends libssl3t64 libcurl4t64 bash` (names UNVERIFIED on 26.04; only add what `ldd` shows missing, `bash`/`curl`/`ca-certificates` are already in base so skip them); `COPY --from=build /tmp/target/release/flexo /usr/bin/flexo`, `COPY --from=build /src/flexo_purge_cache /usr/bin/flexo_purge_cache` (the script path is hard-coded in `main.rs`), scruffy to `/usr/bin/scruffy` if included. `chmod 0755`.
5. Licenses: `/usr/share/licenses/flexo/LICENSE` (MIT), plus scruffy's `LICENSE`/`COPYING` and a note about Cargo dependency licenses (`cargo license` is optional).
6. `ENV HOME=/config`. Cache is in `/config` so no `/var/cache` dirs are needed.
7. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 7878`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}
variable "APP" { default = "flexo" }
variable "VERSION" {
  // renovate: datasource=github-tags depName=nroi/flexo versioning=semver
  default = "1.6.14"
}
variable "LICENSE" { default = "MIT" }   # "MIT AND GPL-2.0-only" if scruffy is bundled
variable "SOURCE"  { default = "https://github.com/nroi/flexo" }
```

Add `SCRUFFY_VERSION` (with `// renovate: datasource=github-tags depName=nroi/scruffy`) only if scruffy is bundled. Standard `group "default"`, `image`, `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (amd64 + arm64) as in `apps/adguardhome-sync`. Run `docker buildx bake --print`.

## 6. settings.yaml

- `upstream_env_url: "https://github.com/nroi/flexo"`.
- ports: `7878` tcp `required: false`.
- env (every name below is read by flexo; defaults equal those exported by start.sh): `TZ` (`Etc/UTC`), `FLEXO_PORT` (`7878`), `FLEXO_LISTEN_IP_ADDRESS` (`0.0.0.0`), `FLEXO_CACHE_DIRECTORY` (`/config/cache/pkg`), `FLEXO_MIRRORLIST_FALLBACK_FILE` (`/config/cache/state/mirrorlist`), `FLEXO_MIRRORLIST_LATENCY_TEST_RESULTS_FILE` (`/config/cache/state/latency_test_results.json`), `FLEXO_MIRROR_SELECTION_METHOD` (`auto`), `FLEXO_MIRRORS_PREDEFINED` (`[]`), `FLEXO_NUM_VERSIONS_RETAIN` (`3`), `FLEXO_MIRRORS_AUTO_ALLOWED_COUNTRIES` (`""`), `FLEXO_MIRRORS_AUTO_HTTPS_REQUIRED` (`true`), `FLEXO_MIRRORS_AUTO_IPV4` (`true`), `FLEXO_MIRRORS_AUTO_IPV6` (`false`), `FLEXO_MIRRORS_AUTO_MAX_SCORE`, `FLEXO_MIRRORS_AUTO_NUM_MIRRORS`, `FLEXO_MIRRORS_AUTO_MIRRORS_RANDOM_OR_SORT`, `FLEXO_MIRRORS_AUTO_TIMEOUT` (values for the last four copied from upstream `flexo.toml` at implementation time, UNVERIFIED here), `FLEXO_CUSTOM_REPO` (`""`).
- volumes: `/config` required (cache and state); the chart used an emptyDir at `/var/cache/flexo`, here the cache is persistent by design.
- dependencies: none.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
: "${FLEXO_CACHE_DIRECTORY:=/config/cache/pkg}"
: "${FLEXO_MIRRORLIST_FALLBACK_FILE:=/config/cache/state/mirrorlist}"
: "${FLEXO_MIRRORLIST_LATENCY_TEST_RESULTS_FILE:=/config/cache/state/latency_test_results.json}"
: "${FLEXO_PORT:=7878}"
: "${FLEXO_LISTEN_IP_ADDRESS:=0.0.0.0}"
: "${FLEXO_MIRROR_SELECTION_METHOD:=auto}"
: "${FLEXO_MIRRORS_PREDEFINED:=[]}"
: "${FLEXO_NUM_VERSIONS_RETAIN:=3}"
# ... same pattern for the FLEXO_MIRRORS_AUTO_* values required by env mode
export FLEXO_CACHE_DIRECTORY FLEXO_MIRRORLIST_FALLBACK_FILE ...   # all of the above
mkdir -p "$FLEXO_CACHE_DIRECTORY" "$(dirname "$FLEXO_MIRRORLIST_FALLBACK_FILE")" /tmp/flexo/uncacheable
exec /usr/bin/flexo
```

Key rules: because setting any `FLEXO_*` var switches flexo to env-only mode, start.sh MUST export every required variable with defaults (taken from upstream `flexo.toml`), otherwise it panics on `unwrap()`. Env values are TOML-parsed, so quote strings consistently; validate or escape user input for `FLEXO_CUSTOM_REPO` (space separated `name@url`, split on `@`). Idempotent: only `mkdir -p`. Nothing written to `/app`; `/tmp/flexo/uncacheable` lives in `/tmp` (hard-coded upstream). Listens on `0.0.0.0`. `/usr/bin/flexo_purge_cache` is invoked by flexo itself and needs `FLEXO_CACHE_DIRECTORY` and `FLEXO_NUM_VERSIONS_RETAIN` exported, which this script guarantees.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
tcp:
- port: '7878'
filePaths:
- /usr/bin/flexo
- /usr/bin/flexo_purge_cache
```

One probe for the single settings port. An `http` probe on `/` is not defined for a package proxy (UNVERIFIED which path returns 200), so the TCP probe plus file checks is the starting point; consider `GET /status` if upstream exposes one (UNVERIFIED). Startup can include a mirror latency test over the internet; with no internet in CI the app falls back to the fallback file or the predefined list and may log errors but should keep listening (UNVERIFIED), so raise `timeoutSeconds` if the first run is slow. Test runs without env, which exercises the all-defaults path in start.sh.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path | Remap |
| --- | --- |
| `/var/cache/flexo/pkg` (package cache) | `/config/cache/pkg` via `FLEXO_CACHE_DIRECTORY` |
| `/var/cache/flexo/state` (mirrorlist fallback, latency results) | `/config/cache/state` via the two `FLEXO_*_FILE` vars |
| `/tmp/flexo/uncacheable` (hard-coded) | stays in `/tmp` (tmpfs) |
| `/etc/flexo/flexo.toml` | unused (env mode) |
| Cargo/registry caches at build | `/tmp/cargo`, `/tmp/target` |

Draft expectations: chart says non-root possible (568), read-only rootfs possible, no privileges, cache as 10Gi emptyDir at `/var/cache/flexo`. All hold: UID 568, read-only rootfs, no capabilities. The cache now sits under `/config`; users who want a throwaway cache can mount a tmpfs or emptyDir there.

## 10. Risks, caveats and open questions

- Env-vs-file config switch: any single `FLEXO_*` variable disables the TOML file and requires the full set; document this in settings.yaml/README and keep start.sh defaults complete. Defaults for the four `[mirrors_auto]` numeric/enum values must be copied from the pinned upstream `flexo.toml`.
- Purge dependency: without `scruffy` (GPL-2.0, tag/version mismatch) or `paccache`, the cache is never trimmed; flexo only warns. Bundling scruffy changes the image's license string.
- Rust toolchain version on Ubuntu 26.04 apt is UNVERIFIED against the Rust 1.96 that upstream's latest commit expects; use `rustup` or a pinned toolchain download if apt is too old.
- openssl 4 support was just added upstream; Ubuntu 26.04 ships OpenSSL 3.x, so verify the crate versions build against it.
- Startup contacts `archlinux.org` for the mirror list and probes mirrors; offline start relies on fallback data (an empty `/config` has none, so the first start needs internet or `predefined` mirrors).
- Flexo only helps once Arch clients point their `mirrorlist` at it (`Server = http://<host>:7878/$repo/os/$arch`), a manual step (draft caveat).
- The GitHub "latest release" for `nroi/flexo` is 1.6.10, tags go to 1.6.14, so renovate must use tags.
- arm64: the draft marks no copy-from for arm64; compile-from-source on arm64 is untested.

## 11. Build and test steps

```sh
cd apps/flexo
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name flexo-probe --read-only --tmpfs /tmp \
  -v flexo-probe-config:/config flexo:1.6.14
docker logs -f flexo-probe
# from a second container on the same network:
#   curl -sI http://flexo-probe:7878/core/os/x86_64/core.db
forgetool containers test --image flexo:1.6.14 --config ./apps/flexo/container-test.yaml
docker rm -f flexo-probe; docker volume rm flexo-probe-config
```

Readiness signal: a log line for the TCP listener on `0.0.0.0:7878` (set `RUST_LOG=debug` to see "Listen on address ..."), process alive, no panic about a missing `FLEXO_*` variable. Functional check: request an Arch DB file through the proxy and confirm a file appears under `/config/cache/pkg`. Cap at 10 rounds.

## 12. PR checklist

- Branch `feat/add-flexo`; commit `feat(flexo): add new container`; same PR title; target `main`.
- Fill in `.github/PULL_REQUEST_TEMPLATE.md`; check only applicable boxes.
- Notes section includes `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only they can sign; `license/cla` check shows status).
- Untested items to list: arm64 build, scruffy-based cache purge, offline first start, Rust toolchain on Ubuntu 26.04, behaviour with a real Arch client.
- Pre-completion: bake `--print` ok, Dockerfile/bake aligned (`VERSION`, optional `SCRUFFY_VERSION`), rootless + read-only verified, empty `/config` start verified, no downstream `FROM` consumers.
