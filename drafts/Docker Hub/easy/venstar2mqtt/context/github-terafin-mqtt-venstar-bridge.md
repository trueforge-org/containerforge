# terafin/mqtt-venstar-bridge

Source URL(s) + fetch date: https://github.com/terafin/mqtt-venstar-bridge (README via raw.githubusercontent.com, master) · https://raw.githubusercontent.com/terafin/mqtt-venstar-bridge/423f9bd613619e92e4799135cf080c1de05d13dc/Dockerfile · https://raw.githubusercontent.com/terafin/mqtt-venstar-bridge/423f9bd613619e92e4799135cf080c1de05d13dc/package.json · https://github.com/terafin/mqtt-venstar-bridge/tags · fetched 2026-11-26

## What it is
- Node.js bridge that connects a Venstar thermostat to MQTT: publishes thermostat state and accepts commands via `/set` topics.
- Only configured through environment variables.

## Install/build steps and build deps
- Upstream Dockerfile (at 423f9bd): `FROM node:lts-alpine`; `RUN apk add --no-cache git tzdata ; mkdir -p /usr/node_app`; `COPY . /usr/node_app`; `WORKDIR /usr/node_app`; `RUN npm install --production`; `CMD ["npm", "start"]`.
- No pure build toolchain beyond npm; dependencies are installed from npm and one git dependency.
- package.json deps: `homeautomation-js-lib` (git: https://github.com/terafin/homeautomation-js-lib.git, unpinned), `lodash ^4.17.20`, `mqtt ^4.2.6`, `cron ^1.8.2`, `got ^11.0.0`.

## Runtime deps
- Node.js (upstream image uses node:lts-alpine; package.json `engines.node` is `>=4`, which is very old and not a meaningful constraint).
- Outbound network to an MQTT broker and to the Venstar thermostat's HTTP API.

## Binaries/entrypoint/CLI flags
- `package.json` scripts.start = `node index.js`. Main = `index.js`. No CLI flags.

## Env vars
| Name | Required | Default | Notes |
| --- | --- | --- | --- |
| `TOPIC_PREFIX` | yes | none | Base MQTT topic, e.g. `/venstar/living_room` |
| `MQTT_HOST` | yes | none | Broker URL, e.g. `mqtt://host` |
| `MQTT_USER` | optional | none | Broker username |
| `MQTT_PASS` | optional | none | Broker password |
| `VENSTAR_HOST` | yes | none | IP of the thermostat |
| `VENSTAR_QUERY_INTERVAL` | optional | 15 | Seconds between queries |
| `LOGGING_NAME` | not stated | none | Example value `mqtt-venstar-bridge` |
| `TZ` | not stated | none | Example value `America/Los_Angeles` |

(Other variables such as `MQTT_RETAIN`, `MQTT_NAME`, `LOG_LEVEL`, `HEALTH_CHECK_*` are documented in plan.md from code reading, not in the README.)

## Ports
- None documented. Upstream Dockerfile declares no EXPOSE.

## Volumes/paths and persistent data
- None documented. No volumes declared upstream. The app keeps no state on disk.

## User/UID & permissions
- Upstream Dockerfile sets no USER, so it runs as root.

## Config files and formats
- None. Configuration is environment variables only.

## Healthcheck/readiness endpoints
- None documented.

## Version/release info and asset naming
- No releases and no tags (GitHub tags page: "There aren't any releases here").
- Upstream Docker Hub/GHCR references use the `latest` tag only. README references `ghcr.io/terafin/mqtt-venstar-bridge:latest`; the Docker Hub page is `docker.io/terafin/mqtt-venstar-bridge`.
- package.json `version` is `1.0.0` and does not change, so it is not a usable release marker.
- Source snapshots for pinning: commit SHA (source tarball `https://github.com/terafin/mqtt-venstar-bridge/archive/<sha>.tar.gz`, not downloaded here).

## Arch support
- Pure JavaScript; no native modules visible in package.json. Arch-neutral in principle.

## Gotchas
- README example compose uses "(OPTIONAL)" and "(eg: ...)" inline text; these must be removed from real configs.
- Upstream Docker Hub page: no overview, no run instructions, no env var docs, last updated more than 3 years ago (per Docker Hub page snapshot).
- Consistent with plan.md: Dockerfile (`node:lts-alpine`, `npm install --production`, `npm start`), no EXPOSE, no USER, license MIT, package version 1.0.0, no tags.
