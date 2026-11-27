# solidping README (main)

## Source URL(s) + date
- https://raw.githubusercontent.com/fclairamb/solidping/main/README.md (WebFetch summary)
- Fetched 2026-11-27

## What it is
- Self-hostable distributed uptime monitor, one Go binary; 45 check types; status pages; incidents; AGPL-3.0.

## Docker run
- Image `ghcr.io/fclairamb/solidping`
- `docker run -p 4000:4000 --name solidping --hostname solidping -v solidping-data:/data ghcr.io/fclairamb/solidping`
- Port 4000 (UI). Volume `/data` holds SQLite DB and uploads.
- `--hostname` required (worker name derived from it; must match `^[a-z][a-z0-9-]{2,20}$`), or set `SP_NODE_NAME`.

## Env vars
- Prefix `SP_`; all optional.
- `SP_DB_TYPE` (e.g. `postgres`), `SP_DB_URL`, `SP_NODE_NAME`, `SP_ADMIN_PASSWORD` (initial admin password; can also recover a lost password if not yet changed).

## Database
- Default SQLite in `/data`; migrations on first boot. Postgres for production.

## First run
- Admin login: `admin@solidping.io`.
- Without `SP_ADMIN_PASSWORD`, a password is printed once at first start. Retrieve: `docker logs solidping 2>&1 | grep "First login"`.
- New password required at first login.
