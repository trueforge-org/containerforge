# github.com/browserless/browserless (v2 line, maintained)

Source URL(s) + fetch date:
- https://github.com/browserless/browserless (repo, via raw README/package.json/LICENSE/scripts) · fetched 2026-11-26
- https://github.com/browserless/browserless/releases · fetched 2026-11-26
- https://raw.githubusercontent.com/browserless/browserless/main/package.json · fetched 2026-11-26
- https://raw.githubusercontent.com/browserless/browserless/main/LICENSE · fetched 2026-11-26
- https://raw.githubusercontent.com/browserless/browserless/main/scripts/start.sh · fetched 2026-11-26

## What it is
Headless Chrome/Chromium (plus Firefox/WebKit variants) remote browser service with Puppeteer/Playwright endpoints, REST APIs and BrowserQL. Node.js service, package `@browserless.io/browserless`.

## Install/build steps and build deps
- package.json scripts: `build` = `npm run clean && npm run build:ts && npm run install:adblock && npm run build:schemas && npm run build:devtools && npm run build:openapi`.
- `install:browsers` = `node node_modules/playwright-core/cli.js install chromium firefox webkit msedge`.
- `install:dev` combines browser install with debugger install; `build:function` and `install:debugger` are used by the upstream Dockerfile (`ghcr.io/browserless/base`).
- Upstream multi-stage Dockerfile (in the `browserless/chrome` repo, see that file): builder runs `npm run build`, `npm run build:function`, `npm run install:debugger`; runtime runs `npm prune --omit=dev`, then `bash ./scripts/install-chrome.sh`.
- Source tarball pattern (not downloaded): `https://github.com/browserless/browserless/archive/refs/tags/v${VERSION}.tar.gz` (direct archive, skipped per rules).

## Runtime deps
- Node.js engine: `>=24` (npm `>=11.10.0`) per package.json `engines`.
- Dependencies of note: `puppeteer-core` 25.18.1, `playwright-core` 1.65.1 (plus aliased 1.61-1.64), `@zorilla/puppeteer-extra` and stealth plugin, `lighthouse` ^13.6.0.
- Browser binaries are installed by `install:browsers` (Playwright chromium/firefox/webkit/msedge) or by `scripts/install-chrome.sh` in the upstream image (installs Google's Chrome deb for the native arch, per the browserless/chrome Dockerfile comment).
- Runtime also needs `dumb-init`, `Xvfb` (only when `DISPLAY` is unset), `node` on PATH (see start.sh).

## Binaries/entrypoint/CLI flags
- `scripts/start.sh` (upstream CMD of the Docker image): if `DISPLAY` is empty it starts `Xvfb :99 -noreset -screen 0 1024x768x16 -nolisten tcp -nolisten unix` and exports `DISPLAY=:99`. Removes stale `/tmp/.X99-lock`. Runs `dumb-init -- node build/index.js "$@"` (args passed through). Forwards SIGTERM/SIGINT to node, waits, exits with node's rc. Reads no token or Chrome flags.
- `package.json` `start`: `env-cmd -f .env node build` (main entry `./build/exports.js`, bin `bin/browserless.js`).
- Upstream image runs `CMD ["./scripts/start.sh"]` as `blessuser` (see browserless/chrome Dockerfile summary).

## Env vars
The README and start.sh document no env var names or defaults. Names seen in the enterprise Docker docs (docs-browserless-docker.md) and the TrueCharts chart (truecharts-browserless-chrome.md): `TOKEN`, `CONCURRENT`, `QUEUED`, `TIMEOUT`, `HEALTH`, `ENABLE_CORS`, `ALLOW_GET`, `DOWNLOAD_DIR`, `DATA_DIR`, `METRICS_JSON_PATH`, `DEBUG`, `TZ`. The package and docs do not state defaults for the open-source build; the plan's `PORT`/`HOST` names are not shown in fetched pages.
Note: the plan's `TOKEN` default behaviour (unauthenticated on private network) matches the docs: "Same private network: connecting without a token is allowed. External access: always use a token."

## Ports
- 3000 (docs, Puppeteer/Playwright via `ws://host:3000`, REST, `/docs` API docs, `/pressure` health, `/metrics`).

## Volumes/paths and persistent data
- Docs (enterprise image, Compose example): `./downloads:/downloads`, `./user_data:/user_data`, `./metrics:/metrics`, `./fonts:/usr/share/fonts/custom`.
- Writes temp browser data dirs to `/tmp/browserless-data-dirs/` (per start.sh comment).
- No `VOLUME` in the open-source README.

## User/UID & permissions
- Upstream image: `USER blessuser` (created in base image `ghcr.io/browserless/base`, not visible). start.sh does no chown/sudo; needs to delete `/tmp/.X99-lock` and start Xvfb.

## Healthcheck/readiness endpoints
- `/pressure` (used by the enterprise Compose healthcheck: `curl` against `/pressure`, 30s interval, 10s timeout, 3 retries, 40s start period).
- `/docs` serves API docs (open-source README: `http://localhost:3000/docs`).

## Version/release info and asset naming
- Latest release: **v2.64.4**, marked Latest, published 25 Nov 2026 (changelog 2026-11-25). Release assets count 2 but names not shown on the page (asset list did not load). Tag naming: `v<semver>` (e.g. `v2.64.4`).
- Recent sequence: 2.61.0, 2.62.0, 2.63.0-2.63.2, 2.64.0-2.64.4. No major jumps; nothing labelled breaking.
- v2.63.0 added a `TOKEN_HEADER` option and made strict route auth policies opt-in. v2.64.0 added extensible BrowserQL APIs and arm64 Chrome support. v2.64.4 fixed regex compatibility for BrowserQL network filters.
- Image names: `ghcr.io/browserless/chromium` (open-source, README); `ghcr.io/browserless/firefox`, `ghcr.io/browserless/multi`; enterprise `registry.browserless.io/browserless/browserless/enterprise` (needs license KEY).

## Arch support
- README: ARM64 fully supported, including Apple Silicon; Edge is amd64-only.
- Release notes: v2.64.0 "arm64 Chrome support" (conflicts with plan.md claim that arm64 Chrome stable does not exist; the claim concerned Google's .deb only).

## Config files and formats
None documented (no config file). BrowserQL endpoints: `/chromium/bql?token=...`, `/chrome/bql`, `/edge/bql`.

## License
`SPDX-License-Identifier: SSPL-1.0 OR Browserless Commercial License` (LICENSE: "dual-licensed under the MongoDB Server-Side Public License OR the browserless commercial license"). A commercial license is required for closed-source commercial sites, apps or closed-source CI use.

## Gotchas
- v2 image name differs from the draft's v1 image (`browserless/chrome`); the open-source Docker command is `docker run -p 3000:3000 ghcr.io/browserless/chromium`.
- Recommended `--shm-size=2g` (64 MB default causes crashes) per docs-browserless-docker.md.
- Open-source README does not document env vars; the env list above is from the enterprise docs and chart, not the OSS build.

## plan.md contradictions
- plan.md says the license is UNVERIFIED: confirmed SSPL-1.0 OR commercial.
- plan.md says Node major UNVERIFIED: confirmed `>=24`.
- plan.md says entrypoint `node build/index.js` UNVERIFIED: confirmed upstream runs `dumb-init -- node build/index.js` via `scripts/start.sh`.
- plan.md latest version v2.64.3: source shows v2.64.4 (25 Nov 2026).
- plan.md says arm64 Chrome stable does not exist (Google .deb amd64 only): release notes claim arm64 Chrome support in v2.64.0 (not reconciled).
