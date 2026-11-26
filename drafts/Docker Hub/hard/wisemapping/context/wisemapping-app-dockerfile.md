# wisemapping-open-source: distribution/app (Dockerfile, start.sh, nginx.conf)

## Source URL(s) + date
- https://raw.githubusercontent.com/wisemapping/wisemapping-open-source/5099d14e6290138a97f599079eaf42daa2d2ad3c/distribution/app/Dockerfile (fetched 2026-11-26)
- .../5099d14e6290138a97f599079eaf42daa2d2ad3c/distribution/app/start.sh (fetched 2026-11-26)
- .../5099d14e6290138a97f599079eaf42daa2d2ad3c/distribution/app/nginx.conf (fetched 2026-11-26)

## What it is
- Single image: Spring Boot API (backend) + React SPA (frontend) served by nginx, supervised by tini.
- Upstream Dockerfile is a 3-stage build.

## Install/build steps + deps
- Stage 1 `backend-builder`: `eclipse-temurin:27-jdk-alpine`, `apk add maven`, copy `wise-api/pom.xml` + `wise-api/src`, in `/build/wise-api`:
  `mvn clean package -DskipTests -Dgit.branch=unknown -Dgit.commit.id.abbrev=unknown -Dgit.commit.id.full=unknown -Dgit.commit.time=unknown`
- Stage 2 `frontend-builder`: `node:24-alpine`, `apk add git`, `ARG FRONTEND_BRANCH=develop`, `ARG CACHEBUST=1`,
  `git clone --depth 1 --branch ${FRONTEND_BRANCH} https://github.com/wisemapping/wisemapping-frontend.git`
  - `sed` on `packages/webapp/config.prod.json`: `"url": "http://localhost:3000/api/restful/app/config"` -> `"url": "/api/restful/app/config"`
  - `ENV COREPACK_ENABLE_STRICT=0`; `corepack enable && corepack prepare yarn@4.13.0 --activate`; `yarn install`
  - `ENV NODE_OPTIONS="--max-old-space-size=4096"`; `APP_CONFIG_TYPE=file:prod yarn build --concurrency 1`
  - `sed` removes `<base ...>` from `packages/webapp/dist/index.html`, inserts `<base>` after `<head>` (placeholder for nginx sub_filter)
- Stage 3 `eclipse-temurin:27-jre-alpine`: `apk add nginx tini su-exec`; group/user `wisemapping` gid 1001 / uid 1001 (`addgroup -S`, `adduser -S`)
  - mkdirs `/app`, `/var/log/nginx`, `/run/nginx`, `/usr/share/nginx/html`, `/var/lib/nginx/tmp/client_body`, `/var/lib/nginx/tmp/proxy`; chown to wisemapping; `chown -R 100:101 /var/lib/nginx`
  - `COPY --from=backend-builder ... /build/wise-api/target/wisemapping-api.jar /app/wisemapping-api.jar`
  - `mkdir -p /app/config` (optional app.yml)
  - `COPY --from=frontend-builder ... dist -> /usr/share/nginx/html/`
  - `COPY distribution/app/nginx.conf /etc/nginx/http.d/default.conf`
  - `COPY distribution/app/start.sh /app/start.sh`; `chmod +x`

## Runtime deps
- JRE 27 (Temurin alpine), nginx, tini (`/sbin/tini`), su-exec.
- Upstream comment: Supervisor deliberately NOT installed (libexpat/python skew, issue #70).

## Entrypoint/flags
- `ENTRYPOINT ["/sbin/tini", "--"]`, `CMD ["/app/start.sh"]`, `WORKDIR /app`
- start.sh (`#!/bin/sh`, `set -e`):
  - `nginx -g 'daemon off;' &`
  - `exec su-exec wisemapping:wisemapping sh -c "java -XX:-UseBASE64Intrinsics ${JAVA_OPTS} -Dspring.config.additional-location=optional:file:/app/config/ -jar /app/wisemapping-api.jar"`
  - `-XX:-UseBASE64Intrinsics` = Java4Shell mitigation (CVE-2026-114938) for JDK older than 27.0.1.1 (script comment).

## Env vars
| Var | Upstream default | Use |
| --- | --- | --- |
| JAVA_OPTS | unset in Dockerfile (start.sh expands it, empty ok) | extra JVM flags |

## Ports
- `EXPOSE 80` (nginx). Backend Spring Boot listens 8080 (proxied by nginx to `http://localhost:8080`).

## Volumes/paths
- `/app/config/` (optional app.yml, created and owned by wisemapping)
- `/usr/share/nginx/html` (frontend)
- `/var/lib/nginx`, `/var/log/nginx`, `/run/nginx` (chowned, nginx runtime)

## User/UID
- Runtime user `wisemapping` uid/gid 1001. start.sh drops to it via `su-exec` for Java. nginx runs as the container root in this layout (no `user` directive in nginx.conf).

## Config files
- `/etc/nginx/http.d/default.conf` = upstream `distribution/app/nginx.conf`.
- nginx.conf: `listen 80`, `server_name _`, `gzip on`, `charset UTF-8`.
  - `sub_filter '<base>' '<base href="$base_scheme://$http_host/">'` (sub_filter_once on)
  - `location /` -> root `/usr/share/nginx/html`, `try_files $uri /index.html`
  - `location /c/` -> try_files to `/usr/share/nginx/html/index.html`
  - `location /api/restful/app/config` -> proxy `http://localhost:8080/api/restful/app/config`; sub_filter rewrites `apiBaseUrl`/`uiBaseUrl` JSON values (localhost:8080 and localhost:3000) to `$base_scheme://$http_host`
  - `location /api/` -> proxy `http://localhost:8080/api/`, timeouts 60s
  - `location ~ ^/(oauth2|login/oauth2)/` -> proxy `http://localhost:8080` with X-Forwarded-* headers
  - `location /health` -> `return 200 "healthy\n"` (access_log off)

## Healthcheck
- Upstream: none in Dockerfile. nginx `/health` returns 200 `healthy`.

## Version/asset naming
- Backend: Maven artifact `wisemapping-api.jar` (`wise-api/target/`).
- Frontend: built from branch `develop` unless `FRONTEND_BRANCH` overridden.

## Arch
- Not stated in these files.

## Gotchas
- `FRONTEND_BRANCH` / `CACHEBUST` args change the frontend build; upstream pins nothing by tag.
- nginx sub_filter strings hard-code `localhost:8080` and `localhost:3000`; brittle if defaults change.
- Upstream Dockerfile listens on port 80 as root-started nginx; a read-only/unprivileged variant must change nginx listen port and temp/pid paths.
