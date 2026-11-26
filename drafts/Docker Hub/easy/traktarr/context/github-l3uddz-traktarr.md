# l3uddz/traktarr (application source, Dockerfile, requirements, README, CLI)

**Source URL(s) + fetch date**
- https://github.com/l3uddz/traktarr (repo root)
- https://raw.githubusercontent.com/l3uddz/traktarr/52d71964a2cd6504adda6e2b2d5cdfc68cc794c8/docker/Dockerfile (fetched 2026-11-26)
- https://raw.githubusercontent.com/l3uddz/traktarr/1.2.5/requirements.txt (fetched 2026-11-26)
- https://raw.githubusercontent.com/l3uddz/traktarr/master/README.md (fetched 2026-11-26)
- https://raw.githubusercontent.com/l3uddz/traktarr/1.2.5/traktarr.py (fetched 2026-11-26)
- https://github.com/l3uddz/traktarr/archive/refs/tags/${VERSION}.tar.gz, https://github.com/l3uddz/traktarr/archive/refs/heads/master.zip: direct source archives, not fetched (pattern below).

**What it is**
"Add new shows & movies to Sonarr/Radarr from Trakt." A Python 3 CLI that runs as a scheduler (`run`) or one-off commands. It acts only as a client to Trakt, Sonarr and Radarr. It is not a web service.

**Install/build steps and build deps (upstream Dockerfile at 52d7196, `docker/Dockerfile`)**
- `FROM python:3.7-alpine3.10`
- ARGs `BRANCH`, `COMMIT` (build tracking only).
- `ENV APP_DIR=traktarr BRANCH COMMIT TRAKTARR_CONFIG=/config/config.json TRAKTARR_CACHEFILE=/config/cache.db TRAKTARR_LOGFILE=/config/traktarr.log`
- `COPY . /traktarr`
- `apk --no-cache -U upgrade`, `pip install --no-cache-dir --upgrade pip setuptools`, `pip install --no-cache-dir --upgrade -r /traktarr/requirements.txt`
- `WORKDIR /traktarr`, `VOLUME /config`, `ENTRYPOINT ["python", "traktarr.py"]`
- No `EXPOSE`, `USER` or `CMD`.

**Runtime deps**
Python with the packages in `requirements.txt` (at tag 1.2.5):
```
backoff==1.5.0
schedule==0.5.0
attrdict==2.0.0
click==6.7
requests~=2.20.0
pyfiglet
cashier~=1.3
apprise==0.7.7
```
Native install per README: Python 3.5+ (Debian), `pip install -r requirements.txt`.

