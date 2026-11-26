# metabase/metabase (upstream source)

**Source URL(s):** https://github.com/metabase/metabase (repo page); https://raw.githubusercontent.com/metabase/metabase/v0.65.6/LICENSE.txt; https://raw.githubusercontent.com/metabase/metabase/v0.65.6/LICENSE-AGPL.txt; https://github.com/metabase/metabase/releases/tag/v0.65.6
**Fetched:** 2026-11-26

## What it is
- Open-source business intelligence and embedded analytics platform (Clojure/JVM). Connects to many databases (PostgreSQL, MySQL, Snowflake, BigQuery, Redshift, MongoDB and others).
- Default branch: `master`. About 50.6k stars.

## Install/build steps and build deps
- No build for the container: upstream publishes `metabase.jar` (see release and download notes). Upstream Dockerfile copies the jar in (dockerfile summary).
- Self-hosting options per metabase.com: run the JAR, Docker, or Metabase Cloud.
- JAR run command (metabase.com start page): `java --add-opens java.base/java.nio=ALL-UNNAMED -jar metabase.jar`.

## Runtime deps
- Java: the Dockerfile base is Temurin 25 JRE (`eclipse-temurin:25-jre-alpine`). Java version is not stated in the repo page or docs. Java 25 is the upstream runtime.
- Application database: embedded H2 by default; PostgreSQL, MySQL and others for production. Docs say H2 is not suitable for production.
- Fonts and CA tooling: installed in the upstream Alpine image (see dockerfile summary).

## Binaries/entrypoint/CLI flags
- Upstream entrypoint: `/app/run_metabase.sh` (see github-metabase-dockerfile.md). The launcher runs `java $JAVA_OPTS -jar /app/metabase.jar $@`.
- Jar naming: upstream image uses `/app/metabase.jar`. The plan.md layout (`/app/metabase/metabase.jar`) does not match.
- Subcommand `load-from-h2` exists (the run script uses it for `/app/initial*.db` seeding).
- Release assets: none on the GitHub release (plan.md). Downloads: `https://downloads.metabase.com/v<VER>/metabase.jar` (open source) and `https://downloads.metabase.com/enterprise/v1.<VER>/metabase.jar` (enterprise, not used). Release notes mention `v0.65.6.x` paths.

## Env vars
Documented (Docker docs, see docs-metabase-running-on-docker.md):
- `MB_DB_TYPE` (e.g. `postgres`), `MB_DB_DBNAME`, `MB_DB_PORT`, `MB_DB_USER`, `MB_DB_PASS`, `MB_DB_HOST`, `MB_DB_CONNECTION_URI`.
- `MB_DB_FILE`: H2 database file path (default `/metabase.db`).
- `JAVA_TIMEZONE` (e.g. `US/Pacific`).
- `MUID`, `MGID`: user and group IDs (default 2000 in the script).
- `MB_PREMIUM_EMBEDDING_TOKEN`: enterprise license token, not used here.
- `_FILE` secret variants for `MB_DB_USER`, `MB_DB_PASS`, `MB_DB_CONNECTION_URI`, `MB_EMAIL_SMTP_PASSWORD`, `MB_EMAIL_SMTP_USERNAME`, `MB_LDAP_PASSWORD`, `MB_LDAP_BIND_DN`.
- `MB_JETTY_HOST` (script default `0.0.0.0`), `JAVA_OPTS` (script appends to it; not in docs).

## Ports
3000 (`EXPOSE 3000`; docs `-p 3000:3000`). Jetty port override `MB_JETTY_PORT` is referenced by the TrueCharts chart but not documented on the Docker page.

## Volumes/paths and persistent data
- `/metabase.db`: default H2 directory (file `metabase.db.mv.db`). Override with `MB_DB_FILE`, e.g. `/metabase-data/metabase.db`.
- `/plugins`: external JARs (drivers). Docs bind a host path here (`--mount ... destination=/plugins`). The upstream image creates `/plugins` with mode `a+rwx` (see dockerfile summary).
- Not `/config`. The plan's `/app/metabase/plugins` symlink target is not the documented path.

## User/UID and permissions
- Upstream run script: if started as root, creates a system group and user `metabase` (`addgroup --system`, `adduser --disabled-password`), chowns the DB directory, and drops to `metabase` via `su`. Non-root starts launch Java directly.
- `MUID`/`MGID` control the IDs (default 2000 in the script).

## Config files and formats
None. All configuration is environment variables and the DB file.

## Healthcheck/readiness endpoints
- `GET /api/health` (TrueCharts docs compose example: `curl --fail -I http://localhost:3000/api/health`, interval 15s, timeout 5s, retries 5).
- Startup log line: "Metabase Initialization Complete" (metabase.com start page). Note: plan.md marked this as UNVERIFIED; the metabase.com page confirms this exact text.

## Version/release info
- Latest GitHub release: `v0.65.6`, titled "Metabase 65.6", published 18 Nov (commit 518e559, marked Latest).
- Release notes: back up the application DB before upgrading. Open-source Docker `metabase/metabase:v0.65.6.x`, JAR at `downloads.metabase.com/v0.65.6.x/metabase.jar`. Enterprise: `metabase/metabase-enterprise:v1.65.6.x`.
- Release notes say "Assets 2" but the file names did not load.
- Docker Hub tag listing shows `v0.65.x`, `v0.65.7.x`, `v0.65.7.2`, plus LTS `v0.64-lts`, `v0.58-lts`. Exact `v0.65.6` tag not shown on the page (four-part `v0.65.6.x` form is used).

## Arch support
Upstream Docker Hub page does not list architectures. The jar is architecture-neutral Java.

## Gotchas
- LICENSE.txt is a licensing notice (AGPL plus commercial split), not the full text. LICENSE-AGPL.txt is the full AGPL-3.0 text (version 3, 19 November 2007) plus an additional permission under GPLv3 section 7 for a list of Clojure libraries (a linking exception). SPDX `AGPL-3.0` with an exception; plan.md's `AGPL-3.0` was UNVERIFIED and is now partly supported.
- Enterprise code under `enterprise/` is under the Metabase Commercial License. Do not package enterprise binaries.
- Docker Hub tags use `v0.65.x` four-part forms; Renovate behaviour with `v`-prefixed four-part tags is UNVERIFIED (plan.md).
- The open-source start page says the first start shows "Metabase Initialization Complete" before the admin setup at localhost:3000.
