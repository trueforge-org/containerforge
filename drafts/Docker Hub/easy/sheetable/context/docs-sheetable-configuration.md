# SheetAble docs (sheetable.net)

Source URL(s) + fetch date (all 2026-11-26):
- https://sheetable.net/docs (intro; no install details)
- https://sheetable.net/docs/configuration
- https://sheetable.net/docs/Installation/installation (overview; Docker vs native)
- https://sheetable.net/docs/Installation/installation-docker

## What it is
User documentation for SheetAble 0.8.1. Describes Docker and native install.

## Install/build steps
Docker (installation-docker): `docker run -p 8080:8080 vallezw/sheetable` (no separate pull). Compose example: image `vallezw/sheetable`, ports `8080:8080`, `environment: CONFIG_PATH=/app/config/`, volumes `/etc/localtime:/etc/localtime:ro` and `/local/path/config/dir:/app/config`. Docs recommend Docker over native. Native binary installs do not auto-update (per the overview page).

## Env vars (table, configuration page)
| Variable | Documented default | Meaning |
| --- | --- | --- |
| `API_SECRET` | none stated | any string; used to encrypt the JWT key |
| `DB_DRIVER` | none stated | mysql, postgres or sqlite |
| `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, `DB_PORT` | none stated | for mysql/postgres |
| `ADMIN_EMAIL`, `ADMIN_PASSWORD` | none stated on this page | admin account |
| `PORT` | 8080 | can be mapped, e.g. `8181:8080` |
| `DEV` | none stated | 0 or 1; dev mode |
| `CONFIG_PATH` | none stated ("root dir implied") | data location |

Set via `-e NAME=value` (Docker), or a `.env` file in the working directory (recommended), or exported variables. A `.env.sample` is linked.

## Ports
8080 (installation-docker).

## Volumes/paths and persistent data
`/app/config` (installation-docker and compose example); `CONFIG_PATH=/app/config/` in the compose example.

## Default login
installation-docker: `admin@admin.com` / `sheetable`, changeable through the Configuration guide. The configuration page itself does not state a default login.

## Database setup
Not described on the pages fetched (installation-docker says nothing about it).

## Gotchas
- The intro page only describes the product; the Docker install details are on installation-docker.
- The configuration page does not mention the default login; the default comes from installation-docker and from `config.go`.
- Docs port 8080 disagrees with the Dockerfile `EXPOSE 8000`.

## Contradictions with plan.md
- None on the default login (plan.md's "(docs)" attribution is correct for installation-docker).
- plan.md's "Docs example: CONFIG_PATH=/app/config/, volume /app/config" is correct (installation-docker).
- plan.md's "Docs port default 8080" is correct for the configuration page.
