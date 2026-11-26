# shneezin/breitbandmessung-node README

Source: https://raw.githubusercontent.com/shneezin/breitbandmessung-node/master/README.md (fetched 2026-11-26)

## What it is
- Script automating Bundesnetzagentur Breitbandmessung speed-test campaigns (drives breitbandmessung.de); packaged as Docker image (Alpine or Debian)

## Install/run
- `mkdir config` (holds config.cfg); `mkdir messprotokolle`
- Alpine: `docker run -d -v $PWD/config/:/usr/src/app/config:rw -v $PWD/messprotokolle:/export/ --name breitbandmessung shneezin/breitbandmessung-node`
- Debian: same, tag `shneezin/breitbandmessung-node:debian`
- Clone route: `sudo ./create.sh` with `alpine` or `debian`
- Merge CSVs: `merge.sh`

## Runtime deps
- Docker; git for clone route; wget+bash for merge one-liner
- Arch: Debian amd64, arm64, arm/v7; Alpine amd64, arm64

## Env vars
- none (settings in config file)

## Ports
- none

## Volumes
- $PWD/config -> /usr/src/app/config (rw); $PWD/messprotokolle -> /export/

## Config file config/config.cfg
| key | meaning | default |
| --- | --- | --- |
| timezone | tz database name | UTC (example Europe/Berlin) |
| crontab | cron expression | `0 */2 * * *` |
| run_once | single run, no cron | - |
| run_on_startup | measure at start | - |

## License
- none named; author: use and improve freely, no responsibility
