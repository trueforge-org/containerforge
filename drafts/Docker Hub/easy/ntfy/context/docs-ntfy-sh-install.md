# docs.ntfy.sh install (Docker)

**Source URL(s) + fetch date**
- https://docs.ntfy.sh/install/ (fetched 2026-11-26). Draft's docs link https://docs.ntfy.sh/ is covered by this and the config page.

**Install/build steps and build deps**
- `docker run -p 80:80 -it binwiederhier/ntfy serve`
- Persistent cache: `docker run -v /var/cache/ntfy:/var/cache/ntfy -p 80:80 -it binwiederhier/ntfy serve --cache-file /var/cache/ntfy/cache.db`
- Architectures listed: amd64, armv6, armv7, arm64.

**Volumes/paths**
- `/var/cache/ntfy` (persistent message cache), `/etc/ntfy` (config; `server.yml`). Image ships without `server.yml`; map `/etc/ntfy` or build a custom image with `ENTRYPOINT ["ntfy", "serve"]`.

**Env vars**
- `TZ` (timezone). Kustomize example sets `NTFY_DEBUG`, `NTFY_LOG_LEVEL`, `NTFY_BASE_URL`.

**Ports**
- 80 (web UI and API).

**User/UID & permissions**
- `-u UID:GID` supported; `server.yml`, `user.db`, `cache.db`, attachments dir chowned to the same UID/GID.

**Healthcheck/readiness endpoints**
- `http://localhost:80/v1/health`, response contains `"healthy": true` (compose example: wget + grep; interval 60s, timeout 10s, retries 3, start period 40s).
- Compose also uses `init: true` with the healthcheck, to avoid zombie processes.

**Gotchas**
- Compose example uses `restart: unless-stopped`; not an image requirement.
