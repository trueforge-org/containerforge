# onlyoffice-document-server — implementation plan
> Source: ./draft.md · Target: apps/onlyoffice-document-server/ · Difficulty: hard (largest of the batch) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | `10.0.0` (GitHub release `v10.0.0` marked Latest; draft tag `10.0.0` is the same). |
| Renovate | `datasource=github-releases depName=ONLYOFFICE/DocumentServer versioning=semver extractVersion=^v(?<version>.+)$` (tag has a `v` prefix; check the `-` build suffixes ONLYOFFICE sometimes adds, UNVERIFIED). |
| License | AGPL-3.0 (Docker-DocumentServer README); SPDX `AGPL-3.0-only` (README says "GNU AGPL v3.0", the or-later variant is not stated). |
| Source URL | https://github.com/ONLYOFFICE/DocumentServer |
| Per-arch download | amd64: `https://github.com/ONLYOFFICE/DocumentServer/releases/download/v10.0.0/onlyoffice-documentserver_amd64.deb` (HTTP 200, 557,621,524 bytes). arm64: `.../onlyoffice-documentserver_arm64.deb` (HTTP 200, 553,350,620 bytes). The upstream Dockerfile instead uses `https://download.onlyoffice.com/install/documentserver/linux/onlyoffice-documentserver_<arch>.deb` (and `_<version>_` infix when `PACKAGE_VERSION` is set). Both are the Community edition (`PRODUCT_EDITION` empty). |
| Checksum | GitHub release assets list no sha256 on the page, the API digest could not be read (rate limited): UNVERIFIED. Compute with `sha256sum` during implementation and pin as `ARG ONLYOFFICE_SHA256_AMD64`/`_ARM64`. |
| Upstream Dockerfile reviewed | https://github.com/ONLYOFFICE/Docker-DocumentServer/blob/master/Dockerfile : `ubuntu:24.04`; apt `ca-certificates curl gnupg locales sudo cron certbot python3-certbot-nginx netcat-openbsd supervisor`; downloads the deb, imports the ONLYOFFICE key, preseeds msttcorefonts EULA, `apt-get install` the local deb (pulls nginx, postgresql, rabbitmq, redis, fonts as dependencies), requires >= 30 ttf in `/usr/share/fonts/truetype/msttcorefonts`; `ENV DS_DOCKER_INSTALLATION=true DS_PLUGIN_INSTALLATION=false`; `EXPOSE 80 443`; `VOLUME /var/log/onlyoffice /var/lib/onlyoffice /var/www/onlyoffice/Data /usr/share/fonts/truetype/custom`; entrypoint `/app/ds/run-document-server.sh`; runs as root. |
| Env vars (README) | DB: `DB_TYPE` (`postgres` default), `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PWD`, `DB_SCHEMA`, `DB_TLS_MODE` (`disable`). Redis: `REDIS_SERVER_HOST`, `REDIS_SERVER_PORT`, `REDIS_SERVER_USER`, `REDIS_SERVER_PASS`, `REDIS_SERVER_DB` (0), `REDIS_TLS_MODE`. AMQP: `AMQP_URI`, `AMQP_TYPE` (`rabbitmq`), `AMQP_TLS_MODE`. JWT/security: `JWT_ENABLED` (true), `JWT_SECRET` (random if unset), `JWT_HEADER` (Authorization), `JWT_IN_BODY` (false), `SECURE_LINK_SECRET`, `WOPI_ENABLED` (false), `ALLOW_PRIVATE_IP_ADDRESS` (false), `ALLOW_META_IP_ADDRESS` (false), `USE_UNAUTHORIZED_STORAGE` (false), `IP_FILTER_RULES`. Other: `GENERATE_FONTS` (true), `WELCOME_PAGE_ENABLED` (true), `EXAMPLE_ENABLED` (false), `PLUGINS_ENABLED` (true), `METRICS_*`, `NGINX_*`, `SSL_*`. README notes the DB/Redis/AMQP table as "Enterprise/Developer editions only"; whether the Community docker image honours them for external servers is UNVERIFIED (the community image bundles its own postgres, redis and rabbitmq). |
| Ports | 80 (nginx), 443 optional TLS. Volumes per upstream listed above. |
| Health | `/healthcheck` endpoint on the nginx port returning `true` is the documented ONLYOFFICE liveness URL; not stated in the README pages read: UNVERIFIED. |

## 2. Target layout

