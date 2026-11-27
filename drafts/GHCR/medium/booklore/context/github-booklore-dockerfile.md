# Upstream Dockerfile, entrypoint.sh and application.yaml: booklore-app/booklore (commit f397e98c)

**Source URL(s):** https://raw.githubusercontent.com/booklore-app/booklore/f397e98c5ab021b02e8930ce278583af11637238/Dockerfile (blob URL in urls.txt is the same file); .../entrypoint.sh; .../booklore-api/src/main/resources/application.yaml (fetched 2026-11-27). Commit is the draft's pin, not the v2.4.0 tag.

## Stage 1: angular-build
- `FROM node:24-alpine`; `COPY booklore-ui/package*.json`; `npm config set registry https://registry.npmjs.org/`; `npm ci --force`.
- `COPY ./booklore-ui`; `npm run build --configuration=production`.

## Stage 2: springboot-build
- `FROM gradle:9.3.1-jdk25-alpine`.
- Copies `booklore-api/build.gradle`, `settings.gradle`; `gradle dependencies --no-daemon` (cache mount `/home/gradle/.gradle`).
- COPY `booklore-api/src`; copies Angular `dist/booklore/browser` -> `src/main/resources/static`.
- `ARG APP_VERSION`; `apk add yq`; `yq eval '.app.version = strenv(APP_VERSION)' -i application.yaml`.
- `gradle clean build -x test --no-daemon --parallel`.

## Stage 3: final
- `FROM eclipse-temurin:25-jre-alpine`.
- ARG `APP_VERSION`, `APP_REVISION`; OCI labels incl. `org.opencontainers.image.licenses="GPL-3.0"`, `documentation=https://booklore.org/docs/getting-started`.
- ENV `JAVA_TOOL_OPTIONS="-XX:+UseG1GC -XX:+UseCompactObjectHeaders -XX:+UseStringDeduplication -XX:MaxRAMPercentage=75.0 -XX:+ExitOnOutOfMemoryError"`.
- `ARG TARGETARCH`; apk `su-exec libstdc++ libgcc`; `mkdir -p /bookdrop`.
- COPY `docker/unrar/unrar-${TARGETARCH}` -> `/usr/local/bin/unrar` (chmod 755).
- COPY `entrypoint.sh` -> `/usr/local/bin/entrypoint.sh` (chmod +x).
- COPY jar `booklore-api-0.0.1-SNAPSHOT.jar` -> `/app/app.jar`.
- `ARG BOOKLORE_PORT=6060`; `EXPOSE ${BOOKLORE_PORT}`.
- `ENTRYPOINT ["entrypoint.sh"]`, `CMD ["java", "-jar", "/app/app.jar"]`. No USER.

## entrypoint.sh
- `USER_ID` default 1000, `GROUP_ID` default 1000.
- Creates group `booklore` (`addgroup -S`) and user `booklore` (`adduser -S -D`) if missing.
- `mkdir -p /app/data /bookdrop`; `chown USER_ID:GROUP_ID` (errors ignored).
- `exec su-exec "$USER_ID:$GROUP_ID" "$@"`. Starts as root.

## application.yaml (relevant keys)
- `app.path-config: '/app/data'` (hard-coded)
- `app.bookdrop-folder: '/bookdrop'` (hard-coded)
- `app.version: 'development'` (overwritten at build by APP_VERSION)
- `server.port: ${BOOKLORE_PORT:6060}`
- `spring.datasource.url: ${DATABASE_URL:jdbc:mariadb://${DATABASE_HOST:${DB_HOST:mariadb}}:${DATABASE_PORT:3306}/${DATABASE_NAME:booklore}?createDatabaseIfNotExist=true&connectionTimeZone=UTC&forceConnectionTimeZoneToSession=true}`
- `spring.datasource.username: ${DATABASE_USERNAME:root}`; `password: ${DATABASE_PASSWORD:${MYSQL_ROOT_PASSWORD}}`
- Flyway: `classpath:db/migration`

## Env vars (read by upstream)
| Var | Default | Where |
| --- | --- | --- |
| BOOKLORE_PORT | 6060 | application.yaml, Dockerfile ARG |
| DATABASE_URL | (jdbc URL built from below) | application.yaml |
| DATABASE_HOST / DB_HOST | mariadb | application.yaml |
| DATABASE_PORT | 3306 | application.yaml |
| DATABASE_NAME | booklore | application.yaml |
| USER_ID / GROUP_ID | 1000 | entrypoint.sh |
| JAVA_TOOL_OPTIONS | (set in image) | Dockerfile ENV |
| APP_VERSION / APP_REVISION | build args | Dockerfile |

## Ports
- 6060 (EXPOSE ${BOOKLORE_PORT})

## Volumes/paths
- `/app/data` (app data), `/bookdrop` (import folder; created in image). No VOLUME.

## User/UID
- Starts as root; entrypoint drops to USER_ID/GROUP_ID (default 1000) via su-exec.

## Arch
- Final stage uses `TARGETARCH` only for the `unrar` binary (amd64, arm64 variants).

## Gotchas
- Requires MariaDB (application.yaml defaults host to `mariadb`).
- Java 25 JRE base; Gradle build stage needs JDK 25.
