# NginxProxyManager setup and guide

**Sources:** https://nginxproxymanager.com/setup (fetched 2026-11-26); https://nginxproxymanager.com/guide/ (fetched 2026-11-26)

## Image / tags
- `jc21/nginx-proxy-manager:2.17.1` (Docker Hub; amd64, arm64). armv7 dropped in 2.14+; use `2.13.7` for armv7.

## Compose (default SQLite)
```yml
services:
  app:
    image: 'jc21/nginx-proxy-manager:2.17.1'
    restart: unless-stopped
    ports:
      - '80:80'
      - '443:443'
      - '81:81'
      # - '21:21'  optional stream port
    environment:
      TZ: "Australia/Brisbane"
      # DB_SQLITE_FILE: "/data/database.sqlite"
      # DISABLE_IPV6: 'true'
    volumes:
      - ./data:/data
      - ./letsencrypt:/etc/letsencrypt
```
- Start: `docker compose up -d`. First start can take a minute.

## Env vars
| Name | Default | Purpose |
|---|---|---|
| TZ | none (example Australia/Brisbane) | timezone |
| DB_SQLITE_FILE | /data/database.sqlite (implied) | SQLite file location |
| DISABLE_IPV6 | unset | `'true'` when host lacks IPv6 |
| DB_MYSQL_HOST / _PORT (3306) / _USER / _PASSWORD / _NAME | none | MySQL/MariaDB; takes precedence over SQLite |
| DB_MYSQL_SSL | false | enable TLS |
| DB_MYSQL_SSL_REJECT_UNAUTHORIZED | true | false permits self-signed |
| DB_MYSQL_SSL_VERIFY_IDENTITY | true | hostname verification |
| DB_POSTGRES_HOST / _PORT (5432) / _USER / _PASSWORD / _NAME | none | Postgres (public schema only) |

- No env vars strictly required for SQLite.
- MariaDB example: linuxserver/mariadb (`./mariadb:/config`); Postgres example: postgres:17 (`./postgres_data:/var/lib/postgresql/data`).

## Ports / paths
| Port | Purpose |
|---|---|
| 80 | HTTP |
| 81 | admin UI |
| 443 | HTTPS |

| Host | Container |
|---|---|
| ./data | /data (JWT keys, SQLite DB) |
| ./letsencrypt | /etc/letsencrypt |

## First run
- Generates JWT keys in data folder; initializes DB schema; creates a default admin user.
- Default login: NOT stated in fetched sources (setup/guide pages).

## Other
- Healthcheck: none mentioned.
- Home hosting: forward 80/443 on router; DNS via dynamic DNS or provider.
- Docker and Docker Compose required.
