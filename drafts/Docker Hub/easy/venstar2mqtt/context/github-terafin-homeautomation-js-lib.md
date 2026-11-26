# terafin/homeautomation-js-lib

Source URL(s) + fetch date: https://github.com/terafin/homeautomation-js-lib (and `.git` variant, same repo) · https://raw.githubusercontent.com/terafin/homeautomation-js-lib/master/README.md · https://raw.githubusercontent.com/terafin/homeautomation-js-lib/master/package.json · fetched 2026-11-26

## What it is
- Author's shared helper library for Node MQTT bridge projects (README: "not meant to be used externally"). Used by mqtt-venstar-bridge as a git dependency.

## Install/build steps and build deps
- Installed by npm from git: `npm install github:terafin/homeautomation-js-lib#<commit>` (mqtt-venstar-bridge package.json uses the `.git` URL unpinned).
- No build step documented.

## Runtime deps
- package.json (name `homeautomation-js-lib`, version `0.0.1`, license MIT, no `main` field). All dependencies are set to `latest`: `graphite`, `js-yaml`, `lodash`, `log4js`, `mqtt`, `path`, `url`, `chokidar`.
- `path` and `url` are npm packages that shadow Node built-ins.

## Binaries/entrypoint/CLI flags
- None (library).

## Env vars
- Not documented in the README. (plan.md cites `health.js` reading `HEALTH_CHECK_PORT`, `HEALTH_CHECK_TIME`, `HEALTH_CHECK_URL`; this was not confirmed by the README or package.json fetch.)

## Ports
- Not documented in the README. (plan.md states an optional health server bound to `0.0.0.0:$HEALTH_CHECK_PORT`; unverified here.)

## Healthcheck/readiness endpoints
- Not documented in the README.

## Version/release info and asset naming
- Package version `0.0.1`; no tags per plan.md. Pin by commit SHA.

## Gotchas
- No `main` field in package.json.
- Transitive dependencies float (`latest`), so builds are not reproducible unless the library commit is pinned and the lockfile is managed (see plan.md section 10).
