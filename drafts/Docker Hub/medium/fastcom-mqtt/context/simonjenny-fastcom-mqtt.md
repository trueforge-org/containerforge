# simonjenny/fastcom-mqtt (Dockerfile + README)

Source URL(s): https://github.com/simonjenny/fastcom-mqtt ; https://github.com/simonjenny/fastcom-mqtt/blob/ce67907/Dockerfile (raw variant fetched) ; https://hub.docker.com/r/simonjenny/fastcom-mqtt (not fetched, JS page)
Date: fetched 2026-11-26

## What it is
- Container that runs fast.com speed tests periodically and publishes download/upload values to MQTT topics.
- Repo status: archived, read-only (per GitHub page).

## Build (Dockerfile @ ce67907)
- `FROM node:14-slim`
- RUN 1: `apt update`; install `wget gnupg mosquitto-clients`; add Google Chrome apt key (dl-ssl.google.com, apt-key) and repo `http://dl.google.com/linux/chrome/deb/` (`[arch=amd64]`); install `google-chrome-stable libxss1` (`--no-install-recommends`); `rm -rf /var/lib/apt/lists/*`.
- RUN 2: `npm i puppeteer`; create group/user `pptruser` (`-G audio,video`); mkdir `/home/pptruser/Downloads`; chown `/home/pptruser` and `/node_modules`.
- `WORKDIR /usr/src/app`; `RUN npm i fast-cli`; `COPY run /usr/src/app/run`.
- `CMD /usr/src/app/run` (shell form). No ENTRYPOINT, ENV, ARG, EXPOSE, VOLUME, USER, HEALTHCHECK.

## Runtime deps
- Node 14 image, Puppeteer, Google Chrome stable, fast-cli, mosquitto-clients (mosquitto_pub).
- Needs a reachable MQTT broker.

## Entrypoint/flags
- `/usr/src/app/run` (script is in repo root `run`, copied in Dockerfile).

## Env vars (per README; no defaults documented)
| Var | Required | Meaning |
| --- | --- | --- |
| SLEEP | yes | seconds between measurements |
| MQTT_SERVER | yes | broker IP/address (README example writes `MQTT_SERVER_`, a typo) |
| MQTT_DOWN | yes | topic for download value |
| MQTT_UP | yes | topic for upload value |
| MQTT_USER | no | MQTT username |
| MQTT_PASS | no | MQTT password |

## Ports
- None documented (MQTT broker port not mentioned).

## Volumes/paths
- None declared. Chrome/Puppeteer home at `/home/pptruser`.

## User/UID
- Created `pptruser` but no USER instruction: container runs as root.

## Gotchas
- Base `node:14-slim` is EOL; Puppeteer downloads/uses Chrome from the Google apt repo (legacy apt-key usage).
- Build uses `apt-key` (deprecated in current Debian/Ubuntu).
