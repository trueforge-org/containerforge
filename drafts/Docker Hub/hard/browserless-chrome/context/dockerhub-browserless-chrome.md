# hub.docker.com/r/browserless/chrome (Docker Hub, draft image)

Source URL(s) + fetch date:
- https://hub.docker.com/r/browserless/chrome · fetched 2026-11-26

## What it is
Headless Chrome in Docker ("Deploy headless Chrome in Docker"), free for non-commercial use. Puppeteer, Selenium and Playwright supported; REST APIs for PDF generation and data collection; fonts, missing libraries, downloads and session management handled. Image size 1.2 GB; 100M+ pulls; described as last updated almost 3 years before the fetch.

## Deprecation / version notice
Page says this is the **old v1** of Browserless and recommends version 2 (github.com/browserless/browserless).

## Tags and arch
- `latest` (only recent tag listed), `1-arm64` (arm64 production tag), `arm64` (local build example).
- amd64 implied default; arm64 via `docker buildx build --platform linux/arm64`; Chromium may not match bundled Puppeteer version on arm64.

## Run / ports / env
- `docker run -p 3000:3000 browserless/chrome`; debugger at `http://localhost:3000/`; `/session` returns running sessions as JSON.
- Connect: Puppeteer `browserWSEndpoint: 'ws://localhost:3000'`; Selenium `.usingServer('http://localhost:3000/webdriver')`; Playwright `chromium.connect`.
- Behind nginx: proxy Upgrade headers (HTTP/1.1, `Connection 'upgrade'`).
- The page lists no environment variables.

## License
Free for non-commercial use; commercial use incl. closed-source CI requires purchase. GPLv3-compatible open-source projects may use it under GPLv3.

## Gotchas
- Draft tag `1.61.1-chrome-stable` belongs to this v1 line, which the page itself calls old. plan.md's switch to v2 (ghcr.io/browserless/chromium) is consistent with this notice.
- Docker Hub v1 license wording (GPLv3 / commercial) differs from the v2 license (SSPL-1.0 OR commercial). Do not assume the v1 terms apply to v2.
