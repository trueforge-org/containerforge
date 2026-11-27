# GitHub: MDeLuise/plant-it

## Source URL(s) + date
- https://raw.githubusercontent.com/MDeLuise/plant-it/0.10.0/deployment/Dockerfile
- https://github.com/MDeLuise/plant-it (repo page, for license)
- Fetched 2026-11-27
- api.github.com/repos/MDeLuise/plant-it/license: DNS error (EAI_AGAIN); repo HTML page used as the one alternative.

## License
- GPL-3.0 (repo page shows "GPL-3.0 license"). SPDX `-only` vs `-or-later` not shown on the page; check LICENSE.txt header.

## Upstream Dockerfile (deployment/Dockerfile, tag 0.10.0)
- Single stage `FROM alpine:3.20.2`.
- `ARG JAVA_VERSION=21`, `ARG JAR_FILE=backend/target/*.jar`.
- RUN: `apk update && apk add bash wget nginx openjdk${JAVA_VERSION}-jre`.
- RUN: `mkdir -p /opt/app`.
- RUN: `wget https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh -O /opt/app/wait-for-it.sh` (unpinned external download at build).
- RUN: `chmod +x /opt/app/start.sh /opt/app/wait-for-it.sh`.
- COPY `${JAR_FILE}` to `/opt/app/backend/app.jar`; `deployment/start.sh` to `/opt/app/start.sh`; `frontend/build/web` to `/opt/app/frontend/build/web`; `deployment/nginx.conf` to `/etc/nginx/nginx.conf`.
- `WORKDIR /opt/app/frontend`.
- `EXPOSE 8080` and `EXPOSE 3000`.
- `CMD ["/bin/sh", "-c", "/opt/app/start.sh"]`.
- No ENV, USER, VOLUME, ENTRYPOINT.

## Runtime deps
- Java 21 JRE (openjdk21-jre), nginx, bash, wget.

## Entrypoint/flags
- `/opt/app/start.sh` (contents not fetched).

## Ports
- 8080 (backend), 3000 (nginx/frontend per plan; nginx.conf not fetched).

## Volumes/paths
- App: `/opt/app/backend/app.jar`, `/opt/app/frontend/build/web`, nginx config at `/etc/nginx/nginx.conf`.

## User/UID
- Not set; runs as root.

## Gotchas
- Upstream uses JRE 21 (Alpine); not Java 17.
- wait-for-it.sh fetched from GitHub master (unpinned) at build time.
- start.sh and nginx.conf contents not fetched; env var names for DB/Redis/JWT not in Dockerfile.