```
apps/onlyoffice-document-server/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  etc/onlyoffice-ds/supervisord.conf    # rootless supervisor config in /tmp and /config paths
  etc/onlyoffice-ds/nginx-ds.conf       # rootless nginx main config (port 8080, tmp paths)
  scripts/render-config.sh              # maps env vars to /config/ds/local.json (invoked by start.sh)
```
`etc/` and `scripts/` are in the `include/.dockerignore` allow-list. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a`

Why: the vendor `.deb` targets Ubuntu and brings nginx/Node components itself; upstream uses 24.04, so 26.04 compatibility of the package dependencies (nginx-extras, libicu, rabbitmq/erlang, fonts) is UNVERIFIED. Closest siblings: `apps/mastodon` and `apps/nextcloud-fpm` (multi-service with a supervisor-like start.sh), `apps/bookstack` (nginx/php on ubuntu).

## 4. Dockerfile

1. `FROM` above; `ARG VERSION`, `ARG TARGETARCH`, `ARG ONLYOFFICE_SHA256_AMD64`, `ARG ONLYOFFICE_SHA256_ARM64` (value computed at implementation time); `USER root`; `ENV DEBIAN_FRONTEND=noninteractive DS_DOCKER_INSTALLATION=true DS_PLUGIN_INSTALLATION=false`.
2. Pre-seed the msttcorefonts EULA with `debconf-set-selections` as upstream does; `apt-get install -y --no-install-recommends ca-certificates curl locales supervisor netcat-openbsd postgresql-client` (client only, to create the schema in the external DB) and let apt pull the deb's dependencies. Do not add packages the base already has.
3. Download per arch: `case "${TARGETARCH}" in amd64) sha="${ONLYOFFICE_SHA256_AMD64}";; arm64) sha="${ONLYOFFICE_SHA256_ARM64}";; esac`; `curl -fsSL -o /tmp/ds.deb "https://github.com/ONLYOFFICE/DocumentServer/releases/download/v${VERSION}/onlyoffice-documentserver_${TARGETARCH}.deb"`; `echo "${sha}  /tmp/ds.deb" | sha256sum -c -`; `apt-get install -y --no-install-recommends /tmp/ds.deb`; assert the installed version: `dpkg-query -W -f='${Version}' onlyoffice-documentserver | grep -q "^${VERSION}"`.
4. Strip what must not run in the container: disable the deb's postinst-started services and the bundled `postgresql`/`redis`/`rabbitmq` service autostarts; keep `rabbitmq-server` binaries because AMQP has no ContainerForge app yet (RabbitMQ runs bundled, see section 7, UNVERIFIED).
5. Pre-generate fonts and static caches at build time (`/usr/bin/documentserver-generate-allfonts.sh` and `documentserver-pluginsmanager.sh` equivalents, exact script names UNVERIFIED) so nothing under `/var/www/onlyoffice/documentserver` needs writing at runtime. Symlink runtime-written dirs to `/config` or `/tmp`:
   - `/var/lib/onlyoffice` -> `/config/lib`
   - `/var/www/onlyoffice/Data` -> `/config/data`
   - `/var/log/onlyoffice` -> `/config/logs`
   - `/etc/onlyoffice/documentserver/local.json` -> `/config/ds/local.json`
   - fonts cache -> `/config/fonts` (UNVERIFIED location)
6. Licence: `mkdir -p /usr/share/licenses/onlyoffice-document-server && cp /var/www/onlyoffice/documentserver/LICENSE.txt /var/www/onlyoffice/documentserver/3rd-Party.txt /usr/share/licenses/onlyoffice-document-server/` (file names UNVERIFIED, confirm after install).
7. `rm -f /tmp/ds.deb /etc/nginx/conf.d/default.conf`; `rm -rf /var/lib/apt/lists/* /tmp/*`; `chown -R root:root` the app tree, `chmod -R a+rX`; make the few dirs the app must write (`/config` subtrees) writable only through the volume.
8. `ENV HOME=/config`.
9. `USER apps`
10. `COPY --chmod=0755 . /`
11. `EXPOSE 8080`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

```hcl
variable "APP" {
  default = "onlyoffice-document-server"
}

variable "VERSION" {
  // renovate: datasource=github-releases depName=ONLYOFFICE/DocumentServer versioning=semver extractVersion=^v(?<version>.+)$
  default = "10.0.0"
}

variable "LICENSE" {
  default = "AGPL-3.0-only"
}

variable "SOURCE" {
  default = "https://github.com/ONLYOFFICE/DocumentServer"
}
```
With `target "docker-metadata-action" {}`, `group "default" { targets = ["image-local"] }`, `image` (args VERSION and the two sha ARGs only if exposed as bake variables, each with matching Dockerfile defaults), `image-local` (`tags = ["${APP}:${VERSION}"]`, `output = ["type=docker"]`) and `image-all` (amd64+arm64), copied from `apps/adguardhome-sync/docker-bake.hcl`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/ONLYOFFICE/DocumentServer"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - name: DB_TYPE
    default: "postgres"
    required: false
  - name: DB_HOST
    default: "postgresql"
    required: true
  - name: DB_PORT
    default: "5432"
    required: false
  - name: DB_NAME
    default: "onlyoffice"
    required: false
  - name: DB_USER
    default: "onlyoffice"
    required: false
  - name: DB_PWD
    default: "onlyoffice"
    required: true
  - name: REDIS_SERVER_HOST
    default: "valkey"
    required: false
  - name: REDIS_SERVER_PORT
    default: "6379"
    required: false
  - name: JWT_ENABLED
    default: "true"
    required: false
  - name: JWT_SECRET
    default: ""
    required: false
  - name: JWT_HEADER
    default: "Authorization"
    required: false
  - name: WOPI_ENABLED
    default: "false"
    required: false
  - name: ALLOW_PRIVATE_IP_ADDRESS
    default: "false"
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies:
  - name: postgresql   # ✅ apps/postgresql exists
  - name: valkey       # ✅ apps/valkey exists
```
Port 80 is replaced by 8080 (rootless); 443 dropped (TLS at the proxy). Every env name above is documented in the README; `start.sh` (via `scripts/render-config.sh`) must default `JWT_SECRET` to a random value persisted in `/config/ds/jwt_secret` when empty, which is why `required` is false. `DB_PWD` has a non-empty default so `required: true` is satisfied.

## 7. start.sh

1. `mkdir -p /config/{ds,lib,data/certs,logs,fonts,rabbitmq} /tmp/{nginx,supervisor,ds}`.
2. Seed on empty `/config`: copy `/etc/onlyoffice/documentserver/local.json.default` (name UNVERIFIED; create from the deb's `default.json` if absent) to `/config/ds/local.json` only when missing. Generate and persist `JWT_SECRET` and `SECURE_LINK_SECRET` in `/config/ds/` when unset (mode 600), never in argv.
3. Render config every start (`scripts/render-config.sh`, idempotent, applies DB password each start): update `/config/ds/local.json` keys `services.CoAuthoring.sql.{type,dbHost,dbPort,dbName,dbUser,dbPass}`, `services.CoAuthoring.redis.{host,port}`, `rabbitmq.url` / `queue.*`, `services.CoAuthoring.token.enable.{browser,request.inbox,request.outbound}`, `services.CoAuthoring.secret.{inbox,outbox,session,browser}.string`, `wopi.enable`, `request-filtering-agent.allowPrivateIPAddress` using `jq` (add `jq` to the apt list, check base first). Exact key names are from ONLYOFFICE's configuration docs and are UNVERIFIED; derive them from the upstream `run-document-server.sh` during implementation. Values pass through `jq --arg`, so special characters do not break JSON.
4. Wait up to 120 s for `${DB_HOST}:${DB_PORT}` and the Redis host; if reachable, create the schema once: `PGPASSWORD="$DB_PWD" psql -h ... -U ... -d ... -tAc "select to_regclass('public.doc_changes')"`, and when null run the vendor `createdb.sql` from `/var/www/onlyoffice/documentserver/server/schema/postgresql/createdb.sql` (path UNVERIFIED). DB must already exist (apps/postgresql creates `POSTGRES_DB`/user).
5. Start bundled RabbitMQ (`RABBITMQ_MNESIA_BASE=/config/rabbitmq`, `RABBITMQ_NODENAME=rabbit@localhost`, cookie in `/config/rabbitmq/.erlang.cookie`, mode 400) under supervisord (rootless config in `/etc/onlyoffice-ds/supervisord.conf` with `[supervisord] nodaemon=true logfile=/tmp/supervisor/supervisord.log pidfile=/tmp/supervisor/supervisord.pid`, `user` directives removed). Programs: `rabbitmq`, `docservice`, `converter`, `nginx`, and optionally `metrics`. Feasibility of a rootless RabbitMQ is UNVERIFIED.
6. nginx: `/etc/onlyoffice-ds/nginx-ds.conf` includes the vendor `ds.conf` with `listen 0.0.0.0:8080`, `pid /tmp/nginx/nginx.pid`, temp paths under `/tmp/nginx`, no `user` directive.
7. Final: `exec /usr/bin/supervisord -c /etc/onlyoffice-ds/supervisord.conf` (supervisord is PID 1 child of the shell via exec; it forwards signals). All listeners bind `0.0.0.0`.

Never write to `/app` (unused) or `/var/www/onlyoffice/documentserver`; `/tmp` for runtime caches (`NODE_*`, nginx temp).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 300
tcp:
- port: '8080'
filePaths:
- /var/www/onlyoffice/documentserver/server/DocService/docservice
- /var/www/onlyoffice/documentserver/server/FileConverter/converter
- /usr/share/licenses/onlyoffice-document-server
- /start.sh
```
Probe for port 8080 is `tcp`; nginx listens even when the DB is down. The database-dependent narrowing exception is NOT claimed: the server process and nginx start without a database (the tcp probe passes), so the exception's "will not start without it" criterion does not hold; the DB-gated paths (schema creation, `/healthcheck`, editing) are not covered by this suite and are run by hand in section 11. File names under `server/` follow the vendor package layout (UNVERIFIED, verify after install; edit paths to the real binaries, do not drop the asserts). The run with a real PostgreSQL/Valkey is done manually in section 11 and must pass `curl http://localhost:8080/healthcheck`.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write path / behaviour | Remap |
|---|---|
| Runs as root under supervisord; nginx on 80/443, `sudo`, `cron`, `certbot` | Dropped; nginx on 8080 as `apps`, TLS via proxy, no cron/certbot, `sudo` not needed |
| `/var/log/onlyoffice` | `/config/logs` |
| `/var/lib/onlyoffice` (file cache, fonts index) | `/config/lib` |
| `/var/www/onlyoffice/Data` (certs, uploads) | `/config/data` |
| `/etc/onlyoffice/documentserver/local.json` rewritten at start | symlink to `/config/ds/local.json` |
| `/var/lib/postgresql`, `/var/lib/redis` (bundled, upstream volumes) | not bundled; external postgresql and valkey |
| `/var/lib/rabbitmq` | `/config/rabbitmq` (bundled RabbitMQ, UNVERIFIED) |
| nginx `/var/run`, `/var/lib/nginx` | `/tmp/nginx` |
| Font generation (`GENERATE_FONTS=true`) at start | done at build; runtime regeneration only writes `/config/fonts` |
| Draft: UID 0, rootfs writable, no persistence | UID 568, read-only rootfs, single `/config` volume (`/var/log`, `/var/lib`, `Data` volumes of upstream map under it) |

## 10. Risks, caveats and open questions

- Very large (two ~550 MB debs; image several GB) and multi-process; rootless RabbitMQ + supervisord + nginx + Node may not work with a read-only rootfs without more remaps.
- ONLYOFFICE's Community image bundles postgres/redis/rabbitmq; external-server env vars are listed as Enterprise/Developer in the README (UNVERIFIED for Community). If they are not honoured, `render-config.sh` writing `local.json` directly (planned) is the fallback.
- No ContainerForge `rabbitmq` app exists, so AMQP must be bundled (or a new rabbitmq/activemq app planned first).
- Ubuntu 26.04 vs vendor-tested 24.04: dependency resolution risk (UNVERIFIED); fallback is to pin an ubuntu 24.04 base which ContainerForge does not offer.
- JWT secret and base URL must match the connecting suite (Nextcloud, etc.).
- `msttcorefonts` downloads from SourceForge during install (flaky; upstream checks for >= 30 ttf).
- Download also available at download.onlyoffice.com; GitHub assets chosen because the draft links them.
- UNVERIFIED count: 12 (SPDX variant, renovate tag suffixes, checksums, external DB env on Community, `/healthcheck`, 26.04 compatibility, font script names, licence file names, local.json key names, createdb.sql path, rootless RabbitMQ, server binary paths).

## 11. Build and test steps

```sh
cd apps/onlyoffice-document-server
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create onlyoffice-document-server-probe-config
docker run --rm -d --name onlyoffice-document-server-probe --read-only --tmpfs /tmp -v onlyoffice-document-server-probe-config:/config onlyoffice-document-server:10.0.0
docker logs -f onlyoffice-document-server-probe
forgetool containers test --image onlyoffice-document-server:10.0.0 --config ./apps/onlyoffice-document-server/container-test.yaml
docker rm -f onlyoffice-document-server-probe; docker volume rm onlyoffice-document-server-probe-config
```
Without a database the log may show "waiting for database"/connection retries; that counts as readiness only while the process stays alive and nginx answers on 8080 (no narrowing exception is claimed). Full run: start `postgresql` and `valkey` containers on one network (`DB_HOST`, `DB_PWD`, `REDIS_SERVER_HOST`), then expect `curl http://localhost:8080/healthcheck` to return `true` and `http://localhost:8080/` to serve the welcome page. Repeat with a changed `DB_PWD` to prove it is applied on restart. Round limit 10; clean scratch containers/volumes each round.

## 12. PR checklist

- Branch `feat/add-onlyoffice-document-server`; commit and PR title `feat(onlyoffice-document-server): add new container`; target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md` (keep sections, tick only applicable boxes); include source, version, base, ports/volumes, dependencies (postgresql, valkey); `🤖 This PR is AI generated.` in Notes.
- CLA notice for the user: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested at plan time: all builds and runs, arm64, RabbitMQ rootless, external DB/Redis wiring, JWT flow with a client app, font generation. Say so in the PR; do not check "Built container locally" unless done.
