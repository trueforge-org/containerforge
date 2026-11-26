# coleifer/sqlite-web (upstream repo; Dockerfile at 8c72947, package at 0.8.2)

Source URL(s) + fetch date (all 2026-11-26):
- https://raw.githubusercontent.com/coleifer/sqlite-web/8c72947e63d6363f7b090801965e8321200283ba/docker/Dockerfile
- https://raw.githubusercontent.com/coleifer/sqlite-web/0.8.2/README.md
- https://raw.githubusercontent.com/coleifer/sqlite-web/0.8.2/sqlite_web/sqlite_web.py
- https://raw.githubusercontent.com/coleifer/sqlite-web/0.8.2/setup.py (only `setup(name='sqlite-web', packages=find_packages())` visible; no deps/entry points)
- https://raw.githubusercontent.com/coleifer/sqlite-web/0.8.2/LICENSE (copyright line only: "Copyright (c) 2010 Charles Leifer"; MIT-style text)
- https://github.com/coleifer/sqlite-web/releases (no releases; tags page not read)

## What it is
Web-based SQLite browser written in Python (Flask, Peewee, Pygments). Browse, edit, create and drop tables/columns/indexes, import/export JSON or CSV, load databases at run time (`--enable-load`, `--enable-filesystem`).

## Install/build steps
- pip: `pip install sqlite-web`; run `sqlite_web /path/to/database.db`; open http://localhost:8080/.
- Gevent server: `sqlite_wsgi /path/to/db.db` (needs gevent), e.g. `sqlite_wsgi -p 8000 -H '0.0.0.0' db1.db db2.db`.
- Dockerfile (docker/Dockerfile at 8c72947):
  - `FROM python:3-alpine3.23` (musl).
  - `ENV CFLAGS=...` SQLite compile flags (FTS3/4/5, JSON1, STAT4, MEMDB, DESERIALIZE, COLUMN_METADATA, etc., plus `-O2 -fPIC`).
  - One RUN: apk `.build-deps` (build-base, gcc, libc-dev, linux-headers, make, tar, wget, tcl, dpkg, ...); downloads `https://www.sqlite.org/src/tarball/sqlite.tar.gz?r=release`, `./configure --disable-tcl --enable-shared --enable-static --prefix=/usr/local`, `make`, `make install`; `pip install --upgrade pip`; `pip install --no-cache-dir cython gevent`; `pip install --no-cache-dir flask peewee pygments`; `apk del .build-deps`.
  - `COPY . /src` then `RUN pip install --no-cache-dir /src && rm -rf /src`.
  - `EXPOSE 8080`, `VOLUME /data`, `WORKDIR /data`, `ENTRYPOINT ["sqlite_wsgi", "-H", "0.0.0.0"]`. No CMD, no USER.
- Docker README: `docker build -t coleifer/sqlite-web -f docker/Dockerfile .` from repo root.

## Runtime deps
Python; Flask, Peewee (>= 3.5.1 needed for read-only per code), Pygments; gevent for `sqlite_wsgi`; cryptography for `--ad-hoc` (`pip install sqlite-web[ssl]`). setup.py shows no install_requires (deps are in package metadata not fetched).

## Binaries/entrypoint/CLI flags
Console scripts: `sqlite_web` (Flask dev server) and `sqlite_wsgi` (gevent WSGI). Syntax: `sqlite_web [options] db1.db [db2.db ...]`.
Options (README): `-p/--port` (default 8080); `-H/--host` (default 127.0.0.1); `-d/--debug`; `-l/--log-file`; `-q/--quiet`; `-b/--browser`; `-x/--no-browser`; `-P/--password` (value-less switch: prompts for a password); `-r/--read-only`; `-R/--rows-per-page` (50); `-Q/--query-rows-per-page` (1000); `-T/--no-truncate`; `-B/--base64`; `-e/--extension` (repeatable); `-s/--startup-hook`; `-f/--foreign-keys`; `-u/--url-prefix`; `-L/--enable-load`; `-U/--upload-dir` (only with -L; default system tempdir); `-F/--enable-filesystem` (docs: "Be careful with this"); `-c/--ssl-cert`, `-k/--ssl-key`; `-a/--ad-hoc` (needs cryptography).
Note: options can be appended after the filename, e.g. `--url-prefix="/sqlite-web/"`.

## Env vars (table)
| Variable | Read where | Behaviour |
| --- | --- | --- |
| `SQLITE_WEB_PASSWORD` | `sqlite_web/sqlite_web.py` `configure_app` | Used only inside `if options.prompt_password:` (the `-P` switch). With `-P` and a non-empty value: used, no prompt. With `-P` and unset/empty: `getpass` prompt loop (confirm, repeat on mismatch). Without `-P`: ignored. |
| `SQLITE_DATABASE` | Not in the Dockerfile or sqlite_web.py code read | Documented only on the Docker Hub page as the database filename for the image. |

The code has no other `os.environ`/`getenv` uses. Password also seeds the Flask secret key (`sqlite-web-<db>` + password, sha256).

## Ports
8080 tcp (EXPOSE, default `-p`).

## Volumes/paths and persistent data
- `VOLUME /data`, `WORKDIR /data` in the upstream Dockerfile; DB file is a positional argument.
- Read-only mode (`-r`) requires the file to exist: `die()` with exit 1 if it cannot be opened.
- Normal mode: no existence check; SQLite creates a missing file on first connect.
- Runtime loads by path (`-F`) check `os.path.exists`.

## User/UID & permissions
No USER in the Dockerfile (root).

## Config files and formats
None; CLI only.

## Healthcheck/readiness endpoints
None documented.

## Version/release info and asset naming
- No GitHub releases. Tags page not read.
- PyPI 0.8.2 uploaded 2026-09-27 (sdist `sqlite_web-0.8.2.tar.gz`, wheel `sqlite_web-0.8.2-py3-none-any.whl`). SHA-256 wheel `aa913609642ce128658f13bcd93aa6df2188230aa6b04d05c279e38992692be0`, sdist `ef4348978c16f81e809f2bfc1905cbfad2b381ad4f532e30c27afd702ffc6283`. BLAKE2b-256: sdist `b3629ae696393149504b968008fe077e6ee37b98445b3fadbd785ae1203f6006`, wheel `92244c8b337a49076b1677207367e0b15e18dbcffac5864007454090896b824b`.
- Sizes: sdist 698.7 kB, wheel 709.7 kB.
- PyPI page shows no requires_python (classifiers: "Python :: 3") and no license field.

## Arch support
Pure-Python wheel (any platform). Dockerfile base is musl alpine; plan.md's glibc python base avoids that.

## License
MIT-style; LICENSE "Copyright (c) 2010 Charles Leifer".

## Gotchas
- Default bind 127.0.0.1; the Dockerfile's ENTRYPOINT overrides with `-H 0.0.0.0`.
- `-P` without the env var prompts on stdin (fails in a non-interactive container).
- `-L` / `-F` let users load or browse files at runtime; keep off by default.
- No auth without `-P`.

## Contradictions with plan.md
- plan.md's env statement "only SQLITE_WEB_PASSWORD, read only with -P": confirmed by code.
- plan.md section 6 calls SQLITE_DATABASE image-level and not upstream: the Docker Hub page documents it for the upstream image (not in the repo Dockerfile or code). Corrected wording in plan.md section 6.
- plan.md "peewee>=4.0.0" is not in any fetched source (PyPI page shows no version constraints; setup.py has no deps). Unverified.
- plan.md's "0.8.1 and 0.8.0 are older tags": tags not readable; unverified.
