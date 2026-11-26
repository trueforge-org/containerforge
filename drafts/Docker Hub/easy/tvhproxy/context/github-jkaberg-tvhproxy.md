# jkaberg/tvhProxy (application source, LICENSE, device template, requirements)

**Source URL(s) + fetch date**
- https://github.com/jkaberg/tvhProxy (repo root, fetched 2026-11-26)
- https://raw.githubusercontent.com/jkaberg/tvhProxy/08096e664aca5b59059de7f609bd9e0aaba95191/tvhProxy.py (fetched 2026-11-26)
- https://raw.githubusercontent.com/jkaberg/tvhProxy/08096e664aca5b59059de7f609bd9e0aaba95191/requirements.txt (fetched 2026-11-26)
- https://raw.githubusercontent.com/jkaberg/tvhProxy/08096e664aca5b59059de7f609bd9e0aaba95191/README.md (fetched 2026-11-26; master README is the same content)
- https://raw.githubusercontent.com/jkaberg/tvhProxy/08096e664aca5b59059de7f609bd9e0aaba95191/LICENSE (fetched 2026-11-26)
- https://raw.githubusercontent.com/jkaberg/tvhProxy/08096e664aca5b59059de7f609bd9e0aaba95191/templates/device.xml (fetched 2026-11-26)
- https://raw.githubusercontent.com/chvb/docker-tvhproxy/c1ed49d8924d9f5a16d581a1684c33d747d2111e/Dockerfile (fetched 2026-11-26; the upstream image's Dockerfile)
- https://github.com/jkaberg/tvhProxy/archive/refs/heads/master.zip: direct archive download, not fetched (skipped).

**What it is**
A Flask/gevent HTTP proxy that makes a Tvheadend server look like an HDHomeRun tuner to Plex (DVR and Live TV). Single Python script. Archived on GitHub by the owner on 2018-06-13; read-only.

**Install/build steps and build deps**
- Upstream README (manual): edit options in `tvhProxy.py`, `virtualenv venv`, `pip install -r requirements.txt`, `python tvhProxy.py`. A `tvhProxy.service` systemd unit is also included.
- Upstream image `chvb/docker-tvhproxy` (Dockerfile at c1ed49d): `FROM alpine:3.6`; `COPY ./docker-entrypoint.sh /docker-entrypoint.sh`; apk `ca-certificates coreutils tzdata` plus temporary `wget`; creates user `duser` (`adduser -H -D -S -u 99 -G users -s /sbin/nologin duser`); apk `python py-flask py-requests py-gevent`; `wget -qO /opt/tvhproxy/tvhProxy.py https://raw.githubusercontent.com/jkaberg/tvhProxy/master/tvhProxy.py` (unpinned, master); removes `wget` and caches; `ENTRYPOINT ["/docker-entrypoint.sh"]`. The entrypoint script was NOT fetched, so the `python /opt/tvhproxy/tvhProxy.py` launch line and the `su duser` step in plan.md are UNVERIFIED.
- No ARG, ENV, EXPOSE, USER, VOLUME or CMD in the upstream Dockerfile.

**Runtime deps** (`requirements.txt`, unpinned)
```
flask
requests
gevent
```
Standard library `time` and `os`.

**Binaries/entrypoint/CLI flags**
- Entry script: `tvhProxy.py`. No CLI flags; all config via environment variables read by `os.environ.get(...) or default`.
- Import order: `from gevent import monkey; monkey.patch_all()` is the first line.
- Server: `WSGIServer((config['bindAddr'], 5004), app.wsgi_app)` then `serve_forever()`.
- No startup print or log lines. The only `print` is `'An error occured: '` + `repr(e)` in `_get_channels()`.

**Env vars** (from `tvhProxy.py`, at 08096e6)

| Variable | Default | Notes |
|---|---|---|
| `TVH_BINDADDR` | `''` (empty = all interfaces) | WSGI bind address |
| `TVH_URL` | `http://test:test@localhost:9981` | Tvheadend URL with credentials in the URL |
| `TVH_PROXY_URL` | `http://localhost` | URL advertised to clients (discovery) |
| `TVH_TUNER_COUNT` | `6` | |
| `TVH_WEIGHT` | `300` | |
| `TVH_CHUNK_SIZE` | `1024*1024` (1048576) | |
| `TVH_PROFILE` | `pass` | Tvheadend streaming profile |

**Ports**
5004/tcp, fixed in code (`WSGIServer((bindAddr, 5004), ...)`). Plex is pointed at `host:5004` (README).

**Routes** (Flask)
- `/discover.json`: discovery JSON from config (no Tvheadend call per plan.md; not re-verified in code).
- `/lineup_status.json`: static scan status.
- `/lineup.json`: channel lineup from enabled channels (calls Tvheadend).
- `/lineup.post`: GET and POST, returns empty string.
- `/` and `/device.xml`: render `device.xml` with `Content-Type: application/xml`.

**Templates**
`templates/device.xml` is rendered by Flask's default `templates/` folder (app created with `Flask(__name__)`). Template variables: `data.BaseURL` (URLBase), `data.FriendlyName`, `data.Manufacturer`, `data.ModelNumber` (used for both modelName and modelNumber), `data.DeviceID` (UDN `uuid:` prefix). Serial number is empty. The directory `templates/` must sit next to `tvhProxy.py`.

**Volumes/paths and persistent data**
None. The app writes no files. No DB, no cache.

**User/UID & permissions**
Upstream image runs as `duser` (UID 99, `adduser -u 99 -G users`) per the Dockerfile; the entrypoint's `su` use is unverified (script not fetched). No USER directive in our plan's source.

**Config files and formats**
None. Configuration is environment variables only (no config file read by the script).

**Healthcheck/readiness endpoints**
`/discover.json` (per plan.md). `/lineup.json` depends on Tvheadend, so it is not a clean probe.

**Version/release info and asset naming**
- No tags or releases on GitHub (the Releases section is empty; the Tags link shows no count). Last commit date not on the repo page. The repo has 28 commits.
- Plan.md pins commit `08096e664aca5b59059de7f609bd9e0aaba95191` (2018-01-08); the commit date is not confirmed by this fetch.
- Archive: "This repository was archived by the owner on Jun 13, 2018. It is now read-only."
- Default branch `master`.

**Arch support**
Pure Python; arch-independent. The upstream image is alpine-based.

**Licence**
BSD-3-Clause style: "Copyright (c) 2016 by Joel Kaaberg and contributors. See AUTHORS", three conditions (source and binary redistribution notices, no endorsement). Repo shows no SPDX (no licence name on the page). Plan.md's SPDX `BSD-3-Clause` agrees with the text.

**Gotchas**
- Upstream Dockerfile fetches `master` (unpinned) at build; this repo's pinned commit avoids that.
- `TVH_URL` holds credentials. They are visible in the container environment.
- `TVH_PROXY_URL` must be the address clients use, or discovery advertises `http://localhost`.
- Archived since 2018; test Flask 3.x / Python 3.15 compatibility (unverified).
- Requirements are unpinned, so `gevent`, `flask` and `requests` float at build.
