# modem7/newyearcountdown (Docker Hub)

**Source URL(s) + fetch date**
- https://hub.docker.com/r/modem7/newyearcountdown (fetched 2026-11-26)

**What it is**
- Docker Hub page for the self-hosted New Year countdown image. Credits patrickgold as original creator.

**Install/build steps and build deps**
- `docker run -d --name newyearcountdown -p 8080:8080 modem7/newyearcountdown`
- Compose: service `newyearcountdown`, image `modem7/newyearcountdown`, container name `NewYearCountdown`, port `8080:8080`.
- Then open `http://localhost:8080`.

**Version/release info and asset naming**
- Only tag: `latest` (digest begins `sha256:7a3b00067…`, size 24.7 MB).
- "Last updated about 1 month ago" (at fetch time); about 9.2K pulls.

**Arch support**
- amd64, arm/v6, arm/v7, arm64/v8.

**Env vars**
- None documented ("no configuration needed").

**Volumes/paths and persistent data**
- None documented.

**Ports**
- 8080.

**User/UID & permissions**
- Built on `nginxinc/nginx-unprivileged`, runs as uid 101.

**Healthcheck/readiness endpoints**
- `/healthz` backs the built-in HEALTHCHECK.

**Gotchas**
- Page states the image is MIT licensed and that CI runs a Playwright check that the countdown rolls over to "Happy New Year!".
