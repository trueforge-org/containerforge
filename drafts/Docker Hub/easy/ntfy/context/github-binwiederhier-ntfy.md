# binwiederhier/ntfy

**Source URL(s) + fetch date**
- https://github.com/binwiederhier/ntfy (README via raw `v2.38.2`)
- https://raw.githubusercontent.com/binwiederhier/ntfy/v2.38.2/Dockerfile
- https://raw.githubusercontent.com/binwiederhier/ntfy/v2.38.2/server/server.yml
- https://github.com/binwiederhier/ntfy/releases/tag/v2.38.2 (page; asset list did not render)
- https://api.github.com/repos/binwiederhier/ntfy/releases/tags/v2.38.2 (asset list, used for names)
- Fetched 2026-11-26. The draft pins `v2.38.1`; plan.md pins `v2.38.2` (latest release).

**What it is**
- ntfy: HTTP pub-sub push notification server, single Go binary (`ntfy`), with CLI client subcommands. Dual licensed Apache-2.0 / GPLv2 (`LICENSE` and `LICENSE.GPLv2` in repo root; README).

**Install/build steps and build deps**
- Upstream image build (`Dockerfile` at v2.38.2): `FROM alpine`, `ARG VERSION=dev`, `RUN apk add --no-cache tzdata`, `COPY ntfy /usr/bin`, `EXPOSE 80/tcp`, `ENTRYPOINT ["ntfy"]`. No CMD, USER, ENV or VOLUME. Labels include `org.opencontainers.image.licenses="Apache-2.0, GPL-2.0"`.
- Release tarballs are the prebuilt binary; the README credits list GoReleaser (build tooling). No build deps are needed to use them.

**Runtime deps**
- None beyond tzdata (upstream). Binary is static (per plan.md inspection of amd64 tarball; not re-verified here).

**Binaries/entrypoint/CLI flags**
- `ntfy serve` runs the server. Upstream `ENTRYPOINT ["ntfy"]`, so the server needs the `serve` argument.
- `--cache-file`, `--config`/`-c` are CLI flags (docs install page shows `serve --cache-file /var/cache/ntfy/cache.db`).

**Env vars**
- Each config key maps to `NTFY_` + key with hyphens turned to underscores and uppercased (README/docs). Names used in examples: `NTFY_BASE_URL`, `NTFY_CACHE_FILE`, `NTFY_AUTH_FILE`, `NTFY_AUTH_DEFAULT_ACCESS`, `NTFY_BEHIND_PROXY`, `NTFY_ATTACHMENT_CACHE_DIR`, `NTFY_ENABLE_LOGIN`, `NTFY_UPSTREAM_BASE_URL`, `NTFY_DATABASE_URL`, `NTFY_LISTEN_HTTP` (chart), `NTFY_LOG_LEVEL` (docs install kustomize example), `NTFY_DEBUG`.
- `TZ` sets timezone (docs install page).
- List options are comma-separated (`NTFY_AUTH_USERS`, `NTFY_AUTH_ACCESS`). Bcrypt `$` must be escaped as `$$` in Compose.
- Not verified here: `NTFY_CONFIG_FILE` (not present in fetched text).

| Key (server.yml) | Default | Notes |
| --- | --- | --- |
| `listen-http` | `":80"` | comma-separated list allowed; `-` disables |
| `base-url` | unset | needed for attachments, email footers, iOS self-hosted push |
| `cache-file` | unset (in-memory) | SQLite cache; in-memory cache kept `cache-duration` 12h |
| `auth-file` | unset (auth off) | SQLite user DB; packages suggest `/var/lib/ntfy/user.db` |
| `auth-default-access` | `read-write` | `read-only`, `write-only`, `deny-all` |
| `attachment-cache-dir` | unset | local dir or S3 URL; needs `base-url` |
| `behind-proxy` | `false` | takes client IP from `proxy-forwarded-header` (default `X-Forwarded-For`) |
| `upstream-base-url` | unset | normally `https://ntfy.sh`; enables instant iOS push (see Gotchas) |
| `web-root` | `/` | also `app`, `home`, `disable` |
| `log-level` | `info` | |
| `enable-metrics` | `false` | |

**Ports**
- 80/tcp (web UI and API), upstream default.

**Volumes/paths and persistent data**
- Upstream Docker docs: `/var/cache/ntfy` (message cache), `/etc/ntfy` (config, `server.yml`).
- Packages: `/var/cache/ntfy/cache.db`, `/var/lib/ntfy/user.db`, attachments under the configured dir.
- Config path default: `/etc/ntfy/server.yml` (image ships without it).

**User/UID & permissions**
- Upstream image runs as root by default; docs say `-u UID:GID` works and the `server.yml`, `user.db`, `cache.db`, attachments dir must be owned by that UID/GID.

**Config files and formats**
- `server.yml` (YAML). Keys above; full list in the README-linked server.yml (fetched, long).

**Healthcheck/readiness endpoints**
- `GET /v1/health` returns JSON containing `"healthy": true` (docs install page, compose example uses wget on `http://localhost:80/v1/health` and greps for `"healthy": true`).

**Version/release info and asset naming**
- Release `v2.38.2`, published 2026-11-24T13:21:40Z, not prerelease, marked Latest. 15 assets. Names (verified via API):
  - `ntfy_2.38.2_linux_amd64.tar.gz`, `ntfy_2.38.2_linux_arm64.tar.gz`, `ntfy_2.38.2_linux_armv6.tar.gz`, `ntfy_2.38.2_linux_armv7.tar.gz`
  - matching `.deb` and `.rpm` for each linux arch
  - `ntfy_2.38.2_darwin_all.tar.gz`, `ntfy_2.38.2_windows_amd64.zip`
  - `checksums.txt`
- Pattern: `ntfy_<version>_linux_<arch>.tar.gz`, `checksums.txt` in the same release.
- `checksums.txt` could not be read: the download URL 302-redirects to a signed `release-assets.githubusercontent.com` URL, which the fetch tool does not follow. Not retried (signed URL).

**Arch support**
- Linux amd64, arm64, armv6, armv7 release tarballs. Docker Hub lists amd64, armv7, arm64. Docs install page lists amd64, armv6, armv7, arm64.

**Gotchas**
- `base-url` required for attachments (`attachment-cache-dir` needs it).
- Behind a reverse proxy, set `behind-proxy`; otherwise all visitors share one rate limit.
- iOS: without `upstream-base-url` (`https://ntfy.sh`) delivery can take hours; with it, the server sends a poll request to upstream for each message and the iOS app fetches the real message from your server (docs config page). Upstream access token only needed for rate limits or a protected upstream.
- Message sizes above 4K break FCM and APNS delivery (server.yml comment).
- With `database-url` (PostgreSQL), `cache-file`, `auth-file`, `web-push-file` must not be set.
- Plan check: `/v1/health` and the asset names in plan.md match upstream. The plan's "`cache-file` unset (in-memory, 12h)" matches. No factual contradictions found in this source.
