# Docker Hub: getferdi/ferdi-server

Source URL(s) + fetch date:
- https://hub.docker.com/r/getferdi/ferdi-server (fetched 2026-11-26)

## What it is

Dockerized build of Ferdi-server: an unofficial stand-in for the Franz server, for the Ferdi client. Based on Alpine Linux with Node.js v10.16.3 (per the Hub page). Old and unmaintained: the page says "Updated over 4 years ago". About 1M+ pulls, 78.8 MB image. MIT (per page).

## Tags and arch

- Only tag shown: `latest`. No architectures listed on the page.
- The draft/chart pins `1.3.2@sha256:6e620b85...` (TrueCharts values.yaml). That tag is not listed on the page.

## Ports

- Container listens on 3333: `-p <port>:3333`. Older users mapped `80:3333`.

## Volumes

- `/data` (database and other data), `/app/recipes` (recipes).
- Migrating from built-in SQLite: `DATA_DIR=/app/database`, DB name `development`, mount `/app/database`.

## Env vars

- Database: `DB_CONNECTION` (sqlite default; `mysql` or `pg` alternatives), `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_DATABASE`, `DB_SSL`, `DATA_DIR`.
- Mail: `MAIL_CONNECTION`, `SMPT_HOST` (sic on page), `SMTP_PORT`, `MAIL_SSL`, `MAIL_USERNAME`, `MAIL_PASSWORD`, `MAIL_SENDER`. SparkPost and Mailgun have own variables.
- Feature toggles: `IS_CREATION_ENABLED`, `IS_DASHBOARD_ENABLED`, `IS_REGISTRATION_ENABLED`, `CONNECT_WITH_FRANZ`.
- Other: `NODE_ENV` (default development, page says do not change), `EXTERNAL_DOMAIN`.

## Config files

- `/config/config.txt` is a deprecated fallback; pass env vars instead.

## Usage notes

- NGINX reverse proxy recommended for access from outside the home network.
- `/import` imports a Franz/Ferdi account; `/new` adds a custom recipe.
- Debug: `docker exec -it ferdi-server /bin/bash`, `docker logs -f ferdi-server`.

## Gotchas

- This is the OLD 1.x-era image. The 2.x successor (`ferdium/ferdium-server`) has different paths (`/data` default in the Dockerfile, `/app/recipes` for recipes), and the draft's `1.3.2` tag is obsolete.
