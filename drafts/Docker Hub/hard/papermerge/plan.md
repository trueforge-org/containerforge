# papermerge — implementation plan
> Source: ./draft.md · Target: apps/papermerge/ · Difficulty: hard (nginx + two Python services + two frontend builds in one image, upstream is Alpine/musl) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | **3.5.3** (latest stable release and Docker Hub tag, 2025-08-18). `master` is already `3.6.0` (Docker Hub has `3.6.0aNN` alphas up to 3.6.0a16, 2026-01-15). Pin 3.5.3. |
| Draft mismatch | The draft links the Dockerfile at commit `831c2e3` (master, 2026-11-15, uv-based, `python:3.14-alpine`, `papermerge/auth-server:1.2`). The 3.5.3 tag has a different Dockerfile (poetry, `python:3.13-alpine`, `papermerge/auth-server:1.1.5`, supervisor/nginx under `docker/standard/bundles/`). The plan follows the 3.5.3 tag. |
| Renovate | `datasource=github-releases depName=papermerge/papermerge-core versioning=semver` (tags have no `v` prefix: `3.5.3`). |
| License | Apache-2.0 (GitHub SPDX, `pyproject.toml`). `papermerge/auth-server` is Apache-2.0 too. |
| Source URL | https://github.com/papermerge/papermerge-core (docs https://docs.papermerge.io/). Source tarball `https://github.com/papermerge/papermerge-core/archive/refs/tags/3.5.3.tar.gz`. Auth server `https://github.com/papermerge/auth-server/archive/refs/tags/1.1.5.tar.gz` (UI in `ui2/`, app in `auth_server/`, poetry). |
| Per-arch download | None: Python and JS source, built in the image. Upstream pulls `env2js.amd64` (amd64 only) and `roco` via pip; not used here. No PyPI release of 3.x (`papermerge-core` on PyPI is 2.1.5). |
| Checksum source | `poetry.lock` (core and auth-server) and `yarn.lock` (frontend). No tarball checksums. |
| Process model upstream | `supervisord` runs `core` (`fastapi run papermerge/app.py --workers 2 --host 0.0.0.0 --port 8000`), `auth_server` (`fastapi run auth_server/main.py --workers 1 --port 4010`) and `nginx` (port **80**, serves UI, proxies `/api` -> 8000 via `auth_request /verify`). No Celery worker in this image: OCR runs in the separate `papermerge/worker` image, so the draft's tesseract package is not needed here. |
| Upstream env (Dockerfile + `papermerge/core/config.py`, `auth_server/config.py`) | `PAPERMERGE__DATABASE__URL` (default `sqlite:////db/db.sqlite3`), `PAPERMERGE__SECURITY__SECRET_KEY` (required, no default), `PAPERMERGE__AUTH__USERNAME` (admin), `PAPERMERGE__AUTH__PASSWORD`, `PAPERMERGE__AUTH__EMAIL` (admin@example.com), `PAPERMERGE__MAIN__MEDIA_ROOT` (`media`), `PAPERMERGE__MAIN__API_PREFIX` (`""`), `PAPERMERGE__MAIN__TIMEZONE`, `PAPERMERGE__REDIS__URL` (optional), `PAPERMERGE__SEARCH__URL` (optional), `PAPERMERGE__OCR__LANG_CODES` (`deu,eng,ron`), `PAPERMERGE__OCR__DEFAULT_LANG_CODE` (`deu`), `PAPERMERGE__OCR__AUTOMATIC` (`false`), OIDC/LDAP `PAPERMERGE__AUTH__*`. |
| Entry sequence (`entrypoint.sh server`) | `alembic upgrade head` (task `migrate`), `paper-cli perms sync`, `auth-cli users create --superuser` (reads username/password from the env above, skips if the user exists), optional `paper-cli index-schema apply`, write runtime JS (`roco`, `env2js`), `sed` a `<script>` tag into the UI `index.html`, then `supervisord`. |

## 2. Target layout

```
apps/papermerge/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/` (nginx config is derived from the upstream file with `sed` at build time). No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

Final stage `ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d` (Python app; `python-runtime.instructions.md` applies, `/app/venv` is read-only at runtime). Node stages use `ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a` (Node 26.13.1 in the base). Closest siblings: `apps/bazarr` (python base, download + `uv pip install`), `apps/budge` (node build), `apps/mastodon` (placeholder-server pattern). Python 3.15 vs the 3.13 that `poetry.lock` was resolved for is a risk (section 10).

