# browserless-chrome: source context (fetched 2026-11-26)

## Sources fetched

| Source URL | Summary file |
| --- | --- |
| https://github.com/browserless/browserless (README, package.json, LICENSE, scripts/start.sh) | github-browserless-browserless.md |
| https://github.com/browserless/browserless/releases | github-browserless-browserless.md |
| https://github.com/browserless/chrome (README) | github-browserless-chrome.md |
| https://github.com/browserless/chrome/releases | github-browserless-chrome.md |
| https://github.com/browserless/chrome/blob/2ebe1345023358d9006a3058b17dbfcc87347843/docker/chrome/Dockerfile | github-browserless-chrome.md |
| https://hub.docker.com/r/browserless/chrome | dockerhub-browserless-chrome.md |
| https://docs.browserless.io/docs/docker.html | docs-browserless-docker.md |
| https://docs.browserless.io/ | docs-browserless-docker.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/browserless-chrome (values.yaml) | truecharts-browserless-chrome.md |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link (never fetched) |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge base app link |
| https://github.com/browserless/browserless/archive/refs/tags/v${VERSION}.tar.gz | direct archive download; asset pattern recorded in github-browserless-browserless.md (`v<semver>` tags) |

## Fetch failures

None. Not fetched in full: the Browserless docs home only gave navigation (no OSS self-hosting page found); the enterprise `/enterprise/launch-options` page was referenced but not followed.

## plan.md corrections

- Section 1 Version: `v2.64.3 (2026-11-23)` -> `v2.64.4 (2026-11-25)`; `Recommend 2.64.3` -> `Recommend 2.64.4`. Source: github-browserless-browserless.md (releases page lists v2.64.4 as Latest).
- Section 1 License: "UNVERIFIED ... believed to be SSPL-1.0 or commercial" -> `SSPL-1.0 OR Browserless Commercial License`. Source: github-browserless-browserless.md (LICENSE, package.json).
- Section 1 Download: "browsers installed via npm/playwright at build (UNVERIFIED exact script names)" -> `npm run install:browsers` (verified). Source: github-browserless-browserless.md (package.json scripts).
- Section 3: "required Node major for 2.64.3 UNVERIFIED" -> Node `>=24` per package.json engines. Source: github-browserless-browserless.md. Note: the `python-node` base's Node major was NOT checked; still needs confirmation.
- Section 5: VERSION `2.64.3` -> `2.64.4`; LICENSE "UNVERIFIED, likely SSPL-1.0" -> `SSPL-1.0` (dual with commercial). Source as above.
- Section 7 step 3: `exec node build/index.js` -> `exec dumb-init -- node build/index.js`. Source: github-browserless-browserless.md (scripts/start.sh runs `dumb-init -- node build/index.js` and starts Xvfb when DISPLAY is unset).
- Section 11: `browserless-chrome:2.64.3` -> `browserless-chrome:2.64.4` (all occurrences).

## Verified but left unchanged (plan.md still reads UNVERIFIED)

- Section 1 Env: docs for OSS list no env vars; enterprise docs name `CONCURRENT`, `QUEUED`, `TIMEOUT`, `TOKEN`, `DOWNLOAD_DIR`, `DATA_DIR`, `METRICS_JSON_PATH`, `HEALTH`. `HOST`/`PORT` names not found in fetched pages.
- Section 8: `/docs` is the API docs page in the OSS README (plan says UNVERIFIED path).
- Section 9: `DOWNLOAD_DIR` and `METRICS_JSON_PATH` exist in enterprise docs (plan says check); `/config/downloads` mapping still to set and verify on the OSS build.

## Conflicts noted (not edited)

- arm64: plan.md says arm64 Chrome stable does not exist. The browserless v2.64.0 release notes list "arm64 Chrome support" (see github-browserless-browserless.md). Left as-is; needs a runtime check.
- Shared-memory and sandbox: docs recommend `--shm-size=2g`; no sandbox guidance in the docs (plan's `--no-sandbox` decision stays open).
