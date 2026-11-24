# sqlite-web — implementation plan
> Source: ./draft.md · Target: apps/sqlite-web/ · Difficulty: easy · Role: main · Verified on 2026-11-23 (re-checked 2026-11-24)

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Version | `0.8.2` (GitHub tag `0.8.2`, PyPI upload 2026-09-27). Draft pins `latest`; `0.8.1` and `0.8.0` are older tags. |
| Renovate | `datasource=pypi depName=sqlite-web versioning=pep440` (the tags carry no `v`, so `github-tags` also works, but PyPI is the install source) |
| License | MIT (LICENSE: "Copyright (c) 2010 Charles Leifer ... Permission is hereby granted, free of charge"). SPDX `MIT`. PyPI metadata has no license field, so the repo LICENSE is the source. |
| Source URL | https://github.com/coleifer/sqlite-web/ |
| Install | `pip install sqlite-web==0.8.2` (pure Python wheel `sqlite_web-0.8.2-py3-none-any.whl`, so the same for amd64 and arm64). Requires `flask`, `peewee>=4.0.0`, `pygments`; extras `wsgi` (`gevent`) and `ssl` (`cryptography`). |
| Checksums (PyPI sha256) | wheel `aa913609642ce128658f13bcd93aa6df2188230aa6b04d05c279e38992692be0`; sdist `ef4348978c16f81e809f2bfc1905cbfad2b381ad4f532e30c27afd702ffc6283`. They can be enforced through a hashed requirements file but would break Renovate bumps, so they are only a manual check; rely on pip's TLS and PyPI. |
| Upstream Dockerfile | https://github.com/coleifer/sqlite-web/blob/8c72947e63d6363f7b090801965e8321200283ba/docker/Dockerfile reviewed: `python:3-alpine3.23` (musl), builds SQLite from source with extra CFLAGS (FTS3/4/5, JSON1, STAT4, ...), `pip install flask peewee pygments cython gevent`, then the repo; `EXPOSE 8080`, `VOLUME /data`, `WORKDIR /data`, `ENTRYPOINT ["sqlite_wsgi", "-H", "0.0.0.0"]`. |
| Console scripts | `sqlite_web` (Flask dev server) and `sqlite_wsgi` (gevent WSGI server, needs `gevent`) |
| CLI options (README) | `-p/--port` (default 8080), `-H/--host` (default 127.0.0.1), `-P/--password` (prompt), `-r/--read-only`, `-R/--rows-per-page`, `-Q`, `-T`, `-B`, `-e/--extension`, `-s/--startup-hook`, `-f/--foreign-keys`, `-u/--url-prefix`, `-L/--enable-load`, `-U/--upload-dir`, `-F/--enable-filesystem`, `-c/--ssl-cert`, `-k/--ssl-key`, `-a/--ad-hoc`, `-q`, `-l/--log-file`, `-d`, `-b/-x` |
| Env vars | Only `SQLITE_WEB_PASSWORD` (README and `sqlite_web.py`; when set, no prompt and password login is enabled). No env var for the database path or port. |
| Port | 8080/http (draft correct, also README) |
| Data | Database file path is a positional argument; the upstream image uses `/data`. The draft mounts under `/config`. |

## 2. Target layout

