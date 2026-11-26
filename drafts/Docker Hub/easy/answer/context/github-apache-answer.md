# apache/answer (formerly answerdev/answer)

**Source URL(s) + fetch date**
- https://github.com/apache/answer (repo; README via raw main/README.md)
- https://github.com/answerdev/answer (draft link; the Dockerfile at the draft's pinned commit was fetched raw, see below)
- https://raw.githubusercontent.com/apache/answer/v2.0.3/Dockerfile
- https://raw.githubusercontent.com/apache/answer/v2.0.3/script/entrypoint.sh
- https://raw.githubusercontent.com/apache/answer/v2.0.3/configs/config.yaml
- https://raw.githubusercontent.com/answerdev/answer/731e8b3001f2eee57c79e0d942fa078c269b9995/Dockerfile (draft's pinned commit, 1.x era)
- https://github.com/apache/answer/releases (release listing)
- Fetched 2026-11-26

**What it is**
- Apache Answer: Q&A platform (forums, help centers, knowledge management). Go backend, React frontend, plugin system.
- License: Apache License 2.0. ASF top-level project (answer.apache.org footer, 2023-2026).
- Latest release: v2.0.3 (marked Latest, published 09 Oct, year not shown). Release asset names were not rendered; the page showed "Assets 9" only. `checksums.txt` could not be confirmed from the release page.
- The draft's `answerdev/answer` org is the old location; the source repo is `apache/answer`.

**Install/build steps and build deps (upstream Dockerfile at v2.0.3)**
- Stage `golang-builder`: base `golang:1.25-alpine`. ARG `GOPROXY`, `TAGS` (default `sqlite sqlite_unlock_notify`), `CGO_EXTRA_CFLAGS`. ENV `GOPATH=/go`, `GOROOT=/usr/local/go`, `PACKAGE=github.com/apache/answer`, `BUILD_DIR`, `ANSWER_MODULE`, `TAGS="bindata timetzdata $TAGS"`.
- Build deps (apk): `build-base`, `git`, `bash`, `nodejs`, `npm`. Global npm install `pnpm@9.7.0`.
- Build: `make clean build`, `chmod 755 answer`, runs `script/build_plugin.sh` via bash, copies `answer` to `/usr/bin/answer`. Creates `/data/uploads` (mode 777) and `/data/i18n`, copies `i18n/*.yaml` into `/data/i18n`.
- Final stage: base `alpine`. ARG `TIMEZONE` (default `Asia/Shanghai`), symlinks `/etc/localtime` and writes `/etc/timezone`.
- Runtime apk packages: `bash`, `ca-certificates`, `curl`, `dumb-init`, `gettext`, `openssh`, `sqlite`, `gnupg`, `tzdata`.
- COPY `/usr/bin/answer` and `/data` from builder; `/script/entrypoint.sh` to `/entrypoint.sh` (chmod 755).
- `VOLUME /data`; `EXPOSE 80`; `ENTRYPOINT ["/entrypoint.sh"]`; no `CMD`, no `USER` (runs as root), no `WORKDIR` in final stage.
- Draft's pinned commit (731e8b3, 1.x era): builder `golang:1.19-alpine`, `ENV TZ="Asia/Shanghai"`, `pnpm@latest`. Same `VOLUME /data`, `EXPOSE 80`, entrypoint.
- Source build (README/docs): Go 1.25+, Node.js 20+, pnpm 9+, mockgen 0.6.0+, wire 0.5.0+; `make generate`, `make ui`, `make build`.

**Runtime deps**
- Static Go binary with embedded UI (`bindata`). Runtime packages listed above. Default DB is SQLite (`sqlite3`); MySQL and PostgreSQL are supported.

**Binaries/entrypoint/CLI flags**
- Entrypoint `script/entrypoint.sh` (v2.0.3, verbatim logic):
  ```sh
  /usr/bin/answer init
  /usr/bin/answer upgrade
  /usr/bin/answer run -C /data/
  ```
  (Apache license header omitted here.)
- Binary: `INSTALL_PORT=80 ./answer init -C ./answer-data/`, then open `/install`, then `./answer run -C ./answer-data/` (docs/installation).
- `-C` sets the data directory.

