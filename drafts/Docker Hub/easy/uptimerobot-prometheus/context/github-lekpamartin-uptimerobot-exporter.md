# lekpamartin/uptimerobot_exporter (application source, Dockerfile, exporter.py, README)

**Source URL(s) + fetch date**
- https://github.com/lekpamartin/uptimerobot_exporter (repo root, fetched 2026-11-26)
- https://raw.githubusercontent.com/lekpamartin/uptimerobot_exporter/a64c74a3690080b2bfb65c947b050d8a76bef15b/Dockerfile (fetched 2026-11-26)
- https://raw.githubusercontent.com/lekpamartin/uptimerobot_exporter/a64c74a3690080b2bfb65c947b050d8a76bef15b/README.md (fetched 2026-11-26)
- https://raw.githubusercontent.com/lekpamartin/uptimerobot_exporter/a64c74a3690080b2bfb65c947b050d8a76bef15b/files/exporter.py (fetched 2026-11-26)
- https://github.com/lekpamartin/uptimerobot_exporter/archive/refs/heads/master.zip: direct archive download, not fetched (skipped).
- LICENSE: not fetched separately (repo page shows Apache-2.0).

**What it is**
Prometheus exporter for UptimeRobot, using the UptimeRobot v3 API. Single Python file (`files/exporter.py`) using `requests` and `http.server.ThreadingHTTPServer`. Apache-2.0.

**Install/build steps and build deps (upstream Dockerfile at a64c74a)**
- Two-stage build. `FROM python:3.15-alpine3.24 AS base` (target platform filesystem) and `FROM --platform=$BUILDPLATFORM python:3.15-alpine3.24 AS build`.
- In `build`: copies `/` of base to `/rootfs`, removes pip from `/rootfs`, then `pip install --no-cache-dir --no-compile --target /rootfs/app/deps --only-binary=:all: --platform any --implementation py --abi none --python-version <detected> requests` (pure-Python wheels only).
- `FROM scratch`, labels `maintainer=LEKPA`, `org.opencontainers.image.source`, `.description`, `.licenses=Apache-2.0`.
- `COPY --from=build /rootfs /`, `COPY files/exporter.py /app/exporter.py`.
- ENV: `PATH=/usr/local/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin`, `LANG=C.UTF-8`, `PYTHONPATH=/app/deps`, `PYTHONUNBUFFERED=1`, `PYTHONDONTWRITEBYTECODE=1`.
- `USER nobody`, `EXPOSE 9705`.
- `HEALTHCHECK CMD ["python3", "-c", "... urlopen('http://127.0.0.1:%s/' % os.environ.get('UPTIMEROBOT_SERVER_PORT', '9705'), timeout=5)"]` (hits `/`, which does not call the API).
- `CMD ["python3", "/app/exporter.py"]`. No ARG, WORKDIR, VOLUME or ENTRYPOINT.

**Runtime deps**
Python 3.8+ (README) and `requests`. The README's install command is `pip install requests`. `requirements.txt` also lists lint and test tools (do not install).

**Binaries/entrypoint/CLI flags**
- `python files/exporter.py -h` (argparse).
- Positional `apikey` (optional, `nargs="?"`, default `UPTIMEROBOT_API_KEY`).
- `--server_name` / `-s`, `--server_port` / `-p`, `--cache_ttl`, `--response_times` (store_true), `--response_time_window`, `--api_url`.

**Env vars** (from `files/exporter.py` and README)

| Variable | Arg | Default | Notes |
|---|---|---|---|
| `UPTIMEROBOT_API_KEY` | `apikey` | none | required |
| `UPTIMEROBOT_SERVER_NAME` | `--server_name` | `0.0.0.0` | bind address |
| `UPTIMEROBOT_SERVER_PORT` | `--server_port` | `9705` | int |
| `UPTIMEROBOT_CACHE_TTL` | `--cache_ttl` | `60` | float seconds |
| `UPTIMEROBOT_RESPONSE_TIMES` | `--response_times` | `""` (false) | true for `1`, `true`, `yes`, `on` (case-insensitive) |
| `UPTIMEROBOT_RESPONSE_TIME_WINDOW` | `--response_time_window` | `3600` | int seconds |
| `UPTIMEROBOT_API_URL` | `--api_url` | `https://api.uptimerobot.com/v3` | trailing slash stripped |

