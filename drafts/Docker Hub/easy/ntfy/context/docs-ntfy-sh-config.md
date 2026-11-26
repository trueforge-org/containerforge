# docs.ntfy.sh config reference

**Source URL(s) + fetch date**
- https://docs.ntfy.sh/config/ (fetched 2026-11-26; page truncated by the fetch tool after the "Tuning for scale" section, so the Health checks and Monitoring sections were not readable).

**Config and env naming**
- Each option maps to an env var with `NTFY_` prefix; hyphens become underscores, uppercase.
- Listen: `listen-http` default `:80`; `listen-https`, `listen-unix` optional.
- `base-url`: needed for attachments; used for attachment URLs and email footers.
- `attachment-cache-dir`: local directory or S3 URL. Example `/var/lib/ntfy/attachments`. ntfy owns the directory; do not share it.
- Attachment defaults: total `5G`, per file `15M`, expiry `3h`.
- `cache-file` (SQLite) makes the message cache persistent; without it the cache is in memory and does not survive restarts. `cache-duration` default `12h`.
- `auth-file` enables auth (SQLite); example path `/var/lib/ntfy/user.db`. `auth-default-access` default `read-write`; `deny-all` for a private instance.
- `database-url` (PostgreSQL): when set, `cache-file`, `auth-file` and `web-push-file` must not be set; implicitly enables auth.
- `behind-proxy`: required behind a reverse proxy; env `NTFY_BEHIND_PROXY=true`. `proxy-forwarded-header` default `X-Forwarded-For`. Proxy must forward `Connection` and `Upgrade` for WebSockets.
- `upstream-base-url` (env `NTFY_UPSTREAM_BASE_URL`, usually `https://ntfy.sh`): for every incoming message the server sends a `poll_request` upstream carrying the original message ID in `X-Poll-ID`; the upstream forwards it via Firebase/APNS to the iOS device, which then fetches the message from your server. Sent text is "New message". Without it, delivery can take hours (docs say about 20-30 minutes when the phone is in use). `upstream-access-token` only for rate limits or a protected upstream.
- Web Push: `web-push-file` is the SQLite file for web push subscriptions.
- `log-level` default `info`; `log-format` default `text`; logs to stderr unless `log-file` set.
- `keepalive-interval` default `45s` (should stay under 77s because of the Android app).

**Gotchas**
- Message size over 4K breaks FCM and APNS delivery.
- Examples use bcrypt hashes; in Compose, escape `$` as `$$`.
