# docuseal/docuseal (Docker Hub)

Source URL(s) + fetch date:
- https://hub.docker.com/r/docuseal/docuseal
- Fetched 2026-11-26

## What it is
- Image description matches the repo: open source document signing; AGPLv3; 1M+ pulls.

## Architectures
- Not shown on the page.

## Tags
- Only `latest` shown (digest begins `sha256:b664cc840...`, size 236.8 MB, updated 3 days before fetch).

## Documented run command
```
docker run --name docuseal -p 3000:3000 -v.:/data docuseal/docuseal
```
- Port 3000 maps 3000. Volume: current dir at /data.
- Env: none in the run example. Default SQLite; set `DATABASE_URL` for PostgreSQL or MySQL.

## Compose option
- `curl https://raw.githubusercontent.com/docusealco/docuseal/master/docker-compose.yml > docker-compose.yml`, then `sudo HOST=your-domain-name.com docker compose up` (Caddy issues SSL when DNS points at the server).

## Gotchas
- Pro features are separate from the open-source feature set.
