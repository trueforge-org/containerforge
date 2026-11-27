# linuxserver/docker-quassel-web s6 scripts

Source URLs (fetched 2026-11-27, GitHub contents API, base64 decoded):
- https://api.github.com/repos/linuxserver/docker-quassel-web/contents/root/etc/s6-overlay/s6-rc.d/init-quassel-web-config/run
- https://api.github.com/repos/linuxserver/docker-quassel-web/contents/root/etc/s6-overlay/s6-rc.d/svc-quassel-web/run

## init-quassel-web-config (oneshot)
- Shebang `/usr/bin/with-contenv bash`.
- `chownfiles`: `lsiown -R abc:abc` on `/app/quassel-web/public` and `/config`.
- If `/config/settings-user.js` exists: `mv` to `/config/settings-user.cjs` (migration).
- If `QUASSEL_CORE` or `QUASSEL_PORT` unset: copy `/app/quassel-web/settings.cjs` to `/config/settings-user.cjs` (if missing), chown, exit 0. User must edit that file.
- If both set: `cp -pr settings.cjs settings-env.cjs`, then `sed -i`:
  - `host:` -> `QUASSEL_CORE` (quoted).
  - `port:` (quasselcore comment line) -> `QUASSEL_PORT`.
  - If `URL_BASE` set: `prefixpath:` -> `URL_BASE` (quoted).
  - If `QUASSEL_HTTPS` empty: `mode:` -> `'http'` and listening `port:` -> `64080`.
- Ends with chownfiles. No chmod.

## svc-quassel-web (longrun)
- Shebang `/usr/bin/with-contenv bash`. `NODE_ENV=production`.
- CONFIG = `/app/quassel-web/settings-env.cjs` if it exists and `QUASSEL_CORE` set, else `/config/settings-user.cjs`.
- PORT parsed from the `webserver: {...}` block of CONFIG (sed/grep/awk).
- Start (PORT not "null"):
  ```
  s6-notifyoncheck -d -n 300 -w 1000 -c "nc -z localhost ${PORT}" \
    cd /app/quassel-web s6-setuidgid abc node app.js --config "${CONFIG}"
  ```
- Fallback (PORT "null"): same, readiness check `true`.
- Working dir `/app/quassel-web`. User `abc` (s6-setuidgid).

## Env vars read
| Name | Use |
| --- | --- |
| `QUASSEL_CORE` | core host; enables env injection |
| `QUASSEL_PORT` | core port |
| `QUASSEL_HTTPS` | empty = http mode, port 64080 |
| `URL_BASE` | prefixpath |

## Gotchas
- Config lives at `/config/settings-user.cjs` (not `.js`) after migration.
- Port for readiness is read from config, not env (except http fallback 64080).
