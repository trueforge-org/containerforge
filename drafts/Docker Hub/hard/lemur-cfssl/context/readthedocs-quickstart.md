# Lemur Quickstart (follow-up)

Source URL(s): https://lemur.readthedocs.io/en/latest/quickstart/index.html. Fetched 2026-11-26.

## Runtime
- Python >= 3.10; PostgreSQL >= 13 (only if DB on web host); Nginx; Node v20.x LTS (npm for source installs only).
- Target UNIX; tested Ubuntu 22.04.

## System packages (apt)
- nodejs npm python3-pip python3-dev libpq-dev build-essential libssl-dev libffi-dev libsasl2-dev libldap2-dev nginx git supervisor postgresql
- Symlink `/usr/bin/nodejs` -> `/usr/bin/node` if needed.

## Source install (page)
- Install dir `/www`; virtualenv `/www/lemur`; `git clone https://github.com/Netflix/lemur`
- `make up-reqs`, then `make release` (npm deps + static assets). Optional `urlContextPath=`.
- Docker: alternative via Netflix/lemur-docker.

## Config
- Command `lemur create_config`; default output `~/.lemur/lemur.conf.py`; `-c/--config` or env `LEMUR_CONF`.
- Required: LEMUR_SECURITY_TEAM_EMAIL (quoted), LEMUR_DEFAULT_COUNTRY, LEMUR_DEFAULT_STATE, LEMUR_DEFAULT_LOCATION, LEMUR_DEFAULT_ORGANIZATION, LEMUR_DEFAULT_ORGANIZATIONAL_UNIT.
- SQLALCHEMY_DATABASE_URI: `postgresql://user:pass@host:port/db`.

## Postgres
- Role `lemur` and db `lemur`; pg_trgm extension required (temporary SUPERUSER needed for init).

## Init / run
- `lemur db init`; `lemur init` (creates default `lemur` user; prints password for first login).
- Start: `lemur start`; default port 8000; gunicorn + eventlet. Example `lemur --config=/etc/lemur.conf.py start -b 127.0.0.1:8000`.
- Nginx reverse proxy: `location /api` -> 127.0.0.1:8000; `location /` static from `/www/lemur/lemur/static/dist`.
- Supervisor program `lemur-web`, command `/www/lemur/bin/lemur start`.
- Cron: `*/15 * * * * lemur sync -s all`, `0 22 * * * lemur check_revoked`, `0 22 * * * lemur notify`.
- Utilities: `lemur lock` / `lemur unlock` (key material).
