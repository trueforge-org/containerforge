# Docker Hub: baserow/baserow

**Source URL(s) + fetch date:** https://hub.docker.com/r/baserow/baserow · fetched 2026-11-26

## What it is
All-in-one Baserow image (no-code database, "Airtable alternative"): bundles Postgres, Redis and Caddy with the app. 1M+ pulls, 55 stars, maintained by baserow.io.

## Tags
- `X.Y.Z` per release (examples use 2.4.3).
- `latest`: digest `sha256:304bebe22…`, 595.1 MB, updated 12 days before fetch (page relative date).
- `develop-latest`: development build, "use at your own risk".

## Run example (2.4.3)
```
docker run -d --name baserow \
  -e BASEROW_PUBLIC_URL=http://localhost \
  -v baserow_data:/baserow/data \
  -p 80:80 -p 443:443 \
  --restart unless-stopped \
  baserow/baserow:2.4.3
```
- Ports 80 and 443. Volume `baserow_data` -> `/baserow/data`.
- `BASEROW_PUBLIC_URL` must match the browser address. Optional: `BASEROW_CADDY_ADDRESSES=:443` (automatic HTTPS), `DATABASE_URL` (external Postgres), `REDIS_URL` (external Redis).

## Upgrade note
Embedded Postgres data created before version 1.24 must be upgraded with `baserow/baserow-pgautoupgrade:1.30.1` before running a newer image. Baserow upgrades itself on startup.

## Architectures
Not listed.

## Licence
Open-core; non-premium/non-enterprise code under MIT.

## Gotchas
- Repository page says "updated 19 minutes ago"; `latest` tag 12 days ago (both relative, as shown).