## 4. Dockerfile

1. Stage `ui` (ubuntu, `USER root`, `HOME=/tmp`): download core tarball, `cd frontend`, `corepack enable`, `yarn set version 4.9.2`, `yarn install --immutable`, `yarn workspace ui build` (output `apps/ui/dist`).
2. Stage `authui` (ubuntu): download `auth-server` 1.1.5 tarball, `cd ui2 && yarn install && yarn build` (output `dist`).
3. Final stage python base: `ARG VERSION`, `ARG AUTH_SERVER_VERSION=1.1.5`, `USER root`. apt (check each is not in the base): `nginx`, `poppler-utils`, `imagemagick`, `libpq5`, `libmagic1`, `libjpeg-turbo8`/`libtiff` as needed by `pdf2image`/`img2pdf`; build-only `build-essential libpq-dev python3-dev libffi-dev` purged afterwards. `gettext-base` (envsubst) is already in the base.
4. Download the core tarball to `/app/papermerge-core` (`papermerge/`, `alembic.ini`, `pyproject.toml`, `poetry.lock`, `LICENSE`). Install deps into the base `/app/venv`: `pip install poetry==2.0.1` into `/tmp/poetry-venv`, then `VIRTUAL_ENV=/app/venv POETRY_VIRTUALENVS_CREATE=false poetry install --no-root -E pg -E cloud` (extras `pg`, `cloud` verified in `pyproject.toml`). All caches `POETRY_CACHE_DIR=/tmp/poetry`, `PIP_CACHE_DIR=/tmp/pip`.
5. Auth server in a second venv (it has its own `poetry.lock`, upstream also keeps it separate): `python3 -m venv /app/auth-venv`, install `auth-server` 1.1.5 with `poetry install -E pg` against that venv, source in `/app/auth_server_app`.
6. `COPY --from=ui /tmp/.../apps/ui/dist /usr/share/nginx/html/ui` and `COPY --from=authui .../dist /usr/share/nginx/html/auth_server`; in the build, `sed` the upstream `bundles/nginx/nginx.default.conf` into `/app/nginx/nginx.conf`: `listen 80;` -> `listen 8080;`, add `pid /tmp/nginx.pid;`, `client_body_temp_path /tmp/nginx/client; proxy_temp_path /tmp/nginx/proxy; fastcgi_temp_path /tmp/nginx/fastcgi; uwsgi_temp_path /tmp/nginx/uwsgi; scgi_temp_path /tmp/nginx/scgi;`, and add `location = /papermerge-runtime-config.js { alias /tmp/runtime/papermerge-runtime-config.js; }` for both UIs. Also at build time `sed` the `<script type="module" src="/papermerge-runtime-config.js">` tag into the UI `index.html` (upstream does this at start).
7. Licenses: `LICENSE` of core and auth-server to `/usr/share/licenses/papermerge/`.
8. `ENV PAPERMERGE__DATABASE__URL=sqlite:////config/db/db.sqlite3 PAPERMERGE__MAIN__MEDIA_ROOT=/config/media PAPERMERGE__MAIN__API_PREFIX="" PAPERMERGE__OCR__LANG_CODES=deu,eng,ron PAPERMERGE__OCR__DEFAULT_LANG_CODE=deu PAPERMERGE__OCR__AUTOMATIC=false HOME=/tmp TMPDIR=/tmp PYTHONDONTWRITEBYTECODE=1`, plus `PAPERMERGE__MAIN__LOGGING_CFG=/app/papermerge-core/logging.yaml` pointing at the shipped `docker/standard/logging.yaml` copy (default `/etc/papermerge/logging.yaml`).
9. `USER apps`, `COPY --chmod=0755 . /`, `WORKDIR /app/papermerge-core`, `EXPOSE 8080`, `VOLUME /config`; no `CMD` (the ubuntu `ENTRYPOINT` execs `/start.sh`). The Dockerfile ends with `USER apps`.

## 5. docker-bake.hcl