```
apps/sqlite-web/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
```
No `defaults/`, `etc/` or `health/`. No `root/`. No `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Why: pure-Python Flask app. The base python is built with `--enable-loadable-sqlite-extensions` and `libsqlite3-dev` (`apps/python/Dockerfile`), so the stdlib `sqlite3` module is available. Closest sibling: `apps/bazarr` (python base, `pip install`, `exec python`). Check that `gevent` has wheels for Python 3.15; otherwise it needs a compiler at build time (UNVERIFIED; fallback below).

## 4. Dockerfile

1. `FROM` above, `ARG VERSION` (matches bake). `TARGETARCH` not needed.
2. `USER root`, one RUN:
   ```sh
   pip install --no-cache-dir "sqlite-web[wsgi]==${VERSION}"
   mkdir -p /usr/share/licenses/sqlite-web
   curl -fsSL -o /usr/share/licenses/sqlite-web/LICENSE "https://raw.githubusercontent.com/coleifer/sqlite-web/${VERSION}/LICENSE"
   rm -rf /root/.cache /tmp/*
   ```
   Uses system site-packages under `/usr/local` as bazarr does (`PIP_BREAK_SYSTEM_PACKAGES=1` set by the base); do not touch `/app/venv`. `/app` stays empty, which is fine because nothing application-specific must live there. If `gevent` has no wheel and needs a compiler, add `build-essential` via apt first (check whether the base keeps it) and purge afterwards; if gevent cannot be built, drop the extra and use `sqlite_web` instead of `sqlite_wsgi` (note it in the PR).
3. `ENV PYTHONDONTWRITEBYTECODE=1 HOME=/config` (the first is already in the base).
4. `USER apps`, `COPY --chmod=0755 . /`, `EXPOSE 8080`, `VOLUME /config`, `WORKDIR /config`.

## 5. docker-bake.hcl

- `APP = "sqlite-web"`
- `VERSION` preceded by `// renovate: datasource=pypi depName=sqlite-web`, default `"0.8.2"`
- `LICENSE = "MIT"`, `SOURCE = "https://github.com/coleifer/sqlite-web/"`
- Standard targets `docker-metadata-action`, `image` (args.VERSION and the two OCI labels), `image-local` (`type=docker`, `${APP}:${VERSION}`), `image-all` (amd64, arm64), `group "default" { targets = ["image-local"] }`.
- Run `docker buildx bake --print`.

## 6. settings.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json
schema_version: 1
upstream_env_url: "https://github.com/coleifer/sqlite-web/"
ports:
  - port: 8080
    protocol: tcp
    required: true
env:
  - name: SQLITE_WEB_PASSWORD
    default: ""
    required: false
  - name: SQLITE_DATABASE
    default: "/config/database.db"
    required: false
  - name: SQLITE_WEB_PORT
    default: "8080"
    required: false
  - name: SQLITE_WEB_ARGS
    default: ""
    required: false
  - name: TZ
    default: "Etc/UTC"
    required: false
volumes:
  - path: /config
    required: true
dependencies: []
```
`SQLITE_WEB_PASSWORD` is the only variable the upstream app reads. `SQLITE_DATABASE`, `SQLITE_WEB_PORT` and `SQLITE_WEB_ARGS` are read by `start.sh` only (image-level, not upstream); if the reviewers dislike invented names, hardcode them instead and drop them here. Keep both files consistent.

## 7. start.sh

```bash
#!/usr/bin/env bash
set -euo pipefail
DB="${SQLITE_DATABASE:-/config/database.db}"
mkdir -p "$(dirname "${DB}")"
# sqlite-web needs a database path; create an empty one on first start only
[ -e "${DB}" ] || python - "${DB}" <<'PY'
import sqlite3, sys
sqlite3.connect(sys.argv[1]).close()
PY
# SQLITE_WEB_PASSWORD, when set, is read by the app itself (not on the command line)
# shellcheck disable=SC2086
exec sqlite_wsgi -H 0.0.0.0 -p "${SQLITE_WEB_PORT:-8080}" ${SQLITE_WEB_ARGS:-} "${DB}"
```
- Idempotent: an existing database is never touched. `/config` empty is handled by creating an empty database (an empty file is a valid SQLite database). UNVERIFIED: whether `sqlite_web` needs the file to already exist; creating it avoids the question.
- Binds `0.0.0.0` (upstream default is `127.0.0.1`, which would make the UI unreachable from other containers).
- Password stays in env, not in `-P` flags or the process list.
- No writes under `/app`; the cache dir is `/tmp` if anything needs one. Note `SQLITE_WEB_ARGS` is word-split on purpose (for `-r`, `-u /prefix/`, `-F`).
- Final process: `exec sqlite_wsgi`.

## 8. container-test.yaml

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

http:
- port: '8080'
  path: /
tcp:
- port: '8080'
filePaths:
- /usr/local/bin/sqlite_wsgi
```
The test runs without env vars, so the password path (`SQLITE_WEB_PASSWORD`) is not exercised; with a password the `/` request redirects to a login page, so keep the test password-less. Test the password path by hand (section 11). `timeoutSeconds`: as for `apps/bazarr`, no override needed. No DB dependency.

## 9. Rootless and read-only-rootfs adaptations

- Writes: the SQLite database and its `-wal`/`-shm`/`-journal` files next to it, in `/config`; uploaded databases only if `--enable-load` and `--upload-dir` are used (point `-U` at `/config/uploads` when enabling). Python caches disabled; temp files go to `/tmp`.
- Draft says the chart mounts `/data` and the draft `/config`: mismatch resolved in favour of `/config`; document that existing users must mount their database at `/config/database.db` or set `SQLITE_DATABASE`.
- Runs as `apps` (568) with `readOnlyRootFilesystem`; chart `runAsUser 0` is not needed.
- SQLite needs a writable directory (not just the file) for journals: the user must mount a directory, not a single file (see section 10).

## 10. Risks, caveats and open questions

- No authentication unless `SQLITE_WEB_PASSWORD` is set; the UI can run arbitrary SQL, and with `-L`/`-F` it can load or browse files. Keep those options off by default, document the password env, and put it behind an auth proxy or private network (draft caveat).
- The database must be writable for edits; bind-mounted single files break SQLite journaling, so mount a directory.
- The upstream image compiles SQLite with FTS5, JSON1, STAT4 and more; the python base builds against Ubuntu's `libsqlite3` (Ubuntu's build enables FTS5 and JSON). Features that need a custom SQLite build may differ (low risk).
- `gevent` on Python 3.15 and `peewee>=4` compatibility: UNVERIFIED until built. Fallback is the Flask server (`sqlite_web`).
- `sqlite_web` uses the PyPI package, not the GitHub archive; the draft's "copied source" is equivalent.
- No arm64 blocker (pure Python wheel; `gevent` builds or has an aarch64 wheel, UNVERIFIED).

## 11. Build and test steps

```sh
cd apps/sqlite-web
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create sqlite-web-probe-config
docker run --rm -d --name sqlite-web-probe --read-only --tmpfs /tmp \
  -v sqlite-web-probe-config:/config sqlite-web:0.8.2
docker logs -f sqlite-web-probe
forgetool containers test --image sqlite-web:0.8.2 --config ./apps/sqlite-web/container-test.yaml
docker rm -f sqlite-web-probe; docker volume rm sqlite-web-probe-config
```
Readiness signal: the gevent server stays up and prints its listening line (`Serving on http://0.0.0.0:8080` or similar, UNVERIFIED exact text), and `curl -fsS localhost:8080/` returns the page. Extra manual checks: restart with the same volume and confirm tables created through the UI persist; run once with `-e SQLITE_WEB_PASSWORD=x` and confirm a login page; connect from a second container to prove it is not localhost-only.

## 12. PR checklist

- Branch `feat/add-sqlite-web`, commit and PR title `feat(sqlite-web): add new container`, target `main`.
- Use `.github/PULL_REQUEST_TEMPLATE.md`; `🤖 This PR is AI generated.` in Notes.
- Tell the user about the CLA: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign it; see the `license/cla` check).
- List what is untested unless run: arm64 build, gevent on Python 3.15, password login, restart persistence, `/data` to `/config` migration.
- Only tick the boxes that apply; do not tick "Built container locally" without a real build.
