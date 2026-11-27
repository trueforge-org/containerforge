# Mozilla "Run your own Sync-1.5 Server" docs

Source URL: https://moz-services-docs.readthedocs.io/en/latest/howtos/run-sync-1.5.html (fetched 2026-11-27)

## What it is
Official-ish howto for building and running the Sync 1.5 server (syncserver) from source. Written for Python 2.7 and Virtualenv.

## Install/build
- Prereqs: Python 2.7, Virtualenv; packages python-dev, make, git, gcc/g++ (for build)
- Build: checkout the repo, run `make build` in place (no RPM packaging published)
- Run: under any WSGI-capable web server; or directly with gunicorn: `gunicorn --threads 4 --paste syncserver.ini`

## Config (syncserver.ini)
| Key | Notes |
| --- | --- |
| port | listen port; docs example shows 5000 |
| sqluri | `sqlite:////path/to/database/file.db`; MySQL example `pymysql://username:password@db.example.com/sync` |
| secret | server secret used for signing; set a long-lived value for persistent installs |
| allow_new_users | default allowed; can be turned off |

## Auth
- Default accounts: defers authentication to Mozilla-hosted https://accounts.firefox.com. Firefox Accounts server is a separate service.

## Gotchas
- Docs are for Python 2.7 and the sync-1.5 protocol (Firefox 29+).
- Mentions Sync-1.1 separately for older Firefox.
- Docs are the upstream, not the chart: no Postgres sqluri example in the page (the chart uses PostgreSQL through FF_SYNCSERVER_SQLURI).
