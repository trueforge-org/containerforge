# fireshare-app/fireshare

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/fireshare-app/fireshare/v1.9.4/Dockerfile.lite (fetched 2026-11-26)
- https://raw.githubusercontent.com/fireshare-app/fireshare/v1.9.4/docs/EnvironmentVariables.md (fetched 2026-11-26; names and defaults verbatim, meanings paraphrased by the fetch tool)
- https://raw.githubusercontent.com/fireshare-app/fireshare/v1.9.4/README.md (fetched 2026-11-26; summary)
- https://raw.githubusercontent.com/fireshare-app/fireshare/HEAD/app/server/requirements.txt (fetched 2026-11-26)
- https://github.com/fireshare-app/fireshare/releases/tag/v1.9.3 (fetched 2026-11-26; release notes)
- https://github.com/fireshare-app/fireshare (repo, referenced by the draft and plan)
- Source tarball (not downloaded, binary archive): https://github.com/fireshare-app/fireshare/archive/refs/tags/v${VERSION}.tar.gz

## What it is

Self-hosted video and image library: scans folders, gives each file a shareable URL (original file, no re-encode), per-file privacy, multi-user, 2FA, IP whitelist, optional transcoding. Single container, no external DB (SQLite in `/data`). Flask + gunicorn backend, React client, nginx in front.

## Install/build steps (upstream Dockerfile.lite, v1.9.4)

Stage `node:24-slim AS client`: `WORKDIR /app`, `ENV PATH=/app/node_modules/.bin:$PATH`, copies `app/client/package.json`, `package-lock.json`, `.env.*`; `npm ci --silent`; copies `app/client/`; `npm run build`.

Final stage `python:3.14-slim-bookworm`, `WORKDIR /`:
- apt: `nginx-extras supervisor libssl-dev libffi-dev libc-dev build-essential gosu ca-certificates tzdata ffmpeg libvulkan1 mesa-vulkan-drivers` (`--no-install-recommends`, lists removed).
- `ln -sf /dev/stdout /var/log/nginx/access.log`, `ln -sf /dev/stderr /var/log/nginx/error.log`.
- `mkdir /data && mkdir /processed`.
- `COPY entrypoint.sh /`, `COPY entrypoint-lite.sh /`, `COPY app/nginx/prod.conf /etc/nginx/nginx.conf.template`, `COPY app/nginx/error.html /etc/nginx/error.html`, `COPY app/nginx/api_unavailable.html /etc/nginx/api_unavailable.html`, `COPY app/server/ /app/server`, `COPY migrations/ /migrations`, `COPY --from=client /app/build /app/build`, `COPY --from=client /app/package.json /app`.
- `pip install --no-cache-dir --ignore-installed /app/server`, then purge `libssl-dev libffi-dev libc-dev build-essential`, `autoremove`, clean apt lists and `/root/.cache/pip /tmp/*`.
- ENV: `FLASK_APP=/app/server/fireshare:create_app()`, `ENVIRONMENT=production`, `DATA_DIRECTORY=/data`, `VIDEO_DIRECTORY=/videos`, `IMAGE_DIRECTORY=/images`, `PROCESSED_DIRECTORY=/processed`, `TEMPLATE_PATH=/app/server/fireshare/templates`, `ADMIN_PASSWORD=admin`, `ANALYTICS_TRACKING_SCRIPT=""`, `TZ=UTC`, `PATH=/usr/local/bin:$PATH`, `FIRESHARE_LITE=true`, `TRANSCODE_GPU=false` (lite script enforces it at runtime).
- `EXPOSE 80`; `CMD ["bash", "/entrypoint-lite.sh"]`.
- No `USER`, `VOLUME`, `HEALTHCHECK`, `ENTRYPOINT` in Dockerfile.lite; runs as root (entrypoint handles PUID/PGID).

Full (non-lite) `Dockerfile` in the same repo is a CUDA build (see `github-shaneisrael-fireshare.md`): not used.

## Runtime deps

- Python 3.14 (Dockerfile.lite base), Flask stack (requirements below), ffmpeg (Debian apt), nginx-extras, Mesa Vulkan (libplacebo tone map).
- Client build needs Node 24 (`node:24-slim`).

## Pinned Python requirements (`app/server/requirements.txt`, HEAD)

`click==8.1.8`, `ffmpeg-python==0.2.0`, `Flask==3.1.1`, `Flask-Cors==5.0.1`, `Flask-Login==0.6.3`, `Flask-Migrate==4.1.0`, `Flask-SQLAlchemy==3.1.1`, `Flask-WTF==1.2.2`, `gunicorn==23.0.0`, `itsdangerous==2.2.0`, `Jinja2==3.1.6`, `MarkupSafe==3.0.2`, `six==1.17.0`, `SQLAlchemy==2.0.40`, `Werkzeug==3.1.3`, `WTForms==3.2.1`, `xxhash==3.5.0`, `apscheduler==3.11.0`, `requests==2.32.3`, `pyotp==2.9.0`, `qrcode==8.2`. Minimum-only: `greenlet>=3.1.0`, `Pillow>=10.0.0`, `rapidfuzz>=3.10.0`.

## Binaries/entrypoint/CLI flags

