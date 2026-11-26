# Docker Hub: adminer (Docker Official Image)

**Source URL(s):** https://hub.docker.com/_/adminer
**Fetched:** 2026-11-26

## What it is
- Docker Official Image for Adminer (full-featured DB tool in PHP, single deployable file). Maintained by Tim Düsterhus (TimWolla). Over 100M pulls; image size about 51.8 MB.

## Supported tags
- 6.3.1 line: `6.3.1`, `6`, `latest`, `6.3.1-standalone`, `6-standalone`, `standalone`
- 6 FastCGI: `6.3.1-fastcgi`, `6-fastcgi`, `fastcgi`
- 5.5.1 line: `5.5.1`, `5`, `5.5.1-standalone`, `5-standalone`
- 5 FastCGI: `5.5.1-fastcgi`, `5-fastcgi`

## Architectures
amd64, arm32v6, arm32v7, arm64v8, i386, ppc64le, riscv64, s390x.

## Ports
- Standalone: **8080** (HTTP).
- FastCGI variant: **9000**. Page warns this exposes the FastCGI socket; use firewall rules or a private network.

## Env vars
| Variable | Purpose |
| --- | --- |
| `ADMINER_DEFAULT_SERVER` | Default DB host (external server or container not named `db`) |
| `ADMINER_DESIGN` | Bundled design, e.g. `nette` |
| `ADMINER_PLUGINS` | Space-separated plugin filenames, e.g. `tables-filter tinymce` |

## Volumes and paths
- No volumes declared.
- `/var/www/html/plugins-enabled/`: custom plugin PHP scripts (e.g. `login-servers.php`).
- `/var/www/html/adminer.css`: custom design.

## User
Not stated on the page (the Dockerfile sets user `adminer`; see github-timwolla-docker-adminer.md).

## How to run
- Standalone: `docker run --link some_database:db -p 8080:8080 adminer`, open http://localhost:8080.
- FastCGI: `docker run --link some_database:db -p 9000:9000 adminer:fastcgi`.
- External server: `docker run -p 8080:8080 -e ADMINER_DEFAULT_SERVER=mysql adminer`.
- Plugins: `-e ADMINER_PLUGINS='tables-filter tinymce'`. Design: `-e ADMINER_DESIGN='nette'`.
- Compose example: `adminer` service (`restart: always`, `8080:8080`) plus `mysql:5.6` `db` service. The page calls it local-testing only and suggests binding `127.0.0.1:8080:8080` and changing the weak root password.

## Drivers
- Included: MySQL, PostgreSQL, SQLite, SimpleDB, Elasticsearch.
- Need extra PHP extensions: `pdo_dblib` (MS SQL), `oci8` (Oracle), `interbase` (Firebird), `mongodb` (MongoDB).
- All official plugins and designs are bundled in the image.

## Dockerfile and source links
- 6.x standalone Dockerfile: https://github.com/TimWolla/docker-adminer/blob/c7030156876cd2e939b6ae3e9cca95faea0d28eb/6/Dockerfile (current image; differs from the plan's pinned 6d83dde commit, which is also summarised in github-timwolla-docker-adminer.md)
- 6.x FastCGI Dockerfile, 5.x Dockerfiles: listed on the page, not fetched.
- Plugins: https://github.com/vrana/adminer/tree/master/plugins ; Designs: https://github.com/vrana/adminer/tree/master/designs

## Gotchas
- The image's standalone variant serves on 8080 and runs under a non-root `adminer` user (per Dockerfile).
- The 6.3.1 tag is what `latest` points to on this page.
