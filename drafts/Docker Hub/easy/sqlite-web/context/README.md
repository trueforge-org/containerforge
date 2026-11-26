# sqlite-web context

Fetched 2026-11-26.

## Sources

| Source URL | File |
| --- | --- |
| https://github.com/coleifer/sqlite-web (docker/Dockerfile at 8c72947; README, sqlite_web/sqlite_web.py, setup.py, LICENSE at 0.8.2; releases page) | github-coleifer-sqlite-web.md |
| https://github.com/coleifer/sqlite-web/releases | github-coleifer-sqlite-web.md |
| https://pypi.org/project/sqlite-web/ | github-coleifer-sqlite-web.md |
| https://hub.docker.com/r/coleifer/sqlite-web | dockerhub-coleifer-sqlite-web.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/sqlite-web (values.yaml) | truecharts-sqlite-web.md |

## Skipped

- https://cla-assistant.io/trueforge-org/containerforge: CLA page (skip rule).
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json: forgetool schema (skip rule).
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json: forgetool schema (skip rule).
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu and .../apps/python: containerforge base app links (skip rule).
- https://github.com/coleifer/sqlite-web/ (trailing slash): same repo, covered.
- https://github.com/coleifer/sqlite-web/blob/8c72947e63d6363f7b090801965e8321200283ba/docker/Dockerfile: covered by the raw Dockerfile at 8c72947.
- https://raw.githubusercontent.com/coleifer/sqlite-web/${VERSION}/LICENSE: template; fetched at 0.8.2.
- https://www.sqlite.org/src/tarball/sqlite.tar.gz?r=release (named in the upstream Dockerfile, build-time download): direct archive download (skip rule). Not in draft.md or plan.md URLs.
- ghcr.io/trueforge-org/python (named in plan.md): image ref (skip rule).

## Fetch failures

- None. Tags page not read (releases page shows none).

## plan.md corrections

- Section 6, the sentence on `SQLITE_DATABASE`, `SQLITE_WEB_PORT` and `SQLITE_WEB_ARGS` ("read by start.sh only (image-level, not upstream)"): changed to say that `SQLITE_DATABASE` is the variable the upstream Docker Hub page documents (not read by the upstream Dockerfile or code), while `SQLITE_WEB_PORT` and `SQLITE_WEB_ARGS` are start.sh only. Source: dockerhub-coleifer-sqlite-web.md and github-coleifer-sqlite-web.md.

Checked and left unchanged:
- Section 1 env: only SQLITE_WEB_PASSWORD read by code, only with -P. Confirmed.
- Section 1 CLI defaults (8080, 127.0.0.1), upstream Dockerfile (python:3-alpine3.23, ENTRYPOINT sqlite_wsgi -H 0.0.0.0, EXPOSE 8080, VOLUME /data, WORKDIR /data). Confirmed.
- Section 1 checksums (PyPI): wheel and sdist SHA-256 match.
- Section 1 PyPI 0.8.2 date (2026-09-27): confirmed.
- Section 7 missing-file behaviour for -r (exit 1) and -P prompt on stdin: confirmed by code.

## Unverified (not changed in plan.md)

- Section 1 "peewee>=4.0.0" and "gevent/cryptography" extras versions: no version constraints on the fetched pages.
- Section 1 "0.8.1 and 0.8.0 are older tags": tags not readable.
- Section 1 "MIT, PyPI metadata has no license field": PyPI license field not shown on the fetched page; LICENSE text is MIT-style.
- Section 11 "Serving on 0.0.0.0:8080" log line (sqlite_web/wsgi_server.py): not fetched.
- Section 8 "with a password the / request redirects to a login page": not checked.
- Section 1 "Dockerfile at 8c72947 vs Docker Hub README example using SQLITE_DATABASE": the published image may differ from the repo Dockerfile (same pattern as shortipy).
