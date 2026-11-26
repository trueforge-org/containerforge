# ronivay/xen-orchestra-docker: xo-server.toml.j2 and monit-services

## Source URL(s) + date
- https://raw.githubusercontent.com/ronivay/xen-orchestra-docker/0be1b1f87e7895d3cc0091c4088fbfc97317687e/conf/xo-server.toml.j2 (fetched 2026-11-26)
- https://raw.githubusercontent.com/ronivay/xen-orchestra-docker/0be1b1f87e7895d3cc0091c4088fbfc97317687e/conf/monit-services (fetched 2026-11-26)

## xo-server config template (jinja2, rendered by run.sh)
- Search order documented in file: `$HOME/.config/xo-server/config.toml`, then `/etc/xo-server/config.toml`.
- `[http]`: if `env['REDIRECT_TO_HTTPS'] == 'true'` and `env['HTTPS_PORT']` set -> `redirectToHttps = true`.
- `[[http.listen]]`: `port = {{ env['HTTP_PORT'] }}` (no hostname = all addresses).
- Second `[[http.listen]]` only if `HTTPS_PORT` set: `port = {{ HTTPS_PORT }}`, `autoCert = true`, `cert = {{ CERT_PATH }}`, `key = {{ KEY_PATH }}`.
- `[http.mounts]`, `[http.proxies]` commented examples.
- `[redis]`: Unix socket or uri (rest of file not needed for build; default redis uri `redis://127.0.0.1:6379/0` per plan note, not re-verified here).
- Template has `user`/`group` commented (default undefined); `datadir` commented, default `/var/lib/xo-server/data`.

## monit-services (`/etc/monit/conf.d/services`)
- monit httpd: port 2812, `use address localhost`, `allow localhost`.
- `check process xo-server` (pidfile `/var/run/xo-server.pid`), `depends on redis`:
  - start: `/usr/bin/env NODE_EXTRA_CA_CERTS=/host-ca.pem /usr/local/bin/forever start -a --pidFile /var/run/xo-server.pid --sourceDir /etc/xen-orchestra/packages/xo-server -l /var/log/xo-server.log dist/cli.mjs`
  - stop: `/usr/local/bin/forever stop /etc/xen-orchestra/packages/xo-server/dist/cli.mjs`
- `check process redis` (pidfile `/var/run/redis.pid`):
  - start: `/usr/bin/redis-server /etc/redis/redis.conf --bind 127.0.0.1 --pidfile /var/run/redis.pid`
  - stop: `/usr/bin/redis-cli shutdown`
- `check process rpcbind` (matching "rpcbind"): start `/sbin/rpcbind`.

## Gotchas
- `NODE_EXTRA_CA_CERTS=/host-ca.pem`: README says mount custom CA at `/host-ca.pem` to trust it.
- xo-server entry is `dist/cli.mjs` run by forever from `/etc/xen-orchestra/packages/xo-server`.
- rpcbind is started and checked (needed for NFS).
