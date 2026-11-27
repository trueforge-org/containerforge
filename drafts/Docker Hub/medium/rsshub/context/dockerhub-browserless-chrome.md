# Docker Hub: browserless/chrome (v1, legacy)

Source URL(s): https://hub.docker.com/v2/repositories/browserless/chrome/ and .../tags?page_size=10 (fetched 2026-11-27)

## What it is
- Headless Chrome in Docker, Puppeteer/Playwright/Selenium remote endpoint. ~177M pulls, 258 stars.
- Repository full description marks this image as the OLD v1 of Browserless; upstream recommends Browserless v2 (github.com/browserless/browserless).
- Last repo update 2024-02-16 (no newer pushes; tags frozen in 2024).
- Free for non-commercial use (upstream licensing).

## Ports / runtime (from upstream README)
- Listens on port 3000 (`docker run -p 3000:3000 browserless/chrome`); debugger at `/`.
- Accepts websocket connections (puppeteer.connect) and REST APIs (PDF, screenshots).

## Tags (from tags endpoint, sample)
| Tag | Last pushed | Notes |
| --- | --- | --- |
| latest | 2024-02-16 | amd64, arm64 |
| 1-chrome-stable | 2024-01-26 | amd64 |
| 1.61-chrome-stable | 2024-01-26 | amd64 |
| 1.61.1-chrome-stable | 2024-01-26 | amd64 (digest sha256:efac47cf...) |
| 1-puppeteer-10.4.0 / 1.61-puppeteer-10.4.0 / 1.61.1-puppeteer-10.4.0 | 2024-01-26 | amd64 |

- Total tags: 959.

## Gotchas
- TrueCharts pins `1.61.1-chrome-stable@sha256:efac47cf...` (the v1 image) as rsshub sidecar. Since it is legacy, no newer build exists.
