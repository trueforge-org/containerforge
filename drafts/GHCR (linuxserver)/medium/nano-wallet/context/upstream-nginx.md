# linuxserver/docker-nano-wallet root/nginx.conf

Source URL (fetched 2026-11-27, GitHub contents API, base64 decoded):
- https://api.github.com/repos/linuxserver/docker-nano-wallet/contents/root/nginx.conf

## Global
- `user abc;`, `worker_processes 4;`, `pid /run/nginx.pid;`
- `include /etc/nginx/modules/*.conf;`
- `daemon off;` (foreground)

## events
- `worker_connections 768;`

## http
- sendfile, tcp_nopush, tcp_nodelay on. keepalive_timeout 65.
- types_hash_max_size 2048. `client_max_body_size 0;` (unlimited upload).
- `include /etc/nginx/mime.types;` default type application/octet-stream.
- gzip on, disabled for msie6.
- Includes `/default` (server block lives there, not fetched).

## Not in this file
- No `listen`, `server_name`, `root`, `try_files`, `location`, or proxy config. Expected in the `/default` include in `root/`, which was not fetched.

## Gotchas
- Runs as user `abc` (LSIO convention). Container must be able to read `/web` (from Dockerfile COPY).
