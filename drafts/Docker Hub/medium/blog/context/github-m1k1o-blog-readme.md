# m1k1o/blog README

Source: https://raw.githubusercontent.com/m1k1o/blog/master/README.md (fetched 2026-11-26)

## What it is
- Single-user, self-hosted PHP "facebook-style" blog; no npm/build pipeline
- Formatting BBCode (default) or Markdown; themes light/dark/legacy; access private/friends/public

## Install/run
- Quick start (SQLite): `docker run -d -p 80:80 -v $PWD/data:/var/www/html/data m1k1o/blog:latest`
- Compose examples: MariaDB 10.1 or Postgres 14 variants (docker-compose.yml in repo)
- Perms: Apache runs as www-data, `chown 33:33 ./data/` (chmod 777 discouraged)
- Manual: Apache 2.0 + PHP 8.0+ + MariaDB 10.1 or SQLite 3; schemas in ./app/db
- Nginx/other: deny public access to `*.ini` and `data/logs/*.log`

## Runtime deps (per README)
- Optional PHP exts: imagick with HEIC (HEIC conversion), zip (export); both in Docker image

## Config
- Don't edit root ./config.ini; copy to ./data/config.ini
- Env: `BLOG_<KEY>` uppercase config keys: BLOG_TITLE, BLOG_NAME, BLOG_NICK, BLOG_PASS, BLOG_LANG, BLOG_FORMATTING, BLOG_DATETIME_FORMAT, BLOG_FRIENDS
- DB: BLOG_DB_CONNECTION (mysql|postgres), BLOG_DB_NAME, BLOG_MYSQL_{HOST,PORT,USER,PASS}, BLOG_POSTGRES_{HOST,PORT,USER,PASS}
- TZ sets timezone
- Compose-only: HTTP_PORT (80), DATA (./data)
- Upload limit 256 MB adjustable in .htaccess (upload_max_filesize, post_max_size)
- Language: config or `?hl=xx` (en, de, sk, fr, cz, bs, es, ru)
- Debug: `debug = true`; CLI flags: none

## Ports
- 80

## Volumes/paths
- /var/www/html/data (config, uploads, logs, sqlite db)
- Compose: mariadb:/var/lib/mysql, postgres:/var/lib/postgresql/data

## Gotchas
- MySQL tables from old versions need utf8mb4 for emoji
- License: not stated in README
