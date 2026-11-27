# Upstream: mitsumaui/leaf2mqtt tag v0.6 (Dockerfile + README)

Source URL(s) + date: https://raw.githubusercontent.com/mitsumaui/leaf2mqtt/v0.6/Dockerfile and .../v0.6/README.md (fetched 2026-11-27)

## What it is
- Dart app that polls Nissan Leaf connected services (NissanConnect / Carwings APIs) and publishes status to an MQTT broker (MQTT client).
- Warning in README: long-term polling without regular weekly use/charging can drain the 12V battery.

## Build (Dockerfile)
- `FROM dart AS build` (unpinned). `apt-get install -y git`. `WORKDIR /app`.
- `COPY pubspec.* ./`, `RUN dart pub get`, `COPY . .`, `RUN dart pub get --offline`.
- `RUN dart compile exe src/leaf_2_mqtt.dart -o src/leaf_2_mqtt`.
- Final: `FROM scratch`, `COPY --from=build /runtime/ /`, `COPY --from=build /app/src/leaf_2_mqtt /app/bin/`.
- `CMD ["/app/bin/leaf_2_mqtt"]`.

## Runtime
- No ENV, EXPOSE, USER, VOLUME, HEALTHCHECK, or ENTRYPOINT in Dockerfile. Runs as image default user (root).
- Base is scratch + dart runtime copied from `/runtime/` of the dart image.

## Env vars (README, v0.6)
| Var | Optional (README) | Description |
| --- | --- | --- |
| LEAF_USERNAME | No | NissanConnect username |
| LEAF_PASSWORD | No | NissanConnect password |
| LEAF_TYPE | No | newerThanMay2019, olderCanada, olderUSA, olderEurope, olderAustralia, olderJapan |
| MQTT_HOST | No | Broker IP/hostname (localhost does not work in Docker) |
| MQTT_PORT | Yes | Default 1883 |
| MQTT_USERNAME | Yes | MQTT username |
| MQTT_PASSWORD | Yes | MQTT password |
| MQTT_BASE_TOPIC | Yes | Default `leaf` |
| UPDATE_INTERVAL_MINUTES | Yes | Default 60 |
| CHARGING_UPDATE_INTERVAL_MINUTES | Yes | Default 15 (used only after UPDATE_INTERVAL elapses while charging) |
| COMMAND_ATTEMPTS | Yes | Default 1 (README recommends 5) |
| LOG_LEVEL | Yes | Default "Warning" |

- README column "Optional" as written; LEAF_USERNAME/PASSWORD/TYPE/MQTT_HOST marked "No" (required).
- Example: `docker run -e LEAF_USERNAME=... -e LEAF_PASSWORD=... -e LEAF_TYPE=newerThanMay2019 -e MQTT_HOST=... -e UPDATE_INTERVAL_MINUTES=1440 -e COMMAND_ATTEMPTS=5`.

## Ports
- None (MQTT client only; no web UI).

## Volumes/paths
- None documented.

## Config files
- None; config via env.

## Healthcheck
- None.

## Topics (MQTT output)
- Base `leaf/{vin}/...` (with `leaf/...` for the first vehicle). Subtopics: battery, climate, location, stats, cockpitStatus, nickname, vin.

## Version/asset naming
- Git tag `v0.6` (release 2022-04-17 per plan). No release assets.

## Arch
- Not stated upstream.

## Gotchas
- Dart SDK constraint and git deps: see plan (pubspec not fetched here).
- Leaf type must match the account's model year region (`LEAF_TYPE`).
- Upstream README points to a k8s-at-home registry image and helm chart (k8s-at-home org).
