# GitHub: nroi/flexo

Source URL(s) + fetch date (2026-11-26):
- https://github.com/nroi/flexo (repo)
- https://raw.githubusercontent.com/nroi/flexo/master/README.md
- https://raw.githubusercontent.com/nroi/flexo/master/flexo/conf/flexo.toml (follow-up)
- https://github.com/nroi/flexo/tags (follow-up)
- https://api.github.com/repos/nroi/flexo/releases/latest

## What it is

- Caching proxy for Arch Linux (pacman) repos. Rust. Cargo project in `flexo/`.
- Single binary under 3 MB. Linux only. x86_64 standard; ARM (incl. Raspberry Pi) works per README.
- Docker image `nroi/flexo` on Docker Hub (see `dockerhub-nroi-flexo.md`).

## Build / deps

- No full Cargo recipe in README. Tests: `cargo test` in `flexo/`.
- README ARM cross-build hint: `cross` tool, plus `openssl = { version = "0.10", features = ["vendored"] }` in Cargo.toml (plan uses system libssl-dev; not reconciled).

## Binaries / runtime

- Binary: `flexo`. Systemd unit `flexo.service` on Arch (not relevant in container).
- Cache cleanup needs `paccache` (Arch-only) or `scruffy` (`github-nroi-scruffy.md`) off Arch.
- README: "No purge script is mentioned."
- First start runs latency tests for ~30 s and serves no requests during that time (README).

## Env vars

Names in `github-nroi-flexo-wiki.md`. Rule: TOML key path upper-cased, joined by `_`, prefixed `FLEXO_`.

## Upstream defaults (raw `flexo/conf/flexo.toml`)

| Key | Default |
| --- | --- |
| cache_directory | `/var/cache/flexo/pkg` |
| connect_timeout | `3000` (ms) |
| mirrorlist_fallback_file | `/var/cache/flexo/state/mirrorlist` |
| mirrorlist_latency_test_results_file | `/var/cache/flexo/state/latency_test_results.json` |
| listen_ip_address | `127.0.0.1` (README: use `0.0.0.0` for LAN) |
| port | `7878` |
| mirror_selection_method | `auto` (or `predefined`) |
| mirrors_predefined | `[]` (must not be empty when `predefined`) |
| num_versions_retain | `3` (`0` = keep indefinitely) |
| mirrors_auto.mirrors_status_json_endpoint | `https://archlinux.org/mirrors/status/json/` |
| mirrors_auto.mirrors_status_json_endpoint_fallbacks | `["https://raw.githubusercontent.com/nroi/archlinux-mirrors-status-fallback/main/mirrorlist.json"]` |
| mirrors_auto.mirrors_blacklist | `[ ]` |
| mirrors_auto.https_required | `true` |
| mirrors_auto.ipv4 | `true` |
| mirrors_auto.ipv6 | `false` |
| mirrors_auto.max_score | `2.5` |
| mirrors_auto.num_mirrors | `8` |
| mirrors_auto.mirrors_random_or_sort | `sort` (or `random`) |
| mirrors_auto.timeout | `350` (ms) |
| mirrors_auto.refresh_latency_tests_after | `8 days` |
| mirrors_auto.allowed_countries | `[]` (empty = test all) |

Commented-out options: `low_speed_limit_formatted` (e.g. `"2 MBit/s"`), `max_speed_limit` (e.g. `102400`), `[[custom_repo]]` (`name`, `url`; placed before `[mirrors_auto]`).

## Ports

- 7878/tcp.

## Volumes / paths

- Cache `/var/cache/flexo/pkg`; state `/var/cache/flexo/state/`. If moved, copy contents and give user `flexo` rw.

## Config file

- AUR install path `/etc/flexo/flexo.toml` (TOML with comments). README's ARM section says `/etc/flexo.toml` (typo).
- Not stated in sources: whether any `FLEXO_*` env var disables the file. Plan's env-only-mode claim is UNVERIFIED.

## Version / release info

- Tags (newest first): 1.6.14 (Nov 14 2026, e51893d), 1.6.13 (Jul 4 2026), 1.6.12 (Jun 24 2026), 1.6.11 (Jun 21 2026), 1.6.10 (Apr 24 2025), 1.6.9 ... 1.6.5. No `v` prefix.
- Latest GitHub release (API): tag `1.6.10`, published 2025-04-24, no assets.
- 1.6.14 is a bare tag (no release object, inferred from tags page).
- Source archives only: `https://github.com/nroi/flexo/archive/refs/tags/<tag>.tar.gz` / `.zip`.

## Gotchas

- Conflict with plan sections 8 and 11: README says no requests are served during the ~30 s first-start latency test. Plan assumes listening during startup; the 120 s probe timeout covers it.
- Empty `mirrors_predefined` with `predefined` is invalid.
- Changing `allowed_countries` requires deleting `latency_test_results.json` and restarting.
- Healthcheck: no documented endpoint. Chart probes `/metrics` (UNVERIFIED upstream).
