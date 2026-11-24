# weblate — implementation plan
> Source: ./draft.md · Target: apps/weblate/ · Difficulty: hard · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
|---|---|
| Version | **2026.11.2** (PyPI `Weblate` 2026.11.2, `requires_python >=3.12`; the upstream docker repo's current Dockerfile pins `WEBLATE_VERSION=2026.11.2`; docker repo tags `2026.11.2.0` and `2026.11.2.1` exist). The draft's `4.16.4` is stale; Weblate moved to calendar versions |
| Renovate | `datasource=pypi depName=Weblate versioning=pep440` (exactly the annotation upstream's own Dockerfile uses) |
| License | GPL-3.0-or-later (upstream Docker image label `org.opencontainers.image.licenses="GPL-3.0-or-later"`; repo LICENSE is GPLv3) |
| Source URL | https://github.com/WeblateOrg/weblate (docker packaging: https://github.com/WeblateOrg/docker) |
| Install | `pip` wheel, arch independent for the app itself; native deps (lxml, xmlsec, pycairo, PyGObject, psycopg) built or wheel-installed per arch. Upstream install line: `uv pip install --no-binary xmlsec --no-binary lxml -r requirements.txt "Weblate[all,zxcvbn,saml,wsgi,wllegal,oidc]==$WEBLATE_VERSION"` |
| Checksum source | PyPI hashes; no separate file (optional: `--require-hashes` with a pinned requirements file generated at port time) |
| Upstream Dockerfile reviewed | `WeblateOrg/docker` main (Dockerfile, `start`, `health_check`, `etc/supervisor/conf.d/*`, `etc/nginx/*`): multi-stage `weblate/dev` build then `weblate/base` final, `USER 1000`, `EXPOSE 8080`, `VOLUME /app/data` and `/app/cache`, `HEALTHCHECK /app/bin/health_check`, entrypoint `/app/bin/start` with `CMD runserver`. The 4.16.4-1 Dockerfile in the draft is obsolete |
| Process model (current upstream) | supervisor (pip `supervisor==4.3.0`) runs **granian** (ASGI/WSGI server on a unix socket `/run/granian/granian.sock`), nginx on **8080** (4443 with built-in SSL), and celery workers (`celery-combined` by default, or split queues) plus `celery-beat`; not uwsgi as the draft says |
| Health | `GET http://localhost:8080/healthz/` (from upstream `health_check`) |
| Env vars read (from `start` and `weblate/settings_docker.py`) | `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_DATABASE` (alias `POSTGRES_DB` in start), `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_SSL_MODE`; `REDIS_HOST` (required, upstream default `cache`), `REDIS_PORT` (6379), `REDIS_DB` (1), `REDIS_PASSWORD`, `REDIS_USER`, `REDIS_TLS`; `WEBLATE_SITE_DOMAIN`, `WEBLATE_ADMIN_NAME`, `WEBLATE_ADMIN_EMAIL`, `WEBLATE_ADMIN_PASSWORD`, `WEBLATE_SERVER_EMAIL`, `WEBLATE_ALLOWED_HOSTS`, `WEBLATE_DEBUG`, `WEBLATE_ENABLE_HTTPS`, `WEBLATE_SECRET_KEY`, `WEBLATE_DATA_DIR` (default `/app/data`), `WEBLATE_CACHE_DIR` (default `/app/cache`), `WEBLATE_SERVICE`, `WEBLATE_WORKERS`, `CELERY_WORKER_MODE`, `CLIENT_MAX_BODY_SIZE`, `WEBLATE_URL_PREFIX`, plus `*_FILE` secret variants for POSTGRES/REDIS/admin/email passwords |

## 2. Target layout

```
apps/weblate/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh                      # adapted from upstream `start` (tag 2026.11.2.1), paths remapped
  etc/weblate/nginx/default.tpl, nginx.conf, generate-site.py, errors/   # vendored from upstream etc/nginx
  etc/weblate/supervisor/supervisord.conf and conf.d/*.conf               # vendored from upstream etc/supervisor
  scripts/health_check          # adapted upstream health_check
  scripts/requirements.txt      # upstream docker requirements.txt (pinned deps), vendored
```
`etc/` is allow-listed by `include/.dockerignore`; a sub-folder `etc/weblate/` avoids overwriting the distro's `/etc/nginx`. The vendored upstream files are GPL-3.0 (docker repo license file: type UNVERIFIED, expected GPL-3.0); keep their headers and note the origin in the PR. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`, two stages (build with dev headers, final with runtime libs). Reason: pip-installed Django app; the base already ships `/app/venv`. Closest siblings: `apps/bazarr` (python base, uv/pip into venv, `COPY . /`), `apps/bookstack` and `apps/kasmvnc` (nginx in /tmp pattern). **Risk:** Weblate's pinned deps (lxml, xmlsec, pycairo, PyGObject, psycopg, granian) may have no wheels or fail to build on Python 3.15 (upstream builds with whatever `PYVERSION` its `weblate/base` image has; version UNVERIFIED). If the build fails, the fallback is a python 3.13/3.14 interpreter, which requires a new base: out of scope, report as blocker.

## 4. Dockerfile

Stage `build` (`FROM` python base, `USER root`):
1. apt dev packages for the wheel builds: `libxml2-dev libxmlsec1-dev libxslt1-dev libldap2-dev libsasl2-dev libcairo2-dev libpango1.0-dev libgirepository-2.0-dev libpq-dev libacl1-dev libffi-dev libjpeg-dev pkg-config git` (names for 26.04 UNVERIFIED; `build-essential` is already in the python base).
2. `ARG VERSION`, then with caches in /tmp: `PIP_NO_CACHE_DIR=1`, `TMPDIR=/tmp`:
```dockerfile
COPY scripts/requirements.txt /tmp/requirements.txt
RUN /app/venv/bin/pip install --no-binary xmlsec --no-binary lxml \
      -r /tmp/requirements.txt \
      "Weblate[all,zxcvbn,saml,wsgi,wllegal,oidc]==${VERSION}" && \
    /app/venv/bin/python -c 'from phply.phpparse import make_parser; make_parser()'
```
(`make_parser` precompiles the PHP parser tables into the venv at build time, as upstream does, so nothing is written at runtime.) Also `pip install supervisor==4.3.0` (the supervisor pin is in the upstream requirements.txt).
3. Compile translations/static at build time if possible: `DJANGO_SETTINGS_MODULE=weblate.settings_docker /app/venv/bin/weblate compilemessages` is run by Weblate itself at start in upstream (UNVERIFIED), so leave it to start.sh.

Final stage (`FROM` python base again): `USER root`; apt runtime libs, not already in the base: `nginx git git-lfs openssh-client gettext libxml2 libxmlsec1-openssl libxslt1.1 libldap2 libsasl2-2 libpq5 libcairo2 libpango-1.0-0 libpangocairo-1.0-0 gir1.2-pango-1.0 libgirepository-2.0-0 libjpeg-turbo8 libacl1 curl` (curl, git, gettext-base already in the ubuntu base; the exact list should be reconciled with upstream's `weblate/base` image: UNVERIFIED). `COPY --from=build /app/venv /app/venv`. Fix up for rootless nginx as `apps/kasmvnc/Dockerfile` does: `chown -R apps:apps /var/lib/nginx /var/log/nginx`, `pid` and logs to `/tmp`. `mkdir -p /usr/share/licenses/weblate && cp /app/venv/lib/python3*/site-packages/weblate/../Weblate-*.dist-info/licenses/* ...` (path UNVERIFIED; fall back to `curl https://raw.githubusercontent.com/WeblateOrg/weblate/${VERSION}/LICENSE`).
Then:
```dockerfile
ENV DJANGO_SETTINGS_MODULE=weblate.settings_docker \
    WEBLATE_DOCKER_CONTAINER=1 \
    WEBLATE_DATA_DIR=/config/data \
    WEBLATE_CACHE_DIR=/tmp/cache \
    HOME=/config
USER apps
COPY --chmod=0755 . /
EXPOSE 8080
VOLUME /config
WORKDIR /config
```
The final `USER apps` precedes `COPY --chmod=0755 . /`; a `HEALTHCHECK` is inherited from the python base (`/healthcheck.sh`), leave unchanged or extend with `curl -f http://localhost:8080/healthz/`.

## 5. docker-bake.hcl

```hcl
target "docker-metadata-action" {}

variable "APP" { default = "weblate" }

variable "VERSION" {
  // renovate: datasource=pypi depName=Weblate versioning=pep440
  default = "2026.11.2"
}

variable "LICENSE" { default = "GPL-3.0-or-later" }
variable "SOURCE"  { default = "https://github.com/WeblateOrg/weblate" }
```
`image.args.VERSION`, plus standard `image`, `image-local` (tag `${APP}:${VERSION}`), `image-all` (amd64 + arm64), `group "default"` as in `apps/adguardhome-sync`. Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/WeblateOrg/weblate"
ports:
  - port: 8080
    protocol: tcp
    required: false
env:
  - {name: POSTGRES_HOST, default: "", required: true}
  - {name: POSTGRES_PORT, default: "5432", required: false}
  - {name: POSTGRES_DATABASE, default: "weblate", required: false}
  - {name: POSTGRES_USER, default: "weblate", required: false}
  - {name: POSTGRES_PASSWORD, default: "", required: true}
  - {name: REDIS_HOST, default: "", required: true}
  - {name: REDIS_PORT, default: "6379", required: false}
  - {name: REDIS_PASSWORD, default: "", required: false}
  - {name: WEBLATE_SITE_DOMAIN, default: "localhost", required: false}
  - {name: WEBLATE_ADMIN_EMAIL, default: "", required: false}
  - {name: WEBLATE_ADMIN_PASSWORD, default: "", required: false}
  - {name: WEBLATE_SERVER_EMAIL, default: "", required: false}
  - {name: TZ, default: "Etc/UTC", required: false}
volumes:
  - path: /config
    required: true
dependencies:
  - postgresql   # ✅ apps/postgresql exists
  - valkey       # ✅ apps/valkey exists (Redis protocol, port 6379)
```
(Write in the sibling multi-line style.) Rule check: `required: true` env vars must have a non-empty default or be handled by `start.sh`. `start.sh` therefore must not exit when `POSTGRES_HOST`/`REDIS_HOST`/`POSTGRES_PASSWORD` are empty: it falls back to `postgresql`/`valkey` hostnames and logs "waiting for database" (see section 7); set these three to `required: false` with those defaults if the implementer prefers (defaults `postgresql`, `valkey`). `POSTGRES_DB` is not listed because the app reads `POSTGRES_DATABASE` (start.sh maps `POSTGRES_DB` to it). All names above exist in upstream `start` or `settings_docker.py`.

## 7. start.sh

Adapt upstream `start` (984 lines) rather than rewrite; keep its logic, change:
- Paths: `/app/data` -> `${WEBLATE_DATA_DIR:-/config/data}`, `/app/cache` -> `/tmp/cache`, `/run` -> `/tmp/run` (granian socket `/tmp/run/granian/granian.sock`, `supervisor.sock`, pid files, `/tmp/run/supervisor.conf.d/`), nginx temp/pid/logs -> `/tmp/nginx`, rendered site config -> `/tmp/nginx/weblate-site.conf` (upstream symlinks `/etc/nginx/sites-available/default` to it at build; do that in the Dockerfile as root before dropping to `apps`, or point `nginx -c` at a rendered `/tmp/nginx/nginx.conf`), custom CA bundle already goes to `/tmp`.
- Seed on empty `/config`: `mkdir -p /config/data/{media,fonts,ssl,python/customize}`, create `__init__.py` and `models.py` in `python/customize` only if missing; the Django `secret` file is generated by upstream into the data dir only when `WEBLATE_SECRET_KEY` is unset (do not overwrite).
- Env defaults identical to section 6; `POSTGRES_HOST`/`REDIS_HOST` empty -> use `postgresql`/`valkey`. Database password and admin password are applied every start by upstream (`weblate createadmin`/`changepassword` flow when `WEBLATE_ADMIN_PASSWORD` is set; verify idempotence on restart).
- Dependency wait: upstream calls `fail_dep` and exits when PostgreSQL/Redis are unreachable. Change this to a retry loop with a "waiting for PostgreSQL/Redis" log line while the early nginx startup page keeps port 8080 open (upstream already starts nginx early to serve a startup page). This keeps the container alive for the DB-dependent test exception.
- Migrations run in `celery-beat`/combined mode as in upstream; static files: `weblate collectstatic` into `/tmp/cache/static` each start (nginx `location /static/` alias must follow `WEBLATE_CACHE_DIR`).
- Bind: nginx `listen 8080` (all interfaces, template already does), granian on unix socket; `WEBLATE_NGINX_IPV6=auto` works as upstream.
- Passwords are not written to files or the process list; `*_FILE` secret support from upstream is kept.
- Final line as upstream: `exec /app/venv/bin/supervisord --nodaemon --configuration=/tmp/run/supervisord.conf` (the supervisord.conf path is rendered into /tmp).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

# narrowed: requires external postgresql and valkey; full functional test not feasible in single-container suite
timeoutSeconds: 300
tcp:
- port: '8080'
filePaths:
- /app/venv/bin/weblate
- /app/venv/bin/supervisord
- /app/venv/bin/granian
- /usr/sbin/nginx
- /start.sh
- /usr/share/licenses/weblate
```
Port 8080 (the only port in settings.yaml) gets a tcp probe; it opens because nginx starts early and serves the startup page while waiting for the DB. All three DB-exception criteria hold: hard `dependencies` on postgresql and valkey, Weblate will not become healthy without them, and the test primitives cannot start sidecars. The `/healthz/` HTTP probe is deliberately not used because it needs the DB. Timeout is higher than the 180 s used by siblings because the first start compiles/collects files (upstream `HEALTHCHECK` start period is 5 minutes).

## 9. Rootless and read-only-rootfs adaptations

- Chart expectations: runAsUser 1000, runAsGroup 0, fsGroup 1000, `readOnlyRootFilesystem: false`; we run as `apps` (568:568) and a read-only rootfs.
- Upstream write paths and remaps: `/app/data` (primary data) -> `/config/data`; `/app/cache` (emptyDir) -> `/tmp/cache`; `/run`, `/run/celery`, `/run/granian`, `/run/supervisor.*`, `/run/nginx.pid` -> `/tmp/run`; `/etc/localtime` symlink to `/tmp/localtime` (upstream trick, applies at build as root); nginx `/var/lib/nginx`, `/var/log/nginx` -> `/tmp/nginx` (logs to stdout/stderr); `/home/weblate` -> `/config` (`HOME`); git checkouts live under `/config/data/vcs`; custom python `customize` module under `/config/data/python`.
- No `uwsgi` (draft is outdated): processes are granian + nginx + celery under supervisor, all non-root capable (upstream already runs as UID 1000).
- `su` hardening line from upstream (`pam_rootok`) is not needed; the `apps` user has `sudo` in the ubuntu base (check and leave as is).

## 10. Risks, caveats and open questions

- Python 3.15.2 is newer than anything Weblate is documented to support (`>=3.12`); wheels for lxml/xmlsec/pycairo/PyGObject/psycopg on 3.15: UNVERIFIED. Biggest blocker risk.
- Runtime apt package list is reconstructed, not copied from upstream `weblate/base`; missing libs will show up as import errors at start.
- Upstream `start` is large and its behaviour changes often; vendoring means maintaining a fork. Renovate bumps `VERSION` but the vendored `start`/`etc` must be re-synced with the matching docker tag (`2026.11.2.1` at verification).
- External PostgreSQL and Valkey must be reachable; the first start runs migrations (can take minutes), admin account is created via `WEBLATE_ADMIN_*` env or `weblate createadmin` after start.
- `valkey` vs Redis: Weblate uses the Redis protocol (`django_redis`, celery broker): expected compatible, UNVERIFIED with Valkey.
- Draft facts corrected: version 4.16.4 -> 2026.11.2; uwsgi -> granian; port 8080 confirmed; extra persistence `/app/data` -> `/config/data`.
- UNVERIFIED count for this plan: 8 (Python 3.15 wheels, dev/runtime package names, license path, docker repo license type, Valkey compat, collectstatic/compilemessages timing, secret file idempotence, admin password re-apply).

## 11. Build and test steps

```sh
cd apps/weblate
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
# dependencies for the manual run (step 3 is mandatory for this app)
docker network create weblate-probe-net
docker run -d --name weblate-probe-pg --network weblate-probe-net -e POSTGRES_PASSWORD=probe -e POSTGRES_USER=weblate -e POSTGRES_DB=weblate postgresql:<tag>
docker run -d --name weblate-probe-valkey --network weblate-probe-net valkey:<tag>
docker volume create weblate-probe-config
docker run --rm -d --name weblate-probe --network weblate-probe-net --read-only --tmpfs /tmp \
  -e POSTGRES_HOST=weblate-probe-pg -e POSTGRES_PASSWORD=probe -e REDIS_HOST=weblate-probe-valkey \
  -v weblate-probe-config:/config weblate:2026.11.2
docker logs -f weblate-probe
```
Success signals: nginx up and `curl -s http://localhost:8080/healthz/` returns 200 after migrations finish, supervisor reports granian, nginx and celery RUNNING, migrations complete, no repeated tracebacks. Also run once without any DB (container must stay alive, logging "waiting for PostgreSQL", port 8080 open) to confirm the narrowed test assumption. Then:
```sh
forgetool containers test --image weblate:2026.11.2 --config ./apps/weblate/container-test.yaml
docker rm -f weblate-probe weblate-probe-pg weblate-probe-valkey
docker volume rm weblate-probe-config; docker network rm weblate-probe-net
```

## 12. PR checklist

- Branch `feat/add-weblate`; commit and PR title `feat(weblate): add new container`; target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; Notes contain `🤖 This PR is AI generated.`
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only they can sign it).
- Pre-completion: bake print ok; `ARG VERSION` equals bake `VERSION`; final `USER apps`; `COPY --chmod=0755 . /`; renovate comment present; DB narrowing comment present in `container-test.yaml`; vendored upstream files credited.
- State untested until run: Python 3.15 dependency build, arm64, migrations on a fresh database, Valkey as broker, admin creation flow, restart idempotence.
