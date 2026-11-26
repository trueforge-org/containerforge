# hub.docker.com/r/simsemand/chronos

Source: https://hub.docker.com/r/simsemand/chronos (fetched 2026-11-26)

- Description: schedules Python 3.7.3 scripts (timer or event); per-script virtualenv; pip reqs entered in UI and installed manually
- Tags: `latest` only (~503.7 MB); last updated >6 years before fetch; 500K+ pulls; described as early beta
- Run: `docker run -p 5000:5000 -v CONFIG_PATH:/chronos simsemand/chronos`
- Port 5000 (web UI and REST API); volume -> /chronos
- Env: none; command: image default
- Scripts not sandboxed; REST-submitted scripts run; do not expose publicly without authenticating reverse proxy
- Arch: not stated
- Upload layout: scripts in config dir; `execute.sh` invoked for non-Python runs

## Docker Hub JSON (added 2026-11-26)
- Source: https://hub.docker.com/v2/repositories/simsemand/chronos/ and /tags?page_size=10
- description empty; pull_count 685852; star_count 4; last_updated 2020-09-17 (stale)
- Tags: latest (2020-07-13, 528 MB), edge (2020-09-17), 0.2 (2020-07-13, linux/amd64), 0.1.4, 0.1.3, 0.1.2, 0.1.1, 0.1.0, simse-patch-1, master. All linux/amd64.
- Tag 0.2 exists (plan pins 0.2 via git tag); Docker Hub `latest` is from 2020
