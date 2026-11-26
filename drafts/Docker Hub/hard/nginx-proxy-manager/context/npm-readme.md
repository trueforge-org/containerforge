# NginxProxyManager README

**Source:** https://raw.githubusercontent.com/NginxProxyManager/nginx-proxy-manager/master/README.md (fetched 2026-11-26)

## What it is
- Pre-built Docker image forwarding traffic to sites, with SSL included. Admin UI on Tabler.
- Proxy hosts, redirections, streams, 404 hosts; Let's Encrypt or custom certs; access lists; advanced Nginx config; users, permissions, audit log.
- License MIT (per Dockerfile label; not confirmed on README).

## Ports
| Port | Purpose |
|---|---|
| 80 | HTTP |
| 81 | Admin UI (http://127.0.0.1:81) |
| 443 | HTTPS |

## Compose example (SQLite default)
- image `jc21/nginx-proxy-manager:latest` on page (pin 2.17.1 per docs), restart unless-stopped
- volumes `./data:/data`, `./letsencrypt:/etc/letsencrypt`
- Start: `docker compose up -d`

## Not on page
- Default admin credentials, healthcheck, env var list (not in README; see `npm-setup-guide.md`).
