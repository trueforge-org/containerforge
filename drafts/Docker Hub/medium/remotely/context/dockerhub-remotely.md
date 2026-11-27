# Docker Hub: immybot/remotely

Source URL(s):
- https://hub.docker.com/v2/repositories/immybot/remotely/
- https://hub.docker.com/v2/repositories/immybot/remotely/tags?page_size=10
Fetched: 2026-11-27

## Repository
| Key | Value |
| --- | --- |
| description | A Remotely server with clients pre-compiled. |
| pull_count | 636643 |
| star_count | 38 |
| last_updated | 2024-08-12 |
| tag count | 31 |

## Tags (page_size=10)
| Tag | Arch | Last pushed |
| --- | --- | --- |
| latest | amd64 | 2024-08-12 |
| preview | amd64 | 2024-08-12 |
| 1037 | amd64 | 2024-08-12 |
| 589 | amd64 | 2024-07-16 |
| 352 | amd64 | 2024-06-28 |
| 117 | amd64 | 2024-06-05 |
| 116 | amd64 | 2024-06-05 |
| 88 | amd64 | 2024-02-26 |
| 87 | amd64 | 2024-02-22 |
| experimental | amd64 | 2024-02-22 |

- Only amd64 seen. Tags are build numbers plus latest/preview/experimental.
- Chart pins the `latest` digest 9bdff2d8... (digest of the latest tag not separately confirmed on this page).

## Run (full_description, quickstart compose)
- Volume: `/var/www/remotely:/app/AppData`; port `5000:5000`.
- Env: `ASPNETCORE_ENVIRONMENT=Production`, `ASPNETCORE_HTTP_PORTS=5000`.
- DB: `Remotely_ApplicationOptions__DbProvider` = SQLite | SQLServer | PostgreSQL.
- SQLite path: `Remotely_ConnectionStrings__SQLite=Data Source=/app/AppData/Remotely.db` (must stay under the volume).
- Other connection strings: `Remotely_ConnectionStrings__SQLServer`, `Remotely_ConnectionStrings__PostgreSQL`.

## Gotchas
- Compose example maps 5000 with ASPNETCORE_HTTP_PORTS=5000; chart uses container 8080 (see truecharts file).
- Docker Hub description is for the image; upstream repo last pushed 2024-12-17 (see github-remotely-dockerfile.md).
