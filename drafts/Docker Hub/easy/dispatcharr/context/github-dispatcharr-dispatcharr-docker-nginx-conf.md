# Dispatcharr/Dispatcharr docker/nginx.conf (tag v0.34.1)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/Dispatcharr/Dispatcharr/v0.34.1/docker/nginx.conf · 2026-11-26

## Facts
- Listen: `listen NGINX_PORT;` and `listen [::]:NGINX_PORT;` (placeholder, must be substituted; plan.md sed matches).
- Locations: `/assets/` root `/app/static`; `/static/` root `/app`; `/logos/` root `/data`; `/protected-backups/` internal alias `/data/backups/`.
- `uwsgi_pass unix:/app/uwsgi.sock;` in `location /`, `/hdhr` and `/proxy/` (plan.md rewrites to `/tmp/uwsgi.sock`).
- `proxy_cache_path /data/cache/logos ... keys_zone=logo_cache:10m inactive=24h use_temp_path=off;` and `proxy_cache_path /data/cache/sd_posters ... keys_zone=sd_poster_cache:10m inactive=14d ...`.
- http-level (outside server): `error_log /dev/stderr;`, the two `proxy_cache_path` lines, and a `map $args $sd_poster_cache_key` block.
- Server-level: `uwsgi_buffer_size 16k`, `uwsgi_busy_buffers_size 16k`, `proxy_connect_timeout 75`, `proxy_send_timeout 300`, `proxy_read_timeout 300`, `client_max_body_size 0`.

## Notes vs plan.md
- The file mixes http-level and server-level directives. Plan's approach (fragment included inside `http`) fits this file.
- plan.md claim that nginx proxies the logo cache to `127.0.0.1:5656` is not shown in this file (it uses unix socket `/app/uwsgi.sock` for `/`, `/hdhr`, `/proxy/`). Logo cache here is `/data/cache/logos` via `/logos/` root `/data`.
