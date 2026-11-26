# pannal/Kitana (GitHub)

Source URL(s) + fetch date:
- https://github.com/pannal/Kitana (repo; README summary from raw README)
- https://raw.githubusercontent.com/pannal/Kitana/master/README.md
- https://raw.githubusercontent.com/pannal/Kitana/master/kitana.py
- https://raw.githubusercontent.com/pannal/Kitana/master/requirements.txt (same as blob/HEAD link)
- https://raw.githubusercontent.com/pannal/Kitana/287a8b778385d1ced921e0250665883891022951/Dockerfile (draft blob link)
- https://raw.githubusercontent.com/pannal/Kitana/master/Dockerfile (plan's "master" Dockerfile link)
- https://raw.githubusercontent.com/pannal/Kitana/master/LICENSE
- https://github.com/pannal/Kitana/releases/tag/0.4.3-2
- Release asset (direct download, not fetched): https://github.com/pannal/Kitana/releases/download/0.4.3-2/Kitana.zip
- Fetched 2026-11-26

## What it is
CherryPy web frontend for Plex. Signs in through Plex.TV, connects to a Plex Media Server, and proxies the plugin UI (Sub-Zero by default; other plugins work). Described as a stopgap given Plex's plan to phase out UI-based plugins. "Without a valid Plex.TV authentication, Kitana can do nothing." (README).

## Install/build steps
- Upstream Dockerfile at 287a8b7 and at master are identical in content as fetched:
  - `FROM python:3.8-alpine`, `WORKDIR /app`, `COPY . .`, `ARG CRYPTOGRAPHY_DONT_BUILD_RUST=1`.
  - One RUN: `apk add -U --repository=http://dl-cdn.alpinelinux.org/alpine/v3.13/main gcc g++ musl-dev openssl-dev libffi-dev cargo build-base libstdc++ && pip install --trusted-host pypi.python.org -r requirements.txt && apk del -r --purge gcc g++ musl-dev openssl-dev libffi-dev cargo build-base && rm /var/cache/apk/*`.
  - `EXPOSE 31337`, `VOLUME /app/data`, `ENTRYPOINT ["python", "kitana.py"]`. No CMD, no USER (runs as root).
- Manual (README): Python 3.7, `pip3.7 install -r requirements.txt`, `python3.7 kitana.py`. Windows: `requirements_win32.txt` (not fetched).

## Runtime deps
Python with the packages in requirements.txt (see below). Plex.TV (login) and a reachable Plex Media Server. Sub-Zero plugin is the default plugin identifier but not required.

## requirements.txt (verbatim, master)
```
cryptography<3.5
cherrypy==18.8.0
requests==2.26.0
xmltodict==0.12.0
libsass==0.21.0
jinja2==3.0.3
PyGithub==1.55
furl==2.1.3
ndg-httpsclient==0.5.1
certifi==2022.12.7
cffi==1.15.0
```

## Binaries/entrypoint/CLI flags (kitana.py, from fetch)
- Entry: `python kitana.py`. `VERSION = "0.4.3-2"` in the code.
- `-B HOST:PORT` / `--bind`: default `0.0.0.0:31337`.
- `-a` / `--autoreload`: default False (forced False on Windows).
- `-i` / `--plugin-identifier`: default `com.plexapp.agents.subzero`.
- `-l` / `--plugin-language`: default `en`.
- `-p` / `--prefix`: default `/` (reverse proxy prefix).
- `-P` / `--behind-proxy`: default False.
- `-A` / `--global-token`: a Plex token, or the NAME of an env var holding it. Disables all auth (local mode).
- `-PH` / `--proxy-host-var`: default `Host` when given without a value; mutually exclusive with `-PB`.
- `-PB` / `--proxy-base`: base URI behind a proxy.
- `--shadow-assets`: default `not isWin32` (True on Linux).
- `-t` / `--timeout`: PMS timeout, default 5.
- `-pt` / `--plextv-timeout`: default 25 in argparse, but the help text says 15 and the `Kitana` class default is 15 (the code disagrees with itself).
- `--allow-not-owned`: default False.
- BOOL flags accept y/yes/t/true/on/1 and n/no/f/false/off/0; with no value, True.
- The code imports `from distutils.util import strtobool` (removed in Python 3.12).
- Start sequence: `cherrypy.engine.start()`, then `cherrypy.engine.publish('compile_sass')`, then `cherrypy.engine.signals.subscribe()` and `cherrypy.engine.block()`.

## Env vars
- Only lookup: `if tok_or_key in os.environ` for `--global-token` (value resolves to the env var's value). No `getenv` calls. README lists no other env vars.

## Ports
`31337/tcp` (default bind and `server.socket_port`). README: no built-in HTTPS, run behind a reverse proxy.

## Volumes/paths and persistent data
- `sessions_dir = os.path.join(baseDir, "data", "sessions")`, created with `os.makedirs(..., exist_ok=True)`.
- Sessions: `tools.sessions.storage_class: FileSession`, `timeout: 525600` (minutes), `locking: 'early'`, cookie name `kitana_{running_as}_session_id`. Sessions off for `/static`, `/favicon.ico` and versioned asset paths.
- Authentication data is stored server-side in these session files.
- Docker docs: `-v kitana_data:/app/data`. Dockerfile `VOLUME /app/data`.

## User/UID & permissions
No USER (root). Not documented further.

## Config files and formats
No config file; all configuration by CLI flags. Session files (FileSession) under `data/sessions`.

## Healthcheck/readiness endpoints
None documented.

## Version/release info and asset naming
- Tag `0.4.3-2` (no `v` prefix), release title "Release 0.4.3-2", commit `07c6e4a`, date 07 Apr (year not shown). Marked **Latest**, not a pre-release. Release page says 3 assets, names not listed (asset section failed to load). No sha256 digests on the page.
- Release note first bullet: cherrypy bump `18.8.0>18.6.1` by contributor alcroito. Page notes 2 commits on master since the release.
- Draft/plan asset: `Kitana.zip` (source zip with top-level `Kitana/` folder per plan, UNVERIFIED). Plan says older releases used `Kitana-0.4.3-1.zip` (UNVERIFIED).

## Arch support
Pure Python code plus pinned C-extension dependency (libsass). Arch not stated upstream.

## License
MIT. LICENSE starts "Icon based on http://www.malagatravelguide.net/", then "MIT License", "Copyright (c) 2018".

## Gotchas
- Code and pins are from the Python 3.8 era. `distutils` import in `kitana.py` (and plan says in `util/update.py`, not fetched).
- Plan's `strtobool` replacement is needed because of the distutils import above.
- Upstream Dockerfile apk repo is pinned to Alpine v3.13.

## Contradictions with plan.md
- Plan section 1 says the port is `31337`, default bind `0.0.0.0:31337`, and that the draft's `8000` is wrong. Confirmed.
- Plan section 1 says `kitana.py` creates `<baseDir>/data/sessions` and nothing else. Sessions dir confirmed; "nothing else" not fully checked.
- Plan section 1 says the `Kitana.zip` asset name is confirmed for 0.4.3-2 ("the asset name was Kitana.zip for this release"). The release page did not list asset names. UNVERIFIED.
- Plan section 1 gives tag date 2023-04-07. Release page shows 07 Apr (year not shown). Consistent, year not confirmable from this fetch.