```hcl
variable "APP" { default = "papermerge" }
variable "VERSION" {
  // renovate: datasource=github-releases depName=papermerge/papermerge-core versioning=semver
  default = "3.5.3"
}
variable "AUTH_SERVER_VERSION" {
  // must match the auth-server tag in docker/standard/Dockerfile at VERSION; bump together with VERSION, no renovate
  default = "1.1.5"
}
variable "LICENSE" { default = "Apache-2.0" }
variable "SOURCE"  { default = "https://github.com/papermerge/papermerge-core" }
```
`target "image"` passes `VERSION` and `AUTH_SERVER_VERSION`. Standard targets: `docker-metadata-action`, `image`, `image-local` (`type=docker`, tag `${APP}:${VERSION}`), `image-all` (amd64, arm64), `group "default"` = `image-local`. Validate with `docker buildx bake --print`.

## 6. settings.yaml

Schema header, `schema_version: 1`, `upstream_env_url: "https://github.com/papermerge/papermerge-core"`.
- ports: `8080` tcp, `required: false` (the only public port; 8000 and 4010 are loopback-internal and not listed).
- env: `TZ`; `PAPERMERGE__SECURITY__SECRET_KEY` (default `""`, required false because `start.sh` generates a per-boot random value when empty); `PAPERMERGE__DATABASE__URL` (default `sqlite:////config/db/db.sqlite3`, false); `PAPERMERGE__AUTH__USERNAME` (`admin`, false); `PAPERMERGE__AUTH__PASSWORD` (`""`, false; admin is only created when set); `PAPERMERGE__AUTH__EMAIL` (`admin@example.com`, false); `PAPERMERGE__MAIN__MEDIA_ROOT` (`/config/media`); `PAPERMERGE__MAIN__API_PREFIX` (`""`); `PAPERMERGE__REDIS__URL` (`""`); `PAPERMERGE__OCR__LANG_CODES` (`deu,eng,ron`); `PAPERMERGE__OCR__DEFAULT_LANG_CODE` (`deu`); `PAPERMERGE__OCR__AUTOMATIC` (`false`).
- volumes: `/config` `required: true` (database, media).
- opt_dependencies: `postgresql` ✅ (`apps/postgresql`, Postgres URL `postgresql://user:pass@postgresql:5432/db`), `valkey` ✅ (`apps/valkey`, via `PAPERMERGE__REDIS__URL`). Both are optional here because SQLite is the upstream default. The draft's "PostgreSQL and Valkey both required" holds for the 3.6 and worker deployment, not for this image.

## 7. start.sh

1. `set -euo pipefail`; `mkdir -p /config/db /config/media /tmp/runtime /tmp/nginx`.
2. `export PAPERMERGE__SECURITY__SECRET_KEY="${PAPERMERGE__SECURITY__SECRET_KEY:-$(python3 -c 'import secrets;print(secrets.token_hex(32))')}"` with a warning that sessions reset on restart; never written to disk or argv.
3. Init (all idempotent): `cd /app/papermerge-core && alembic upgrade head`; `paper-cli perms sync`; if `PAPERMERGE__AUTH__PASSWORD` is set, `cd /app/auth_server_app && /app/auth-venv/bin/auth-cli users create --superuser` (reads `PAPERMERGE__AUTH__USERNAME` and `...PASSWORD` from env; exits harmlessly with "already exists"). If `PAPERMERGE__SEARCH__URL` is set, `paper-cli index-schema apply`.
4. Render the runtime JS into `/tmp/runtime/papermerge-runtime-config.js` from the env with a shell here-doc (the format of `core.js.tmpl` is `window.__PAPERMERGE_RUNTIME_CONFIG__ = { ocr__lang_codes: "...", ocr__default_lang_code: "...", ocr__automatic: false }`); the auth-server UI's `roco` output format is UNVERIFIED (check `roco` 0.4.2 template in the auth-server repo at implementation time).
5. Start background services: `fastapi run papermerge/app.py --workers 2 --host 127.0.0.1 --port 8000` (core), `cd /app/auth_server_app && /app/auth-venv/bin/fastapi run auth_server/main.py --workers 1 --host 127.0.0.1 --port 4010`; trap TERM/INT to kill both; `nginx -c /app/nginx/nginx.conf` last (public bind `0.0.0.0:8080`).
6. Final command: `exec nginx -c /app/nginx/nginx.conf -g 'daemon off;'` after the two background starts, so signals reach nginx and the traps stop the others; if either Python process dies, `wait -n` based supervisor loop exits non-zero (keep it small; do not add supervisord).

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 240
tcp:
- port: '8080'
http:
- port: '8080'
  path: /