**Startup without an API key (verified in `exporter.py`)**
If the key is empty or missing after parsing, the script calls `parser.error("an API key is required (argument or UPTIMEROBOT_API_KEY)")`. argparse prints usage and that message, then exits with **status 2**. The container exits at start without a key.

**Ports**
9705/tcp. Server is `ThreadingHTTPServer((server_name, server_port))`, default all interfaces.

**Routes**
- `/metrics`: Prometheus text, content type `text/plain; version=0.0.4; charset=utf-8`, 200.
- `/`: HTML page titled "UptimeRobot Exporter" with a link to `/metrics`. No API call.
- Other paths: 404 `Not Found`. GET only.

**Startup**
Logs `Listening on %s:%d` (via `logging.basicConfig`, default stderr). No API requests at startup; only the `requests.Session` (Bearer auth, Accept, User-Agent) and the Collector are created.

**API calls on scrape of `/metrics`**
If the cache is younger than `cache_ttl`, or a rate-limit backoff is active, no calls are made. Otherwise: `GET /monitors` (paginated, `limit=200`, cursor from `nextLink`), `GET /user/me`, `GET /psps` (paginated), and if response times are on, `GET /monitors/{id}/stats/response-time` (`from` param) per up monitor. Timeout 30 s. HTTP 429: back off using `Retry-After`. Other errors: back off `min(cache_ttl, 60)` s. Both report `uptimerobot_up 0` during backoff.

**Volumes/paths and persistent data**
None. No disk writes; cache in memory only.

**User/UID & permissions**
`USER nobody` (scratch image). Port 9705 above 1024.

**Healthcheck/readiness endpoints**
- Upstream HEALTHCHECK: `/` on `UPTIMEROBOT_SERVER_PORT`.
- README: `uptimerobot_up` metric is 1 when the last API query succeeded.

**Version/release info and asset naming**
- README references git tags `vX.Y.Z` and a registry with `X.Y.Z` tags and `latest`. README production tip: pin a release tag such as `1.0.0`. Tags are not confirmed by the fetch (repo page shows no release count or names; Tags link has no number).
- Plan.md states no releases and no tags (tags API empty) at 2026-11-23. Contradiction with the README's tag mentions; unverified which is current.
- Pinned commit `a64c74a3690080b2bfb65c947b050d8a76bef15b` (plan.md; 2026-11-15 commit date per plan.md, not confirmed here).
- Repo has 49 commits; default branch `master`.

**Arch support**
README: image platforms amd64, arm/v6, arm/v7, arm64. Dockerfile uses pure-Python wheels, so no native build.

**Licence**
Apache-2.0 (repo page; Dockerfile label `org.opencontainers.image.licenses="Apache-2.0"`). `LICENSE` not fetched.

**Docker details (README)**
- ghcr.io/lekpamartin/uptimerobot_exporter (also Docker Hub lekpamartin/uptimerobot_exporter).
- Tags: `latest` (last commit on master), `X.Y.Z` and `X.Y` (from git tags `vX.Y.Z`), `sha-<commit>`.
- Image based on official python Alpine, no pip, non-root, Trivy-scanned before publish.
- Run example: `docker run -d --name uptimerobot_exporter -e 'UPTIMEROBOT_API_KEY=...' -p 9705:9705 --read-only ghcr.io/lekpamartin/uptimerobot_exporter:latest`.

**Rate limits (README)**
Free plan: 10 requests/minute. Paid plans: `monitor_limit × 2`. Each refresh costs 3 requests (monitors, account, public status pages), plus one per up monitor with response times on. Results cached for `UPTIMEROBOT_CACHE_TTL`. Free-plan monitors checked every 5 minutes, so `scrape_interval: 5m` is enough.

**API key (README)**
From the Integrations & API page of the UptimeRobot dashboard. A read-only key is sufficient.

**Gotchas**
- Without a key the process exits with status 2 (verified). A start.sh fallback would need to change this.
- `--response_times` adds one request per up monitor per refresh.
- The README's non-Docker run uses `python files/exporter.py -h`.