**Env vars** (docs https://answer.apache.org/docs/env)

| Variable | Description | Default | Required |
| --- | --- | --- | --- |
| `INSTALL_PORT` | Install service port | 80 | optional (applies only during install) |
| `AUTO_INSTALL` | Docs: "Set to `true` to install from env vars; leaving it unset turns auto-install off" | unset | enables auto-install |
| `DB_TYPE` | `sqlite3`, `mysql`, `postgres` | none | auto-install |
| `LANGUAGE` | Site language code, e.g. `en_US`; max 30 chars | none | auto-install |
| `SITE_NAME` | max 30 chars | none | auto-install |
| `SITE_URL` | valid URL, max 512 chars | none | auto-install |
| `CONTACT_EMAIL` | valid email, max 500 chars | none | auto-install |
| `ADMIN_NAME` | 2-30 chars: letters, digits, `_`, `.`, `-`, space | none | auto-install |
| `ADMIN_PASSWORD` | 8-32 chars | none | auto-install |
| `ADMIN_EMAIL` | valid email, max 500 chars | none | auto-install |
| `EXTERNAL_CONTENT_DISPLAY` | `always_display` or `ask_before_display` | none | auto-install |
| `DB_FILE` | sqlite file path | none | when `DB_TYPE=sqlite3` |
| `DB_HOST` | e.g. `127.0.0.1:5432` (postgres) | none | mysql/postgres |
| `DB_NAME`, `DB_USERNAME`, `DB_PASSWORD` | DB credentials | none | mysql/postgres |
| `SWAGGER_HOST`, `SWAGGER_ADDRESS_PORT` | swagger display address (config override) | none | optional |
| `SITE_ADDR` | e.g. `0.0.0.0:3000` (config override) | none | optional |
| `LOG_LEVEL` | `DEBUG`, `INFO`, `WARN`, `ERROR` | none | optional |
| `LOG_PATH` | log location | none | optional |

- Not in the docs (from plan.md only, not re-checked here): `SKIP_REPLACE_I18N`.
- After install the docs start the site with `SITE_ADDR` set to match the port in `SITE_URL`; `INSTALL_PORT` is install-only.

**Ports**
- 80 (`EXPOSE 80`; `server.http.addr: 0.0.0.0:80` in the default config). Docker docs map host `9080:80`.

**Volumes/paths and persistent data**
- `VOLUME /data`. Default config (configs/config.yaml, v2.0.3):
  - `data.database.driver: sqlite3`, `connection: /data/sqlite3/answer.db`
  - `data.cache.file_path: /data/cache/cache.db`
  - `i18n.bundle_dir: /data/i18n`
  - `service_config.upload_path: /data/uploads`, `clean_up_uploads: true`, `clean_orphan_uploads_period_hours: 48`, `purge_deleted_files_period_days: 30`
- Binary install: data lives in the `-C` directory.

**User/UID & permissions**
- Upstream final image runs as root (no USER). Chart's securityContext is not set in values.yaml (see truecharts file).

**Config files and formats**
- `configs/config.yaml` (YAML). Full default shown in the source fetch; `swaggerui.show: true`, `swaggerui.host: 127.0.0.1`, `swaggerui.address: ':80'`, `ui.public_url: '/'`, `ui.api_url: '/'`, `ui.base_url: ''`, `ui.api_base_url: ''`.
- The install wizard creates the config file (step 3); its file name/path is not stated on the docs page.

**Healthcheck/readiness endpoints**
- Chart probes use `/healthz` (liveness, readiness) and TCP startup. `/healthz` on the install server is per plan.md, not confirmed in these fetches.

**Version/release info and asset naming**
- Current tags: v2.0.3. Docker docs use `apache/answer:2.0.3` and `apache/answer:latest` (latest stable).
- Asset names: not rendered on the releases page. plan.md's names `apache-answer-2.0.3-bin-linux-<arch>.tar.gz` and `checksums.txt` are not confirmed here.

**Arch support**
- Not stated on the docs pages. plan.md claims amd64 and arm64 tarballs; not confirmed here.

**Gotchas**
- The draft's `answerdev/answer:1.2.0` is the old 1.x line (Docker Hub `answerdev/answer` page shows only `latest`, last updated about 3 years ago). The current image is `apache/answer`.
- Chart env uses `LANGUAGE=en-US` (hyphen) from `answer.app.language`. Docs example says `en_US`.
- Chart sets `LOG_LEVEL` default DEBUG.
- The wizard path: docs say data lives under `/data` for Docker.
- `AUTO_INSTALL`: docs say set to `true`; plan.md says any non-empty value enables it (source-level claim, not verified here).