**Binaries/entrypoint/CLI flags**
- Entrypoint: `python traktarr.py`. CLI group `app`, help "Add new shows & movies to Sonarr/Radarr from Trakt."
- Version: `@click.version_option('1.2.5', prog_name='Traktarr')`.
- Global options (each with an env var, default relative to the script's directory):

| Option | Env | Default |
|---|---|---|
| `--config` | `TRAKTARR_CONFIG` | `config.json` (script dir) |
| `--cachefile` | `TRAKTARR_CACHEFILE` | `cache.db` (script dir) |
| `--logfile` | `TRAKTARR_LOGFILE` | `activity.log` (script dir) |

- Commands: `run` (automatic mode; `-d/--add-delay` 2.5, `-s/--sort` votes/rating/release, `--no-search`, `--run-now`, `--no-notifications`, `--ignore-blacklist`), `trakt_authentication` (Trakt OAuth; prints a code for trakt.tv/activate and polls every 5 s), `movie` (`-id/--movie-id` required, `-f`, `-ma`, `--no-search`), `movies` (`-t/--list-type` required, plus `-l -d -s -y -g -f -a -rt -ma` and flags), `show` (`-id/--show-id` required, `-f`, `--no-search`), `shows` (like movies, no `-rt`/`-ma`).
- `run` loop: logs "Automatic mode is now running."; registers `schedule` jobs from `automatic.movies.interval` and `automatic.shows.interval` (hours; 0 skips); logs "Next job at ..." each loop; SIGTERM/SIGINT run `exit_handler`, which clears the schedule and exits.

**Env vars**
- `TRAKTARR_CONFIG`, `TRAKTARR_CACHEFILE`, `TRAKTARR_LOGFILE` (above). These are the only env vars in the source. The README and Dockerfile define no others.
- Trakt client credentials live in `config.json` (`trakt.client_id`, `trakt.client_secret`), not env.

**Ports**
None. No HTTP server or listening socket (`traktarr.py` acts as a client only). README lists only Sonarr (`localhost:8989`) and Radarr (`localhost:7878`) as example URLs.

**Volumes/paths and persistent data**
- `VOLUME /config` (Dockerfile). Config file, `cache.db` and `traktarr.log` are all set to `/config` by ENV.
- Default CLI paths are relative to the script directory (`activity.log` for logs). The Dockerfile overrides them.

**User/UID & permissions**
No USER directive upstream (runs as root).

**Config files and formats**
`config.json` (created by `traktarr run` if missing, then edit it). Top-level keys: `core`, `automatic`, `filters`, `notifications`, `radarr`, `sonarr`, `trakt`, `omdb`.
- `core.debug` (default `false`).
- `trakt.client_id`, `trakt.client_secret`. Trakt app redirect URI `urn:ietf:wg:oauth:2.0:oob`.
- `radarr`: `api_key`, `minimum_availability` (`announced`, `in_cinemas`, `released`), `quality`, `root_folder`, `url` (include URL Base if enabled).
- `sonarr`: `api_key`, `language` (v3 only), `quality`, `root_folder`, `season_folder`, `tags`, `url`.
- `omdb.api_key` (Rotten Tomatoes filtering).
- `automatic.movies` / `automatic.shows`: `interval` (hours; 0 skips), list keys (`anticipated`, `boxoffice` (movies only), `popular`, `trending`, `watched`, `played`, `watchlist`, `lists`); `watched_*`/`played_*` variants take weekly/monthly/yearly/all.
- `filters.movies` / `filters.shows`, `notifications` (apprise, pushover, slack entries).

**Healthcheck/readiness endpoints**
None.

**Version/release info and asset naming**
- Tag `1.2.5` (plan.md: commit `3c89b265aafcfa62a2235894d9b49eaecb31c171`; `--version` string 1.2.5 in `traktarr.py`).
- Dockerfile in the draft: master HEAD `52d71964a2cd6504adda6e2b2d5cdfc68cc794c8` (newer than the tag per plan.md, last push 2023-03-14 per plan.md).
- Tag archive pattern: `https://github.com/l3uddz/traktarr/archive/refs/tags/<version>.tar.gz` (no `v` prefix; plan.md).

**Arch support**
Pure Python; arch-independent. Docker Hub third-party image says "multiarch" (no list).

**Licence**
GPL-3.0 (per the fetched fact "GPL v3.0 code" in traktarr.py's header note; plan.md says `LICENSE.md` is GPLv3).

**Gotchas**
- No port. Health checks must be command- or file-based.
- `config.json` is generated on first `run`; the app then needs a Trakt client ID and secret, plus Sonarr/Radarr URLs and API keys, before it does anything useful.
- `trakt_authentication` is interactive (prints a code; poll interval 5 s).
- README's native install uses Debian `python3` and a systemd unit; not applicable to the container.
- `misc/config.py` (where the first-run default config is written and what exit code it uses) was NOT fetched. The plan.md statement "exits 0" is UNVERIFIED.
- `attrdict==2.0.0` and `click==6.7`: Python 3.15 compatibility is UNVERIFIED (plan.md says `collections.Mapping` removal; not checked here).

**plan.md consistency**
- Matches: Dockerfile (`python:3.7-alpine3.10`, ENV names, `VOLUME /config`, `ENTRYPOINT python traktarr.py`); requirements at 1.2.5; `--version` 1.2.5; the three `TRAKTARR_*` env vars; no port (plan corrects the draft's `5555`); `run` loop.
- Unverified: first-run behaviour (exit 0 and the "Please edit" message) — `misc/config.py` not fetched; `attrdict` import failure on 3.10+; click underscore command name for `trakt_authentication`.
