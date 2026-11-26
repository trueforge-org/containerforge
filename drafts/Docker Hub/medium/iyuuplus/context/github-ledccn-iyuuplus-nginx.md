# ledccn/iyuuplus-dev: docker/rootfs/etc/nginx/nginx.conf (HEAD)
Source URL: https://raw.githubusercontent.com/ledccn/iyuuplus-dev/HEAD/docker/rootfs/etc/nginx/nginx.conf (fetched 2026-11-26)
- Server listen 8780 default_server (IPv4 and IPv6)
- root /var/lib/nginx/html
- location proxies to http://127.0.0.1:8787 (PHP/webman app)
- another location proxies to http://127.0.0.1:3131
- JSON access log format
- Includes conf snippets (proxy.conf)
