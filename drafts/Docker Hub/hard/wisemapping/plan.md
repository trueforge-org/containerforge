# wisemapping — implementation plan
> Source: ./draft.md · Target: apps/wisemapping/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `6.0.11` (Docker Hub `wisemapping/wisemapping:6.0.11`, pushed 2026-10-24; `latest` pushed 2026-10-29; frontend repo tag `6.0.11`). Draft says only `latest`. |
| Version caveat | `wisemapping-open-source` has NO `6.x` tags or releases (newest tag `v5.0.10`; `develop` pom is `6.0.9-SNAPSHOT`). Docker images are built from `develop` plus frontend `FRONTEND_BRANCH`. Backend commit that matches image `6.0.11` is UNVERIFIED. |
| Renovate | `datasource=github-tags depName=wisemapping/wisemapping-frontend versioning=loose` (tags `6.0.9`, `6.0.10`, `6.0.11`, no `v` prefix) |
| License | WiseMapping Public License 1.0 (Apache-2.0 plus "powered by wisemapping" notice, `LICENSE.md`). No SPDX id: use `LicenseRef-WiseMapping-WPL-1.0` (GitHub shows NOASSERTION). Frontend repo license UNVERIFIED. |
| Source | https://github.com/wisemapping/wisemapping-open-source (backend `wise-api/`), https://github.com/wisemapping/wisemapping-frontend (UI) |
| Downloads | Source tarballs: backend `https://github.com/wisemapping/wisemapping-open-source/archive/<BACKEND_REF>.tar.gz`, frontend `https://github.com/wisemapping/wisemapping-frontend/archive/refs/tags/${VERSION}.tar.gz`. JDK: Temurin 27 from `https://api.adoptium.net/v3/binary/latest/27/ga/linux/<x64\|aarch64>/jdk/hotspot/normal/eclipse` (also `jre`). Latest seen `jdk-27.0.1.1+4`; JRE x64 sha256 `9e15835ca3451a0089aac2c3667c009bc2743b9cb15030a14c6f5ec05f8d5aaf`. |
| Checksum | Adoptium publishes sha256 per asset (API `checksum` field). None for the source tarballs. |
| Upstream Dockerfile | Reviewed `distribution/app/Dockerfile` (3 stages: `eclipse-temurin:27-jdk-alpine` + Maven, `node:24-alpine` frontend with `yarn@4.13.0` via corepack, final `eclipse-temurin:27-jre-alpine` + nginx + tini). Also `distribution/api/Dockerfile`, `distribution/app/start.sh`, `distribution/app/nginx.conf`. |
| Build | Backend: `mvn clean package -DskipTests -Dgit.branch=unknown -Dgit.commit.id.abbrev=unknown -Dgit.commit.id.full=unknown -Dgit.commit.time=unknown` in `wise-api/`, output `target/wisemapping-api.jar`; `java.version` is 27 (JDK 27 required). Frontend: `config.prod.json` sed to relative URL, `corepack enable`, `yarn install`, `APP_CONFIG_TYPE=file:prod yarn build --concurrency 1` (`NODE_OPTIONS=--max-old-space-size=4096`), output `packages/webapp/dist`; `packageManager` is `yarn@4.18.1` at 6.0.11, Node `>=24`. Then `sed` removes `<base>` in `dist/index.html` and adds placeholder `<base>` for nginx `sub_filter`. |
| Ports | nginx `80/tcp` (frontend + `/api/` proxy + `/health` returning `healthy`), Spring Boot API `8080/tcp` (internal, proxied). |
| Config | Spring Boot: `-Dspring.config.additional-location=optional:file:/app/config/`. Default DB is in-memory HSQLDB (dev only). Supported: PostgreSQL 15+, MySQL 8+, MariaDB 11.4+. Postgres overlay (`distribution/app-postgresql/app.yml`): `spring.datasource.url jdbc:postgresql://postgresql:5432/wisemapping`, user `wisemapping`, `spring.sql.init.platform=postgresql`, `mode=always`, `schema-locations=classpath:schema-postgresql.sql`, `data-locations=classpath:data-postgresql.sql`, `jpa.hibernate.ddl-auto=validate`, `hibernate.dialect=org.hibernate.dialect.PostgreSQLDialect`, `hikari.data-source-properties.prepareThreshold=0`. |
| Env vars read | `JAVA_OPTS` (default `-XX:InitialRAMPercentage=60 -XX:MaxRAMPercentage=60`), `SPRING_CONFIG_ADDITIONAL_FILE_CONTENT` (api image only), Spring relaxed-binding env (`SPRING_DATASOURCE_*`, `SERVER_PORT`). Compose-only (NOT read by the app): `POSTGRES_*`, `WISEMAPPING_DATA_DIR`, `WISEMAPPING_PORT`. Mail/OAuth vars in `.env.example` are compose commented examples, whose mapping to the app is UNVERIFIED. |
| Default logins (compose README) | `test@wisemapping.org` / `password`, admin `admin@wisemapping.org` / `testAdmin123` (seeded by `data-*.sql`); must be changed in production. |

