# simse/chronos README

Source: https://raw.githubusercontent.com/simse/chronos/master/README.md (fetched 2026-11-26)

## What it is
- Small container to run and schedule Python scripts; triggers: interval, CRON; web UI; captures stdout/stderr
- Each script gets its own virtualenv and folder
- Python 3.7 in image; not for long-running or port-listening scripts

## Install/run
- `docker pull simsemand/chronos`
- `docker run -p 5000:5000 -v CONFIG_PATH:/chronos simsemand/chronos`

## Env vars / config
- none; only config is the mounted /chronos volume (no documented options)

## Ports
- 5000 (web UI)

## Volumes
- host CONFIG_PATH -> /chronos

## Runtime deps
- Docker; Python 3.7 + pip/virtualenv inside container

## Gotchas
- No access control: UI lets any visitor run Python on the server; do not expose publicly
- Maintainer note: small feature requests added quickly

## License
- none stated on README (LICENSE file in repo per plan; not checked here)
