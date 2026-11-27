# Upstream entrypoint: RSS-Bridge/rss-bridge (docker-entrypoint.sh)

Source URL: https://raw.githubusercontent.com/RSS-Bridge/rss-bridge/98e03011dbb80ea9cea3ef8c5e29a1778f169cc9/docker-entrypoint.sh (fetched 2026-11-27)

## Flow
1. `find /config/ -type f` (recursive). Skips names containing a space. Copies:
   - `*Bridge.php` → `/app/bridges/` (chown www-data)
   - `*Format.php` → `/app/formats/` (chown www-data)
   - `config.ini.php` → `/app/`
   - `whitelist.txt` → `/app/`
   - `DEBUG` → `/app/` (debug toggle file)
2. If `HTTP_PORT` set: `sed -i "s/80/$HTTP_PORT/g" /etc/nginx/sites-enabled/default`.
3. `nginx` (daemonises).
4. `exec php-fpm8.2 --nodaemonize`.

## Env vars
| Name | Use |
| --- | --- |
| HTTP_PORT | nginx listen port (replaces the substring "80" in the nginx site file) |

## Gotchas
- The sed replaces every "80" in the nginx site file, not only the listen directive.
- Writes into /app (bridges, formats, config.ini.php, whitelist.txt, DEBUG): needs writable /app.
- Only `*Bridge.php` and `*Format.php` files are picked up; `config.ini.php` and `whitelist.txt` are copied directly.
