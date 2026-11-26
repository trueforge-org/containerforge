# docs.browserless.io/docs/docker.html (enterprise Docker docs)

Source URL(s) + fetch date:
- https://docs.browserless.io/docs/docker.html · fetched 2026-11-26
- https://docs.browserless.io/ (docs home) · fetched 2026-11-26

## Scope
This page documents the **enterprise** image, not the open-source one. Open-source image is `ghcr.io/browserless/chromium` (see github-browserless-browserless.md). Enterprise image: `registry.browserless.io/browserless/browserless/enterprise` (login with `docker login registry.browserless.io`; registry credentials are separate from the license key). Arch: ARM64 and AMD64. Pinning recommended (example `:2.3.0`).

## Run examples
- `docker run --rm -p 3000:3000 -e KEY=<license> registry.browserless.io/browserless/browserless/enterprise:latest`
- With token: `-e TOKEN=<token>`; env file `--env-file .env` with `KEY`, `TOKEN`, `CONCURRENT=20`.
- Compose: `services.browserless` with `KEY`, `TOKEN`, port `"3000:3000"`.

## Env vars (no defaults stated on the page)
| Variable | Example value | Meaning |
|---|---|---|
| KEY | license key | Enterprise features |
| TOKEN | API token | API auth |
| CONCURRENT | 20 (15 in webhook example) | Concurrent sessions |
| QUEUED | 30 | Queue size |
| TIMEOUT | 300000 | Session timeout (ms) |
| DOWNLOAD_DIR | /downloads | Download storage |
| DATA_DIR | /user_data | User data |
| METRICS_JSON_PATH | /metrics/metrics.json | Metrics file |
| ENABLE_CORS | false | CORS |
| ALLOW_GET | false | GET requests |
| ALLOW_FILE_PROTOCOL | false | file:// |
| HEALTH | true | Health checking |
| MAX_MEMORY_PERCENT | 90 | Memory threshold |
| MAX_CPU_PERCENT | 90 | CPU threshold |
| DEBUG | browserless* | Debug logs |
| TZ | America/New_York | Timezone |
| QUEUE_ALERT_URL, REJECT_ALERT_URL, TIMEOUT_ALERT_URL, FAILED_HEALTH_URL | webhook URLs | Alerts |

## Ports and endpoints
- Container port 3000. `/docs` (API docs), `/pressure` (health), `/metrics`.
- Puppeteer `browserWSEndpoint` at `/chromium`; Playwright `chromium.connectOverCDP` at `/chromium`; REST POST `/screenshot`, `/content` with `url`.
- WebSocket auth: `ws://host:3000/chromium?token=...`; REST accepts `?token=` or `Authorization: Bearer` (header recommended). Token Roles: admin, developer, viewer.

## Shared memory
Docker default `/dev/shm` 64 MB can crash Chrome. Recommended `--shm-size=2g` (Compose `shm_size: '2g'`). Alternative `--ipc=host` (weaker isolation).

## Volumes (Compose example)
`./downloads:/downloads`, `./user_data:/user_data`, `./metrics:/metrics`, `./fonts:/usr/share/fonts/custom`.

## Healthcheck
Compose: curl against `/pressure`, interval 30s, timeout 10s, 3 retries, start period 40s.

## Resource guidance
Minimum 2 CPU cores and 4 GB RAM; medium 4 cores / 8 GB / 10-20 sessions / 50 GB storage. Log cap json-file 10m x 5.

## Sandbox
No guidance on `--no-sandbox` on this page; launch parameters are referenced via `/enterprise/launch-options` (not fetched).

## Docs home (https://docs.browserless.io/)
Quick links: Getting Started (/overview/comparison), BrowserQL, BaaS, REST APIs, MCP, AI integrations; index at /llms.txt. No self-hosting image list or edition comparison on the home page.
