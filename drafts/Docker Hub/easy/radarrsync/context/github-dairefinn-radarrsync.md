# dairefinn/RadarrSync (GitHub, the fork the Docker image is built from)

Source URL(s) + fetch date (2026-11-26):
- https://github.com/dairefinn/RadarrSync (repo; README via https://raw.githubusercontent.com/dairefinn/RadarrSync/master/README.md)
- https://raw.githubusercontent.com/dairefinn/RadarrSync/master/Dockerfile (draft cites blob/master/Dockerfile)
- https://raw.githubusercontent.com/dairefinn/RadarrSync/master/requirements.txt
- https://raw.githubusercontent.com/dairefinn/RadarrSync/master/startup.sh
- https://raw.githubusercontent.com/dairefinn/RadarrSync/master/RadarrSync.py
- Not fetched: https://github.com/dairefinn/RadarrSync/archive/${VERSION}.tar.gz (contains ${, skipped); https://github.com/dairefinn/RadarrSync/archive/7546e59b7c6ca50f42460e919ebd86eb254a2c57.tar.gz (direct archive download, skipped; plan.md records sha256 for it).

## What it is
Links two Radarr servers through their web API so that movies added to one are added to a second (4K) instance and a search is triggered there. This fork is built for Docker and handles only two servers. Configuration is environment variables only.

## Install/build steps and build deps (Dockerfile)
```
FROM python:3-alpine
COPY RadarrSync.py /
COPY requirements.txt /
COPY startup.sh /
RUN  pip install -r requirements.txt && chmod 755 /startup.sh
ENTRYPOINT [ "sh","/startup.sh" ]
```
- No ARG, ENV, WORKDIR, EXPOSE, VOLUME, USER, HEALTHCHECK or CMD.

## Runtime deps
- Python 3 (base python:3-alpine).
- requirements.txt: `requests==2.20.0` only.

## Binaries/entrypoint/CLI flags
- Entrypoint: `sh /startup.sh`, which runs `while [ true ]; do python /RadarrSync.py; sleep 15m; done`.
- RadarrSync.py: `VER = '1.0.1'`, `DEV = False`. No CLI arguments.

## Env vars (all read with os.environ[...], missing one raises KeyError)
| Name | Purpose |
| --- | --- |
| RADARR_URL | Source Radarr base URL |
| RADARR_KEY | API key for source Radarr |
| RADARR4K_URL | Target (4K) Radarr base URL |
| RADARR4K_KEY | API key for target Radarr |
| PROFILE_ID | Quality profile id on the target to transcode to (example 5) |

## Ports
- None. No listening socket; outbound HTTP only.

## Volumes/paths and persistent data
- Log file: `./Output.txt` (relative to cwd, via logging.FileHandler). Console output to stdout.
- Both Radarr servers must share the same root path (README example `/movie`).

## Config files and formats
- None. Env only.

## User/UID & permissions
- Not set; runs as root (base image default, no USER).

## Healthcheck/readiness
- None.

## Radarr API used
- Unversioned v0.2-era paths: `GET {RADARR_URL}/api/movie?apikey=...`, `GET {RADARR4K_URL}/api/movie?apikey=...`, `POST {RADARR4K_URL}/api/movie?apikey=...` (adds movie), `POST {RADARR4K_URL}/api/command?apikey=...` with `{'name':'MoviesSearch','movieIds':...}`.
- Sessions set trust_env = False. sys.exit(0) on non-200 from either server.
- Gotcha: current Radarr uses /api/v3; this script is old and may not work against current Radarr versions (plan.md section 10 notes a blocker; not re-verified here).

## Version/release info and asset naming
- No tags or releases on the fork. Script VER 1.0.1. Last commit per plan.md 7546e59b (2021-01-28). Archive URL pattern `https://github.com/dairefinn/RadarrSync/archive/<commit>.tar.gz`.

## Arch support
- Pure Python; no per-arch artifact. Image python:3-alpine.

## Gotchas
- Interval: the loop sleeps 15 minutes between runs.
- Fork includes no LICENSE per plan.md (GitHub API reports none).
- Original upstream: https://github.com/Sperryfreak01/RadarrSync (see github-sperryfreak01-radarrsync.md).