## 2. Target layout

```
apps/wisemapping/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  etc/nginx/nginx.conf     # full nginx config: unprivileged port, /tmp paths (nginx.conf copied to /etc/nginx/)
```

`etc/` is on the `.dockerignore` allow-list, so `COPY --chmod=0755 . /` ships it. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454`

Why: the draft proposed `java17`, but the backend is compiled for Java 27 (`<java.version>27</java.version>`), and no ContainerForge `java27` exists (java8/11/17/21/25 only; verified `apps/`). The runtime JRE 27 is therefore installed from the Temurin tarball like `apps/java25/Dockerfile` does, and nginx comes from apt on ubuntu. Closest siblings: `apps/java25` (Temurin install) and `apps/it-tools` / `apps/theme-park` (nginx). Build stages use `eclipse-temurin:27-jdk` style tooling: `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb... AS backend-build` with the Temurin JDK 27 tarball and `apt-get install maven`, and `... AS frontend-build` with Node 24.

## 4. Dockerfile

1. Stage `backend-build` (ubuntu, `USER root`): `apt-get install -y --no-install-recommends maven`; download Temurin JDK 27 for `${TARGETARCH}` (map `amd64`->`x64`, `arm64`->`aarch64`), verify sha256 from the Adoptium API, extract to `/opt/java/openjdk`, set `JAVA_HOME`. `ARG BACKEND_REF=<pinned develop commit sha>` (UNVERIFIED which sha corresponds to 6.0.11). Fetch tarball, `cd wise-api`, run the Maven command above, with `-Dmaven.repo.local=/tmp/m2`.
2. Stage `frontend-build` (ubuntu): install Node 24 (NodeSource-free option: Node tarball from nodejs.org with `SHASUMS256.txt` verification, or copy from `ghcr.io/trueforge-org/python-node` stage). Fetch frontend tarball `${VERSION}`, apply the `config.prod.json` and `index.html` seds from upstream, `corepack enable && corepack prepare yarn@4.18.1 --activate`, `yarn install`, `NODE_OPTIONS=--max-old-space-size=4096 APP_CONFIG_TYPE=file:prod yarn build --concurrency 1`. `ENV YARN_CACHE_FOLDER=/tmp/yarn COREPACK_HOME=/tmp/corepack`.
3. Final stage `FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb...`, `ARG VERSION`, `ARG TARGETARCH`, `USER root`:
   - `apt-get install -y --no-install-recommends nginx` (not in base; pin per `apps/valkey` style if a pin is wanted; nginx is not the tagged software so an unpinned install is acceptable but record the version in the PR). Remove default site: `rm -f /etc/nginx/sites-enabled/default /etc/nginx/conf.d/default.conf`.
   - Download Temurin JRE 27 (same mapping as above, sha256 verified) to `/opt/java/openjdk`; `ENV JAVA_HOME=/opt/java/openjdk PATH=$JAVA_HOME/bin:$PATH`.
   - `COPY --from=backend-build /build/wise-api/target/wisemapping-api.jar /app/wisemapping-api.jar`
   - `COPY --from=frontend-build /build/.../packages/webapp/dist /app/www/`
   - License: `/usr/share/licenses/wisemapping/LICENSE.md` (from the backend tarball) and the frontend `LICENSE` if present.
   - `chown -R root:root /app && chmod -R a+rX /app`; `rm -rf /var/lib/apt/lists/* /tmp/*`.
4. `ENV HOME=/tmp JAVA_OPTS="-XX:InitialRAMPercentage=60 -XX:MaxRAMPercentage=60"`.
5. `USER apps`, then `COPY --chmod=0755 . /`. `EXPOSE 8080`, `VOLUME /config`, `CMD ["/start.sh"]`. The image ends with `USER apps`.

## 5. docker-bake.hcl

- `APP` = `wisemapping`
- `VERSION`:
  ```hcl
  // renovate: datasource=github-tags depName=wisemapping/wisemapping-frontend versioning=loose
  default = "6.0.11"
  ```
- Extra variable `BACKEND_REF` (commit sha, passed as `args`), kept alongside VERSION and bumped manually (no renovate comment possible on a sha).
- `LICENSE` = `LicenseRef-WiseMapping-WPL-1.0`, `SOURCE` = `https://github.com/wisemapping/wisemapping-open-source/`
- Targets `docker-metadata-action`, `image` (args `VERSION`, `BACKEND_REF`), `image-local`, `image-all` (amd64 + arm64), group `default` -> `image-local`, as in `apps/adguardhome-sync/docker-bake.hcl`. Validate: `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/wisemapping/wisemapping-open-source/"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - name: TZ
    default: "Etc/UTC"
    required: false
  - name: JAVA_OPTS
    default: "-XX:InitialRAMPercentage=60 -XX:MaxRAMPercentage=60"
    required: false
  - name: WISEMAPPING_DB_URL
    default: ""
    required: false      # empty = embedded in-memory HSQLDB (dev/test only, data lost on restart)
  - name: WISEMAPPING_DB_USER
    default: "wisemapping"
    required: false
  - name: WISEMAPPING_DB_PASSWORD
    default: "MYPOSTGRESPASSWORD"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - name: postgresql   # ✅ apps/postgresql exists
    required: true
```

`WISEMAPPING_DB_*` are ContainerForge-specific names consumed by `start.sh`, not upstream names (upstream uses a YAML overlay). Default URL example for docs: `jdbc:postgresql://postgresql:5432/wisemapping`. Dependency stays `required: true` for production use even though the empty-URL fallback lets the test run.

## 7. start.sh

- `set -euo pipefail`; `mkdir -p /config/logs /tmp/nginx /tmp/wisemapping`.
- Render `/tmp/wisemapping/application.yml` only when `WISEMAPPING_DB_URL` is set, referencing the password through a Spring placeholder (`password: ${WISEMAPPING_DB_PASSWORD}`) so the secret never lands in a file or the process list. Contents mirror the Postgres overlay (driver `org.postgresql.Driver`, `sql.init` platform `postgresql`, `mode always`, `ddl-auto validate`, dialect, `prepareThreshold 0`); URL/user via placeholders too. If it is empty, log a warning: `WISEMAPPING_DB_URL not set, using embedded in-memory HSQLDB (data is lost on restart)`.
- Copy `/config/application.yml` support: pass `-Dspring.config.additional-location=optional:file:/tmp/wisemapping/,optional:file:/config/` so a user file overrides the generated one.
- Start nginx in the background: `nginx -c /etc/nginx/nginx.conf -g 'daemon off;' &` (config from `etc/nginx/nginx.conf`: `listen 8080;`, `pid /tmp/nginx/nginx.pid;`, all `*_temp_path` in `/tmp/nginx`, `error_log /dev/stderr;`, `access_log /dev/stdout;`, root `/app/www`, upstream copy of upstream `nginx.conf` locations with `proxy_pass http://127.0.0.1:8081`, keep the `sub_filter` strings that match `http://localhost:8080` because the backend still emits its default `app.site.*-base-url` values).
- Trap `SIGTERM` to stop nginx; then final command: `exec java -XX:-UseBASE64Intrinsics ${JAVA_OPTS} -Dserver.port=8081 -Dspring.config.additional-location=... -jar /app/wisemapping-api.jar` (the `-XX:-UseBASE64Intrinsics` flag is copied from upstream, which cites a mitigation for JDKs older than 27.0.1.1; Temurin 27.0.1.1 is used so it may be dropped, decide when implementing). Servers bind `0.0.0.0` via nginx; the API on 8081 is internal.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

http:
- port: '8080'
  path: /health
tcp:
- port: '8080'
filePaths:
- /app/wisemapping-api.jar
- /app/www/index.html
- /usr/share/licenses/wisemapping/LICENSE.md
```

`timeoutSeconds`: Spring Boot plus HSQLDB seeding is slow; copy the value from `apps/nzbhydra2/container-test.yaml` or `apps/airsonic-advanced/container-test.yaml` (use the larger, add margin). Because `start.sh` falls back to HSQLDB with no env, the test runs functionally and the DB-narrowing exception is NOT used. If nginx is up but Java crashed, the container exits, so the probe fails correctly. Add an `/api/restful/app/config` http probe only if it returns 200 (UNVERIFIED).

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
| --- | --- |
| nginx pid, temp dirs (`/run/nginx`, `/var/lib/nginx/tmp/*`), logs `/var/log/nginx` | all moved to `/tmp/nginx`, logs to stdout/stderr |
| `/app/config/application.yml` (written by `env-config.sh`) and draft's `WEB-INF/app.properties` init (old Tomcat image, no longer upstream) | generated in `/tmp/wisemapping`, user overrides in `/config` |
| Port 80 | 8080 (unprivileged); Java on 8081 internal |
| Spring logs (compose mounted `/var/log/supervisor`) | stdout; optional `/config/logs` |
| Java temp dir (`VOLUME /tmp` upstream) | `--tmpfs /tmp` |
| HSQLDB/EHCache | in-memory; no disk writes by default |

Draft expected runAsUser 0 and writable rootfs; the target is UID 568, read-only rootfs. Upstream also runs as `wisemapping` UID 1001 plus `su-exec`, so root is not required.

## 10. Risks, caveats and open questions

- No Java 27 base in ContainerForge; Temurin 27 is installed per image. Consider adding a shared `java27` app as a separate PR.
- Image `6.0.11` to backend commit mapping is UNVERIFIED; `develop` is a moving branch, so pin the sha.
- Frontend and backend are cloned from different repos; the frontend licence is UNVERIFIED.
- Hard dependency on PostgreSQL for real use (schema is created by `sql.init` with `mode: always`, so `schema-postgresql.sql` must be idempotent; UNVERIFIED on restart with existing data).
- `sub_filter` of `localhost:8080` strings is brittle if upstream changes defaults.
- Seeded default accounts and passwords (`test@wisemapping.org`/`password`, admin) must be documented as insecure.
- Long builds (Maven + yarn), memory 4 GiB for webpack; `image-all` arm64 build may be very slow under QEMU (upstream builds natively).
- Mail/OAuth env mapping UNVERIFIED, so none are declared in settings.yaml.

## 11. Build and test steps

```sh
cd apps/wisemapping
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create wisemapping-probe-config
docker run --rm -d --name wisemapping-probe --read-only --tmpfs /tmp \
  -v wisemapping-probe-config:/config wisemapping:6.0.11
docker logs -f wisemapping-probe
forgetool containers test --image wisemapping:6.0.11 --config ./apps/wisemapping/container-test.yaml
docker rm -f wisemapping-probe; docker volume rm wisemapping-probe-config
```

Readiness signal: Spring Boot `Started ... in ... seconds` plus `curl localhost:8080/health` returns `healthy`. Run once more against `apps/postgresql` on a shared network with `WISEMAPPING_DB_URL` set, and open `/c/login` from another container.

## 12. PR checklist

- Branch `feat/add-wisemapping`, commit `feat(wisemapping): add new container`, PR title the same, target `main`.
- PR template filled; `🤖 This PR is AI generated.` in Notes.
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested list: Maven build, frontend build, arm64, PostgreSQL run, backend-commit pinning, nginx config on unprivileged port, `/health` and config sub_filter behaviour.
