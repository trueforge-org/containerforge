# wisemapping-open-source README (backend repo)

## Source URL(s) + date
- https://raw.githubusercontent.com/wisemapping/wisemapping-open-source/develop/README.md (fetched 2026-11-26; GitHub mirror used because the Bitbucket raw URL 404'd)

## What it is
- Free, open-source web mind-mapping tool (Spring Boot v4 backend `wise-api/`, React frontend in separate repo). Powers https://www.wisemapping.com.
- License: "WiseMapping Open License, Version 1.0" (link to `LICENSE.md` on develop). README does not give an SPDX id.

## Install/build steps + deps
- Prerequisites: JDK 27+, Maven 3.x, Yarn v4+, Node v24+.
- Backend: `mvn -f wise-api/pom.xml package` then `cd wise-api && mvn spring-boot:run` (API on :8080, in-memory HSQLDB).
- Frontend: checkout `wisemapping-frontend`; `export APP_CONFIG_TYPE="file:dev"`; `yarn install`; `yarn build`; `cd packages/webapp; yarn start` (UI on :3000, proxies `/api` to :8080).
- Run jar: `java -jar wise-api/target/wisemapping-api.jar --spring.config.additional-location=file:./app.yml`

## Runtime deps
- Supported DB: PostgreSQL 15+ (recommended), MySQL 8+, MariaDB 11.4+; HSQLDB 2.7+ dev/test only.

## Entrypoint/flags
- Overlay config via `--spring.config.additional-location=file:./app.yml` (Spring Boot external config).

## Config files
- Preferred: override `wise-api/src/main/resources/application.yml` via an external app.yml.
- Examples: `distribution/app-postgresql/app.yml`; MySQL/MariaDB overlays under `distribution/`.
- Compose: `distribution/app-postgresql` (also app-mysql, app-mariadb); `.env.example`; needs `WISEMAPPING_DATA_DIR` and DB password (Compose fails if unset).

## Env vars
- Not listed in README (see `distribution/app-postgresql/README.md` per README).

## Ports
- Frontend dev server 3000; API 8080.

## Seeded accounts (compose/dev)
| Account | Password |
| --- | --- |
| test@wisemapping.org | password |
| admin@wisemapping.org | testAdmin123 |

## Healthcheck
- None in README.

## Gotchas
- README says "Docker deployment: production-ready multi-architecture (amd64 and arm64) images on Docker Hub".
- README points production users to Docker Hub, not to a build.
- Features list includes LDAP, OIDC, Google/Facebook OAuth2, Micrometer/Prometheus telemetry (off by default).
