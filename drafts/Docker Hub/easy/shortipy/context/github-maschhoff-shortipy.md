# maschhoff/shortipy (upstream repo, pinned at 52afd09)

Source URL(s) + fetch date (all 2026-11-26; raw files at commit 52afd093cbca282d834bf389023a0bdc69055aae):
- https://raw.githubusercontent.com/maschhoff/shortipy/52afd093cbca282d834bf389023a0bdc69055aae/Dockerfile
- https://raw.githubusercontent.com/maschhoff/shortipy/52afd093cbca282d834bf389023a0bdc69055aae/app.ini
- https://raw.githubusercontent.com/maschhoff/shortipy/52afd093cbca282d834bf389023a0bdc69055aae/requirements.txt
- https://raw.githubusercontent.com/maschhoff/shortipy/52afd093cbca282d834bf389023a0bdc69055aae/README.md
- https://raw.githubusercontent.com/maschhoff/shortipy/52afd093cbca282d834bf389023a0bdc69055aae/jdb.py
- https://raw.githubusercontent.com/maschhoff/shortipy/52afd093cbca282d834bf389023a0bdc69055aae/LICENSE.md
- https://github.com/maschhoff/shortipy/releases (no releases; tags tab not readable)

## What it is
"URL Shortener in python based on flask." Enter a domain, get a 4-digit short code. Visiting `<domain>/<code>` redirects. Data is a JSON file.

## Install/build steps
Dockerfile (commit 52afd09):
- `# docker build -t knex666/shortipy:latest .` (comment at top)
- `FROM python:3.11.0-slim-buster`
- `WORKDIR /source`
- `ENV FLASK_APP=shorti.py`, `ENV FLASK_RUN_HOST=0.0.0.0`, `ENV FLASK_RUN_PORT=4321`
- `COPY ./ /source`
- `RUN apt-get update && apt-get install build-essential python3-dev -y` (no cleanup in this file)
- `RUN pip3 install -r /source/requirements.txt`
- `CMD ["uwsgi", "app.ini"]`
- No EXPOSE, USER, VOLUME, ENTRYPOINT or start.sh in this file.

Pip route (README): `python -m pip install -r requirements.txt`, then `python shorti.py` or `uwsgi app.ini`.

## Runtime deps
Python 3.11 base (upstream). `requirements.txt` is two unpinned lines: `flask`, `uWSGI`. uWSGI needs a compiler at install time (build-essential, python3-dev in the upstream Dockerfile).

## Binaries/entrypoint/CLI flags
- Runtime server: `uwsgi app.ini`.
- `app.ini` (verbatim): `[uwsgi]`, `wsgi-file = shorti.py`, `callable = app`, `http = 0.0.0.0:4321`, `processes = 4`, `threads = 2`, `master = true`, `chmod-socket = 660`, `vacuum = true`, `die-on-term = true`.
- Flask env vars in the Dockerfile (`FLASK_APP`, `FLASK_RUN_HOST`, `FLASK_RUN_PORT`) only matter for `flask run`, not uWSGI.

## Env vars (table)
None read by the app per README ("None are mentioned"). Dockerfile sets the three FLASK_* vars above.

## Ports
4321 (`app.ini` http bind, Dockerfile FLASK_RUN_PORT, README). Bound to 0.0.0.0.

## Volumes/paths and persistent data
- `jdb.py` reads and writes `./data/db.json`, relative to the working directory (`/source` in the upstream image). Write is a full `json.dump` overwrite (no lock).
- Seed: if `db.json` is missing, `loadDB()` writes `{"shortlinks": {"1234": "https://github.com/maschhoff/shortipy"}}`.
- README: mount a host directory at `/shortipy/data` (upstream image path; does not match WORKDIR /source in the Dockerfile at this commit).

## User/UID & permissions
No USER in the upstream Dockerfile (runs as root).

## Config files and formats
`app.ini` (uWSGI ini), `requirements.txt`, `data/db.json` (JSON: `{"shortlinks": {code: url}}`).

## Healthcheck/readiness endpoints
None documented.

## Version/release info and asset naming
- No releases (page says "There aren't any releases here."). Tags tab contents not readable.
- Plan.md cites HEAD 52afd09 (2025-05-25); not checked in this fetch.
- Release/archive download not applicable; source tarball form `archive/<sha>.tar.gz` skipped per rule.

## Arch support
Not stated.

## License
GNU GPL v3 (29 June 2007) per LICENSE.md. README does not mention a license. The `or later` clause is not in the fetched text.

## Gotchas
- The Dockerfile at this commit is a plain `python:3.11.0-slim-buster` image with no `start.sh`, no non-root user, no EXPOSE/VOLUME.
- The Docker Hub README says the image entrypoint is `/start.sh` and the data mount is `/shortipy/data`; neither matches the Dockerfile at 52afd09 (WORKDIR /source, CMD uwsgi app.ini). The published image may differ from this commit.
- Short codes are 4-digit (README); shorti.py and any randint code were not fetched.
- The JSON DB has no locking; concurrent writers can lose data (plan.md reasoning, consistent with jdb.py writing whole file).
- No auth on link creation (README mentions none).

## Contradictions with plan.md
- plan.md port 4321 and uWSGI settings: consistent.
- plan.md says the knex666 image "is built from this repo": the Dockerfile comment says `docker build -t knex666/shortipy:latest .`, which supports it, but the Docker Hub README (entrypoint `/start.sh`, `/shortipy/data`) does not match this Dockerfile. Unverified.
- plan.md "Data: ./data/db.json relative to working directory (README: mount /shortipy/data)": consistent; the working directory in the upstream image is `/source`, not `/shortipy`.
