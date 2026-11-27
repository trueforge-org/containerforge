# 2FAuth docker/nginx.conf (tag v9.0.3)

Source URL(s): https://raw.githubusercontent.com/Bubka/2FAuth/v9.0.3/docker/nginx.conf (fetched 2026-11-27)

- Single server, `listen 8000` (IPv4 and IPv6), `root /srv/public`, `index index.php`.
- Temp paths: `client_body_temp_path /tmp`, `fastcgi_temp_path /tmp/fastcgi_temp`.
- `client_max_body_size 10m`. Logs to stdout/stderr.
- PHP via `fastcgi_pass 127.0.0.1:9000` (php-fpm must listen on 9000).
- `/storage/` served with CSP `default-src 'none'; style-src 'unsafe-inline'; sandbox` and nosniff.
- Dotfiles denied except `.well-known`.
- 404 goes to `/index.php`.
