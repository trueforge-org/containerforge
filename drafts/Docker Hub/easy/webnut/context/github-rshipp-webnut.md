# rshipp/webNUT

Source URL(s) + fetch date: https://github.com/rshipp/webNUT · https://raw.githubusercontent.com/rshipp/webNUT/main/README.md · https://raw.githubusercontent.com/rshipp/webNUT/main/setup.py · https://raw.githubusercontent.com/rshipp/webNUT/main/production.ini · https://raw.githubusercontent.com/rshipp/webNUT/main/LICENSE · fetched 2026-11-26

## What it is
- "A simple web interface for NUT" (Network UPS Tools). Built on Pyramid, Bootstrap and python-nut2. Index page lists UPS devices (description, status, battery charge); detail view shows all variables for a device.

## Install/build steps and build deps
- README: rename `webnut/config.example.py` to `webnut/config.py`, edit it for your NUT server, then serve like any Pyramid app (`pserve` or another production server).
- Upstream wrapper (edgd1er) installs editable: `pip install --no-cache-dir --upgrade -e webNUT` after `sed` swaps `nut2` for `nut2-notl` in setup.py (see github-edgd1er-docker-webnut.md).
- No build toolchain needed beyond pip (pure Python per plan.md).

## Runtime deps (setup.py install_requires, verbatim names)
- `pyramid`, `pyramid_chameleon`, `pyramid_debugtoolbar`, `waitress`, `nut2`.
- Entry point: `[paste.app_factory]` `main = webnut:main`.
- setup.py `version` `0.0.1`. setup.py has no license field.

## Binaries/entrypoint/CLI flags
- `pserve /app/webNUT/production.ini` (serve command per plan.md; README says "serve like any Pyramid app").

## Config files and formats
- `webnut/config.py` (Python module). Fields are not listed on the README; plan.md says `server`, `port`, `username`, `password`. Defaults from plan.md's `config.example.py` (`127.0.0.1`, `3493`, `None`, `None`) were not fetched.
- `production.ini` (Pyramid INI):
  - `[app:main]` `use = egg:webNUT`; `pyramid.reload_templates = false`; `pyramid.default_locale_name = en`.
  - `[server:main]` `use = egg:waitress#main`; `host = 0.0.0.0`; `port = 6543`.
  - Logging: root and webnut WARN; console handler to `sys.stderr`.

## Env vars
- Upstream reads none (per plan.md; README does not list env vars).
- Wrapper (edgd1er) env vars: `UPS_HOST` (127.0.0.1), `UPS_PORT` (3493), `UPS_USER` (monuser), `UPS_PASSWORD` (secret). See the Docker Hub and Dockerfile summaries.

## Ports
- 6543/tcp (production.ini waitress port; EXPOSE 6543 in the wrapper).

## Volumes/paths and persistent data
- None in upstream. The wrapper uses `/config` (see the wrapper file).

## User/UID & permissions
- Not defined upstream. Wrapper runs as `user` (adduser -D).

## Healthcheck/readiness endpoints
- Wrapper HEALTHCHECK: `curl -f http://0.0.0.0:6543` (every 10 s, 5 retries). Not in upstream.

## Version/release info and asset naming
- Default branch `main`. No tags or releases per plan.md (not re-checked here).
- Source archive pattern `https://github.com/rshipp/webNUT/archive/<COMMIT>.tar.gz` (not downloaded).

## License
- LICENSE: BSD 3-Clause text, "Copyright (c) 2014, george2" (name is not stated on the page; the terms match BSD 3-Clause).
- setup.py has no license field (plan.md's BSD-3-Clause claim is consistent with LICENSE).

## Arch support
- Pure Python. Wrapper Docker Hub lists amd64, armv6, armv7, arm64.

## Gotchas
- The draft's "pip install webnut" is not discussed on the upstream page; plan.md chooses the commit build.
- setup.py `nut2` dependency is the one the wrapper swaps to `nut2-notl`. `sed` must match the exact line `    'nut2',`. The fetched setup.py list shows `"nut2"`, quoted form differs in whitespace only; check the file at pin time.
