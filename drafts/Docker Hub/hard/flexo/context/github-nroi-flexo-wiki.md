# GitHub wiki: nroi/flexo

Source URL(s) + fetch date:
- https://github.com/nroi/flexo/wiki (Home), fetched 2026-11-26
- https://github.com/nroi/flexo/wiki/Flexo-with-Docker (followed from the README; the only other sidebar page), fetched 2026-11-26

## What it is

- Home: essentially empty ("Welcome to the flexo wiki!"), last edited Mar 5 2023. Sidebar lists 2 pages: Home and Flexo with Docker. The sidebar showed a loading-error banner; page content was still returned.
- The wiki itself says `flexo.toml` in the repo is the authoritative list of settings because the wiki may be outdated.

## Install/build steps and build deps

- None on the wiki. Docker usage only.

## Env vars

Docker page: settings go in an env file passed with `docker run --env-file my-environment-file`. Every TOML setting has a `FLEXO_` variable. Variables listed:

```
FLEXO_CACHE_DIRECTORY
FLEXO_CONNECT_TIMEOUT
FLEXO_CUSTOM_REPO
FLEXO_LISTEN_IP_ADDRESS
FLEXO_LOW_SPEED_LIMIT
FLEXO_LOW_SPEED_LIMIT_FORMATTED
FLEXO_LOW_SPEED_TIME_SECS
FLEXO_MAX_SPEED_LIMIT
FLEXO_MIRRORLIST_FALLBACK_FILE
FLEXO_MIRRORLIST_LATENCY_TEST_RESULTS_FILE
FLEXO_MIRRORS_AUTO_ALLOWED_COUNTRIES
FLEXO_MIRRORS_AUTO_HTTPS_REQUIRED
FLEXO_MIRRORS_AUTO_IPV4
FLEXO_MIRRORS_AUTO_IPV6
FLEXO_MIRRORS_AUTO_MAX_SCORE
FLEXO_MIRRORS_AUTO_MIRRORS_BLACKLIST
FLEXO_MIRRORS_AUTO_MIRRORS_RANDOM_OR_SORT
FLEXO_MIRRORS_AUTO_MIRRORS_STATUS_JSON_ENDPOINT
FLEXO_MIRRORS_AUTO_MIRRORS_STATUS_JSON_ENDPOINT_FALLBACKS
FLEXO_MIRRORS_AUTO_NUM_MIRRORS
FLEXO_MIRRORS_AUTO_TIMEOUT
FLEXO_MIRROR_SELECTION_METHOD
FLEXO_MIRRORS_PREDEFINED
FLEXO_NUM_VERSIONS_RETAIN
FLEXO_PORT
FLEXO_REFRESH_LATENCY_TESTS_AFTER
```

Note: `FLEXO_LOW_SPEED_LIMIT_FORMATTED` and `FLEXO_MAX_SPEED_LIMIT` are not in the plan's list; `FLEXO_LOW_SPEED_TIME_SECS` is also in this list. Plan's section 1 optional list names `FLEXO_LOW_SPEED_LIMIT` and others; these match upstream.

Format notes:
- Country codes comma-separated, no spaces: `FLEXO_MIRRORS_AUTO_ALLOWED_COUNTRIES=DE,AT`.
- Predefined list is a bracketed list of single-quoted URLs: `FLEXO_MIRRORS_PREDEFINED=['https://mirror.fra10.de.leaseweb.net/archlinux/', 'https://ftp.halifax.rwth-aachen.de/archlinux' ]`.
- Custom repos: `FLEXO_CUSTOM_REPO` formatted like `"eschwartz@https://pkgbuild.com archzfs@https://archzfs.com"` (per the README; space-separated `name@url` pairs).
- Example env for auto mode: `FLEXO_MIRROR_SELECTION_METHOD=auto` with `FLEXO_MIRRORS_AUTO_ALLOWED_COUNTRIES=DE,AT`.

## Ports

- Not documented on the wiki page. `FLEXO_PORT` exists; no value given here. Upstream default 7878 (see `github-nroi-flexo.md`).

## Volumes/paths

- Not documented on the wiki page (no volume or mount instructions, no docker run example beyond `--env-file`).

## Arch client setup

- Not on the wiki page. README gives `Server = http://172.17.0.1:7878/$repo/os/$arch` (example host) and for custom repos `Server = http://localhost:7878/custom_repo/<name>/$repo/$arch`.

## Gotchas

- The wiki page has no ARM/platform, first-run or limitation notes.
- Wiki may be outdated; use `flexo.toml` as the reference, as the page itself says.
