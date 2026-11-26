# GitHub: nroi/flexo

Source URL(s) + fetch date:
- https://github.com/nroi/flexo (repo root, README via raw `master/README.md`, config via raw `master/flexo/conf/flexo.toml`, tags page `https://github.com/nroi/flexo/tags`), fetched 2026-11-26

## What it is

- Caching proxy for Arch Linux (pacman) package repositories. Written in Rust. Cargo project lives in the `flexo/` subdirectory.
- README: "single file under 3 MB" binary. Docker image `nroi/flexo` on Docker Hub (see `dockerhub-nroi-flexo.md`). AUR package `flexo-git` (not fetched).
- Linux is the only supported OS. x86_64 Arch is the standard target. README says ARM (incl. Raspberry Pi) also works.

## Install/build steps and build deps

- README gives no full Cargo build recipe. Tests: `cargo test` inside `flexo/`.
- Cross-compiling for ARM: README suggests the `cross` tool and a vendored openssl entry in `Cargo.toml`: `openssl = { version = "0.10", features = ["vendored"] }`. The plan uses the system `libssl-dev` instead; both are consistent with the README only if the vendored feature is not required for a normal build (not verified).
- ARM options listed by README: native AUR build (recommended), build the Docker image on the device, or cross-compile.

## Binaries/entrypoint/CLI flags

- Binary: `flexo` (single file). Not documented beyond that in the README.
- Systemd unit on Arch: `flexo.service` (logs: `journalctl --unit=flexo`). Not relevant inside a container.
- README: "No purge script is mentioned." Cache cleanup off Arch needs `paccache` or `scruffy`. See `github-nroi-scruffy.md`.

## Env vars

The env var names are documented in `github-nroi-flexo-wiki.md` (Flexo with Docker page). Each TOML key maps to `FLEXO_` + upper-case path (nested keys joined with `_`, e.g. `mirrors_auto.https_required` -> `FLEXO_MIRRORS_AUTO_HTTPS_REQUIRED`). Upstream default values (from raw `flexo.toml`):

| Key (TOML) | Default |
| --- | --- |
| cache_directory | `/var/cache/flexo/pkg` |
| connect_timeout | `3000` (ms) |
| mirrorlist_fallback_file | `/var/cache/flexo/state/mirrorlist` |
| mirrorlist_latency_test_results_file | `/var/cache/flexo/state/latency_test_results.json` |
| listen_ip_address | `127.0.0.1` (README: use `0.0.0.0` for LAN access) |
| port | `7878` |
| mirror_selection_method | `auto` (or `predefined`) |
| mirrors_predefined | `[]` (must not be empty when method is `predefined`) |
| num_versions_retain | `3` (`0` keeps packages indefinitely) |
| low_speed_limit_formatted | commented out (example `"2 MBit/s"`) |
| [mirrors_auto] mirrors_status_json_endpoint | `https://archlinux.org/mirrors/status/json/` |
| [mirrors_auto] mirrors_status_json_endpoint_fallbacks | `["https://raw.githubusercontent.com/nroi/archlinux-mirrors-status-fallback/main/mirrorlist.json"]` |
| [mirrors_auto] mirrors_blacklist | `[ ]` |
| [mirrors_auto] max_speed_limit | commented out (example `102400`) |
| [mirrors_auto] https_required | `true` |
| [mirrors_auto] ipv4 | `true` |
| [mirrors_auto] ipv6 | `false` |
| [mirrors_auto] max_score | `2.5` |
| [mirrors_auto] num_mirrors | `8` |
| [mirrors_auto] mirrors_random_or_sort | `sort` (or `random`) |
| [mirrors_auto] timeout | `350` (ms) |
| [mirrors_auto] refresh_latency_tests_after | `8 days` |
| [mirrors_auto] allowed_countries | `[]` (ISO codes; empty = test all) |

Note: this resolves the plan's "UNVERIFIED" values for `max_score`, `num_mirrors`, `mirrors_random_or_sort` and `timeout`.

`[[custom_repo]]` (commented out in the file): `name = "archzfs"`, `url = "https://archzfs.com"` (URL without the `$repo/$arch` part). Must be placed before `[mirrors_auto]`. Client side: `Server = http://localhost:7878/custom_repo/archzfs/$repo/$arch`.

## Ports

- 7878/tcp (README and `flexo.toml`).

## Volumes/paths and persistent data

- Default cache: `/var/cache/flexo/pkg`. State: `/var/cache/flexo/state/` (mirrorlist fallback, latency test results JSON).
- README: if the cache is moved, copy the contents and give user `flexo` read and write access.
- Cache subdirectories are created by flexo on demand (plan, not from these sources).

## Config files and formats

- Installed config path (AUR): `/etc/flexo/flexo.toml`, TOML with comments. README's ARM section refers to `/etc/flexo.toml`, which looks like a typo.
- Env mode and file mode: the fetched sources do not state when env vars override the file. The plan's "any FLEXO_* var switches to env-only mode" is NOT confirmed here.
- Predefined mirror entries omit the `$repo/os/$arch` suffix, e.g. `"https://mirror.org/archlinux/"`.

## Healthcheck/readiness endpoints

- Not documented in the README. The TrueCharts chart probes `/metrics` (see `truecharts-flexo.md`). Whether `/metrics` exists upstream is UNVERIFIED.

## Version/release info and asset naming

- Tags (newest first, from `https://github.com/nroi/flexo/tags`): 1.6.14 (Nov 14 2026, commit e51893d), 1.6.13 (Jul 4 2026, 2459e15), 1.6.12 (Jun 24 2026, d303437), 1.6.11 (Jun 21 2026, 144eb1c), 1.6.10 (Apr 24 2025, 8d43af9), 1.6.9 (May 31 2023), 1.6.8, 1.6.7, 1.6.6, 1.6.5.
- Tags have no `v` prefix. 1.6.10 is the only tag with a published release note; 1.6.14 appears to be a bare tag (inference, not confirmed by the page).
- No named release assets. Only GitHub auto-generated source archives: `1.6.14.tar.gz` and `1.6.14.zip` (i.e. `https://github.com/nroi/flexo/archive/refs/tags/<tag>.tar.gz`).
- README does not state a version number; the Docker tag and `pacman -Qi flexo` are the suggested checks.

## Arch support

- Linux only. x86_64 standard. ARM (Raspberry Pi etc.) supported per README; serving ARM packages needs a `custom_repo` to an Arch Linux ARM mirror.

## Gotchas

- Plan contradiction: README "Runtime behavior" says the first start runs latency tests for roughly half a minute and "serves no requests during that time". The plan (section 8 and 11) assumes flexo keeps listening during startup and uses a TCP probe. Not corrected in plan.md (not a clear factual error); the 120s probe timeout in the plan should cover it.
- Empty `mirrors_predefined` with `mirror_selection_method = "predefined"` is invalid per README (must not be empty).
- After changing `allowed_countries`, delete `/var/cache/flexo/state/latency_test_results.json` and restart (README).
- `num_versions_retain = 0` disables purging (keeps everything).
- Cleanup needs `paccache` or `scruffy`; without either, the cache is not trimmed (README, consistent with plan).
- README links to `./mirror_selection.md`, `flexo/terminology.md` (not fetched).
