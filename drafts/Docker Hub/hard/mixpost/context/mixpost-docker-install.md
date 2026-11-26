# Mixpost Lite Docker install

**Source:** https://docs.mixpost.app/lite/installation/docker (fetched 2026-11-26)

## Images / services
| Service | Image |
|---|---|
| mixpost | `inovector/mixpost:latest` |
| mysql | `mysql/mysql-server:8.0` |
| redis | `redis:latest` (`redis-server --appendonly yes --replica-read-only no`) |
| traefik | optional (SSL and Traefik-without-SSL variants) |

- mixpost depends on mysql and redis.

## Commands
- `docker compose up -d`; logs `docker compose logs -f`; stop `docker compose stop`
- Ubuntu Docker install: docker-ce, docker-ce-cli, containerd.io, docker-buildx-plugin, docker-compose-plugin
- No artisan/setup commands on page.

## Compose variants
- SSL: Traefik + Let's Encrypt TLS challenge (resolver `mytlschallenge`); acme in `traefik_data` at `/letsencrypt/acme.json`; HTTP -> HTTPS; `--api.insecure=true`.
- No SSL: mixpost exposed `9000:80`.
- Traefik without SSL: TLS on `websecure`, no ACME (recommended for Cloudflare).

## Ports
- No SSL: host 9000 -> container 80.
- Traefik: 80 and 443 published by Traefik.

## Volumes
| Volume | Mount |
|---|---|
| storage | /var/www/html/storage/app |
| logs | /var/www/html/storage/logs |
| mysql | /var/lib/mysql |
| redis | /data |
| traefik_data | /letsencrypt (SSL only) |

- All volumes: `local` driver.

## Env (.env via env_file)
- APP_NAME, APP_KEY (generated via tool on mixpost.app), APP_DEBUG (false), APP_DOMAIN (no protocol), APP_URL (`https://${APP_DOMAIN}`), DB_DATABASE, DB_USERNAME, DB_PASSWORD, SSL_EMAIL
- MySQL container receives MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD from DB_* values.

## Healthchecks
- mysql: `mysqladmin ping` (3 retries, 5s timeout)
- redis: `redis-cli ping` (3 retries, 5s timeout)
- mixpost: none defined.

## Restart / defaults
- restart: unless-stopped (all services).
- Default login admin@example.com / changeme (change after login).

## DNS / Cloudflare
- A record to server IP; Cloudflare proxied, SSL/TLS mode Full, Always Use HTTPS.