- Entrypoint (lite): `/entrypoint-lite.sh` (CMD). `/entrypoint.sh` also copied. Contents not fetched (plan's startup-order description is therefore unverified here).
- CLI used by plan: `flask db upgrade`, `fireshare migrate-game-assets`, `python -m fireshare.cli create-boomerang-posters` (from plan; not fetched).

## Env vars (docs/EnvironmentVariables.md, v1.9.4; names and defaults verbatim)

| Name | Default | Meaning (paraphrase) |
| --- | --- | --- |
| `DOMAIN` | none | base URL; sharing links, notifications |
| `STEAMGRIDDB_API_KEY` | none | game art |
| `MINUTES_BETWEEN_VIDEO_SCANS` | `5` | scan interval; `0` disables auto-scan |
| `ANALYTICS_TRACKING_SCRIPT` | none | `<script>` injected into frontend |
| `TZ` | `UTC` | timezone |
| `FS_LOGLEVEL` | `INFO` | DEBUG/INFO/WARNING/ERROR/CRITICAL |
| `THUMBNAIL_VIDEO_LOCATION` | `50` | thumbnail second mark |
| `DATA_DIRECTORY` | `$(pwd)/fireshare/data/` | required; DB and metadata (Dockerfile.lite: `/data`) |
| `PROCESSED_DIRECTORY` | `$(pwd)/fireshare/processed/` | required; transcodes, symlinks, posters (`/processed`) |
| `VIDEO_DIRECTORY` | `$(pwd)/path/to/my/videos/` | required; source videos (`/videos`) |
| `IMAGE_DIRECTORY` | `$(pwd)/path/to/my/images/` | required; source images (`/images`) |
| `DEMO_MODE` | `false` | demo mode |
| `DEMO_UPLOAD_LIMIT_MB` | `0` | |
| `DEMO_MODE_DELETE_ALL` | `false` | wipes dirs at startup (demo only) |
| `SECRET_KEY` | generated | saved to `/data/.secret_key` |
| `ADMIN_USERNAME` | `admin` | initial admin |
| `ADMIN_PASSWORD` | `admin` | initial admin; reapplied every start |
| `DISABLE_ADMINCREATE` | `false` | no auto admin on first run |
| `LOGIN_IP_WHITELIST` | none | comma-separated IPs/CIDRs; malformed prevents startup |
| `LOGIN_IP_WHITELIST_TRUSTED_PROXIES` | `1` | `2` behind another proxy |
| `LDAP_*` | n/a | removed; app will not start if set |
| `CORS_ORIGINS` | unset | `*` rejected |
| `SECURE_COOKIES` | `false` | |
| `ENABLE_TRANSCODING` | `false` | |
| `TRANSCODE_GPU` | `false` | NVENC (not in lite) |
| `NVIDIA_DRIVER_CAPABILITIES` | `compute,utility,video` | NVIDIA toolkit (GPU image only) |
| `TRANSCODE_TIMEOUT` | `7200` | seconds |
| `DISCORD_WEBHOOK_URL` | none | |
| `GENERIC_WEBHOOK_URL` | none | |
| `GENERIC_WEBHOOK_PAYLOAD` | none | |
| `PUID` | `1000` | process uid (entrypoint) |
| `PGID` | `1000` | process gid (entrypoint) |
| `FIRESHARE_PORT` | `80` | nginx port inside container |
| `GUNICORN_WORKERS` | `min(cpu_count × 2 + 1, 4)` | |
| `GUNICORN_WORKER_CAP` | `4` | `0` removes cap |
| `GUNICORN_THREADS` | `8` | |

MFA/2FA is per-account in Settings, no env vars.

## Ports

- nginx listens on 80 in the container (`FIRESHARE_PORT`, default 80; "mainly relevant with network_mode: host"). Compose example publishes `8080:80`.

## Volumes/paths and persistent data

- `/data` (internal database, `.secret_key`), `/processed` (posters, metadata), `/videos` (source videos), `/images` (source images). Dockerfile.lite creates `/data` and `/processed`.
- `TEMPLATE_PATH=/app/server/fireshare/templates`.

## User/UID & permissions

- Dockerfile.lite: no USER; `PUID`/`PGID` default 1000 (entrypoint). Docs: match PUID/PGID to host directory owner. Standard image: `adduser nginx` (full Dockerfile only).

## Config files and formats

- nginx template at `/etc/nginx/nginx.conf.template` (from `app/nginx/prod.conf`), error pages `error.html`, `api_unavailable.html` in `/etc/nginx/`.

## Healthcheck/readiness endpoints

- None in Dockerfile.lite. Plan's test uses `/`.

## Version/release info and asset naming

- Release v1.9.3 page: notes on security fix (password-protected video download), images behaving like videos, PUID fixes for non-1000 users, uploads on fresh named volumes. Assets listed "2" (names not captured; likely auto source archives).
- Plan: v1.9.4 tag; GitHub "Latest" v1.9.5 at check time (not verified here). Chart pins `1.9.6` (see truecharts file), which contradicts plan's "latest v1.9.5" claim and is unverified.
- Source archive: `archive/refs/tags/v${VERSION}.tar.gz` (tag `v` prefix; `VERSION` without `v`).

## Arch support

- Dockerfile.lite uses `python:3.14-slim-bookworm` and Debian apt; arch not stated in fetched text.

## License

- GPLv3 (per https://fireshare.net, "GPLv3", no paid tier). Repo LICENSE not fetched.

## Gotchas

- Dockerfile.lite forces `TRANSCODE_GPU=false` via `entrypoint-lite.sh`.
- `ADMIN_PASSWORD=admin` default is upstream's; reapplied each start.
- `LDAP_*` variables make the app fail to start.
- `LOGIN_IP_WHITELIST` malformed entries prevent startup.
- Requirements use `>=` for three packages; not pinned.

## Contradictions with plan.md

- None on port (plan uses 8080 for the non-root image, upstream 80; a deliberate change), env var names/defaults (match), license GPLv3 (matches).
- Plan's "Latest v1.9.5" is not confirmed here (chart pins 1.9.6).
