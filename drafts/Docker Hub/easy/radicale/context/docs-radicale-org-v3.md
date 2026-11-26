# Radicale 3 documentation (radicale.org/v3.html)

Source URL(s) + fetch date (2026-11-26):
- https://radicale.org/v3.html (first 100000 of 116223 characters read; the remaining tail, including Docker mention in the Download section, was not read)

## Server
- `[server] hosts`: comma-separated bind addresses. Default `localhost:5232`. For container reach, set `hosts = 0.0.0.0:5232, [::]:5232`.
- `type`: `builtin` default; `hypercorn` and `cheroot` optional (>= 3.9.0).
- `max_connections` default 8; `max_content_length` default 100000000; `timeout` default 30.
- SSL: `ssl` default False; `certificate` default `/etc/ssl/radicale.cert.pem`; `key` default `/etc/ssl/radicale.key.pem`.

## Storage
- `[storage] type`: `multifilesystem` default; alternative `multifilesystem_nolock` (single process only).
- `filesystem_folder`: default `/var/lib/radicale/collections`, auto-created if absent. (Conflicts with plan.md, which says the user must set it. See README.md.)
- `filesystem_cache_folder` (>= 3.3.2): defaults to filesystem_folder.
- Storage folder should not be readable by unauthorized users (systemd example uses `chmod -R o=`).

## Auth
- `[auth] type`: default `none` (< 3.5.0), `denyall` (>= 3.5.0). `htpasswd` type uses an Apache htpasswd file.
- `htpasswd_filename` default `/etc/radicale/users`.
- `htpasswd_encryption` default `md5` (< 3.3.0), `autodetect` (>= 3.3.0). Values: plain, bcrypt, md5, sha256, sha512, argon2, autodetect.
- `htpasswd_cache` default False; `delay` default 1; `realm` default `Radicale - Password Required`.

## Config file paths
- Tries `/etc/radicale/config` and `~/.config/radicale/config`. Multiple files separated by `:` (`;` on Windows); path starting with `?` is optional.
- `--config ""` disables default file loading.
- `[rights] file` defaults to `/etc/radicale/rights`.

## Env vars
- `RADICALE_CONFIG`: config file path(s). No other env vars in standalone mode. `HTTP_X_SCRIPT_NAME`/`SCRIPT_NAME` feed script_name (WSGI).

## CLI flags
- `--version`, `--verify-storage`, `--verify-item` (>= 3.6.0), `--verify-sharing` (>= 3.7.0), `-C|--config`, `-D|--debug`.
- Any option overridable as `--<section>-<option>` with `_` to `-`, e.g. `--storage-filesystem-folder=...`, `--auth-type none`, `--server-hosts 0.0.0.0:5232,[::]:5232`, `--auth-htpasswd-encryption autodetect`, `--logging-level=debug`.

## Container notes (from the page)
- Default bind is localhost; set `hosts` to `0.0.0.0:5232` and publish 5232.
- Mount a volume at `/var/lib/radicale/collections`; mount config and users files.
- Logging goes to stderr.