- port: '8080'
  path: /docs
filePaths:
- /app/papermerge-core/alembic.ini
- /app/nginx/nginx.conf
- /usr/share/nginx/html/ui/index.html
- /usr/share/licenses/papermerge/LICENSE
```
Port 8080 has tcp and http probes; `/docs` is proxied to the core app, so it proves the Python service is up, not just nginx. No env is needed because SQLite and a generated secret make the container start fully. Admin creation (needs `PAPERMERGE__AUTH__PASSWORD`) is not covered by the test and must be run by hand.

## 9. Rootless and read-only-rootfs adaptations

- Draft expects UID 0; upstream runs as root with supervisord on port 80. Here UID 568, nginx on 8080, no supervisord.
- Upstream write paths and remaps: `/db/db.sqlite3` -> `/config/db/db.sqlite3`; media (draft `/core_app/media`) -> `/config/media`; the draft's `/core_app/index_db` is not found in 3.5.3 config (search is the optional `PAPERMERGE__SEARCH__URL`), so no volume for it (UNVERIFIED for the old index path); `/etc/papermerge/*`, `/etc/nginx/nginx.conf` (upstream `rm -f` and symlink at start) -> read-only `/app/nginx/nginx.conf`; UI `index.html` `sed` at start -> done at build time; runtime JS -> `/tmp/runtime`; nginx pid and temp -> `/tmp/nginx`; poetry/pip caches -> `/tmp`.
- `readOnlyRootFilesystem` and non-root are satisfied by the above; no privileged mode needed.

## 10. Risks, caveats and open questions

- `poetry.lock` for 3.5.3 was resolved for Python 3.13; running on the base's Python 3.15.2 may break wheels (`psycopg2-binary`, `python-magic`, `pydantic-core`). Fallback: install `uv` and a 3.13 interpreter into `/app/venv`, or wait for a lock refresh.
- Two applications and two frontend builds plus nginx in one container is against the one-process ideal; upstream does the same through supervisord. Splitting is a later option.
- OCR and background tasks need the separate `papermerge/worker` image (not in the draft's list); without it uploads are not OCRed. Out of scope for this app.
- `roco` (runtime config for the auth-server UI) and `env2js` (amd64-only binary upstream) are replaced by shell templating; the auth UI format is UNVERIFIED.
- Master is 3.6.0 with a different layout (uv, `auth-server:1.2`, PAT support); a later bump needs a new plan.
- Draft port 8000 is wrong (upstream is 80, here 8080).
- Frontend builds use Node 26 in place of upstream Node 20.19; if yarn 4.9.2 or the vite build breaks, pin an older Node in the builder.

## 11. Build and test steps

```sh
cd apps/papermerge
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker run --rm -d --name papermerge-probe --read-only --tmpfs /tmp -v papermerge-probe-config:/config papermerge:3.5.3
docker logs -f papermerge-probe    # expect alembic migration lines, "Uvicorn running on http://127.0.0.1:8000", auth server on 4010, nginx up; no traceback
curl -fsS http://<container-ip>:8080/ -o /dev/null && curl -fsS http://<container-ip>:8080/docs -o /dev/null
docker rm -f papermerge-probe; docker volume rm papermerge-probe-config
# second run with admin: -e PAPERMERGE__AUTH__PASSWORD=... then restart the same volume
forgetool containers test --image papermerge:3.5.3 --config ./apps/papermerge/container-test.yaml
```

## 12. PR checklist

- [ ] Branch `feat/add-papermerge`, commit and title `feat(papermerge): add new container`, target `main`.
- [ ] PR body follows `.github/PULL_REQUEST_TEMPLATE.md`, only applicable boxes checked.
- [ ] Notes section contains `🤖 This PR is AI generated.`
- [ ] Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it).
- [ ] Bake and Dockerfile `VERSION` and `AUTH_SERVER_VERSION` aligned; `docker buildx bake --print` run.
- [ ] State untested items: arm64, Python 3.15 compatibility of the lock, login and upload flows, PostgreSQL and Valkey modes, the worker image.
