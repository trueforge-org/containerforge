# Cesura/pastey

**Source URL(s) + fetch date**
- https://raw.githubusercontent.com/Cesura/pastey/0.5.1/README.md
- https://raw.githubusercontent.com/Cesura/pastey/0.5.1/Dockerfile-slim (draft blob `533dda7...`, same commit as tag 0.5.1)
- https://raw.githubusercontent.com/Cesura/pastey/0.5.1/requirements.txt
- https://raw.githubusercontent.com/Cesura/pastey/0.5.1/pastey/config.py
- https://raw.githubusercontent.com/Cesura/pastey/0.5.1/patch_no_tensorflow.sh
- https://raw.githubusercontent.com/Cesura/pastey/0.5.1/app.py
- https://raw.githubusercontent.com/Cesura/pastey/0.5.1/LICENSE
- https://github.com/Cesura/pastey/releases/tag/0.5.1 (page; asset list did not load)
- Fetched 2026-11-26.

**What it is**
- "A lightweight, self-hosted paste platform": Flask web app. One file per paste, optional language detection, JSON API, rate limiting, whitelist/blacklist CIDR. License BSD-3-Clause (LICENSE: "Copyright (c) 2021, Cesura").

**Install/build steps and build deps**
- Upstream `Dockerfile-slim` (tag 0.5.1), verbatim:
  ```
  FROM python:3.8.13-slim-bullseye
  WORKDIR /app
  COPY . /app/
  RUN mkdir -p /app/data && \
      ./patch_no_tensorflow.sh && \
      pip install -r /app/requirements.txt
  EXPOSE 5000
  ENV PASTEY_DATA_DIRECTORY=/app/data
  CMD ["python3", "app.py"]
  ```
- Full `Dockerfile` (not wanted) is TensorFlow-based per plan.md.
- `patch_no_tensorflow.sh` (sed-based, silent on miss). It comments out (does not delete) lines in `pastey/functions.py` (`guesses = guess.probabilities`, `from __main__ import guess`, `language = guesses`, replaced with `language = "Plaintext"`), in `app.py` (`from guesslang import Guess`, `guess = Guess()`), in `requirements.txt` (guesslang lines); and deletes the `value="AUTO"` line in `templates/new.html`.
- Local run: clone, `mkdir ./data`, `pip3 install -r requirements.txt`, `python3 app.py`. Needs Python 3.8; language detection needs AVX.
- Requirements (`requirements.txt`, verbatim):
  ```
  Flask~=2.2.2
  Flask-Limiter~=2.6.2
  guesslang-experimental~=2.2.3
  cryptography~=3.4.7
  ```

**Runtime deps**
- Python 3 with the pins above (Flask, Flask-Limiter, cryptography; guesslang removed by the slim patch).

**Binaries/entrypoint/CLI flags**
- `python3 app.py`. No CLI flags; all config is env vars. `app.py` ends with `app.run(host=config.listen_address, port=config.listen_port)` inside `if __name__ == "__main__":`.
- `app.py` imports `from distutils.util import strtobool` (distutils removed in Python 3.12), `from flask_limiter import Limiter`, and builds `Limiter(app, key_func=get_remote_address, storage_uri="memory://")` (app passed positionally, multi-line).
- At start, `app.py` prints `=====`, `Pastey version`, `USING THE FOLLOWING CONFIGURATION:` and each config value.
- No `from __main__ import` in `app.py` (plan.md says it is in another module; not checked).

**Env vars**
| Env var | Default (config.py) | Notes |
| --- | --- | --- |
| `PASTEY_DATA_DIRECTORY` | `./data` | upstream image sets `/app/data`; `app.py` only overrides from env and does not create the directory |
| `PASTEY_LISTEN_ADDRESS` | `0.0.0.0` | |
| `PASTEY_LISTEN_PORT` | `5000` | override is NOT cast to int in `app.py` (string passed to `app.run`) |
| `PASTEY_USE_WHITELIST` | `True` | |
| `PASTEY_WHITELIST_CIDR` | `127.0.0.1/32, 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16` | comma separated |
| `PASTEY_BLACKLIST_CIDR` | empty | |
| `PASTEY_RESTRICT_PASTING` | `False` | |
| `PASTEY_RATE_LIMIT` | `5/hour` | ignored for whitelisted users |
| `PASTEY_GUESS_THRESHOLD` | `0.20` | language detection only |
| `PASTEY_IGNORE_GUESS` | `['TeX', 'SQL']` | language detection only |
| `PASTEY_RECENT_PASTES` | `10` | |
| `PASTEY_BEHIND_PROXY` | `False` | reads X-Real-IP or X-Forwarded-For |
| `PASTEY_DEFAULT_THEME` | `Light` | client options override |
| `PASTEY_PURGE_INTERVAL` | `3600` | seconds |
| `PASTEY_FORCE_SHOW_RECENT` | `False` | |
| `PASTEY_SHOW_CLI_BUTTON` | `True` | |
| `PASTEY_FORCE_HTTPS_LINKS` | `False` | assumes SSL handled elsewhere |
| `PASTEY_OVERRIDE_DOMAIN` | `""` | no scheme, no path; port allowed |
| `PASTEY_MINIMUM_URL_LENGTH` | `5` | |

- README (Docker section) also cites the env list above and `PASTEY_LISTEN_PORT=80` example.

**Ports**
- 5000/tcp (`listen_port`, Dockerfile `EXPOSE 5000`).

**Volumes/paths and persistent data**
- Upstream: `/app/data` (Dockerfile ENV `PASTEY_DATA_DIRECTORY`); README run example `-v /path:/app/data`. One file per paste. Code default `./data`.

**User/UID & permissions**
- Upstream image runs as root (no USER).

**Config files and formats**
- None; env-only. Comma-separated CIDR lists.

**Healthcheck/readiness endpoints**
- None documented. Chart probes use HTTP GET `/`.

**Version/release info and asset naming**
- Release `0.5.1` ("06 Sep", year not shown on page; marked Latest; tag has no `v` prefix). Asset count 2 per page; names not readable. Source archive: `https://github.com/Cesura/pastey/archive/refs/tags/0.5.1.tar.gz` (plan.md; not downloaded here).
- README mentions Docker tags `latest` and `latest-slim` only; no version tags are named in the README.

**Arch support**
- Not stated. Pure Python with pinned old packages; `cryptography~=3.4.7` may need a compiler on newer Python (plan.md risk).

**Gotchas**
- Upstream pins target Python 3.8 (Flask 2.2, Flask-Limiter 2.6, cryptography 3.4.7); the plan relaxes them on a 3.15 base. Not verified here.
- `app.py` `distutils` import breaks on Python 3.12+.
- `PASTEY_LISTEN_PORT` override is passed to `app.run` uncast (see Env vars).
- Whitelisted IPs can see recent pastes and delete pastes; restrict pasting option exists.
- Behind a proxy set `PASTEY_BEHIND_PROXY`, else all clients look like the proxy.
- Plan check: Dockerfile-slim, requirements pins, env var defaults, port 5000, `/app/data` upstream path all match. The patch script's effects match plan.md section 4 description ("removes guesslang, TensorFlow and the AUTO option").
