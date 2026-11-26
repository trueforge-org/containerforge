# dchesterton/amcrest2mqtt (Docker Hub)

Source URL(s) + fetch date:
- https://hub.docker.com/r/dchesterton/amcrest2mqtt
- Fetched 2026-11-26

## What it is
Docker Hub listing for the amcrest2mqtt image (see github-dchesterton-amcrest2mqtt.md for the app itself).

## Version/release info and asset naming
- Only the `latest` tag is listed. The page does not show versioned tags such as `1.0.16`, so the pinned version in plan.md (`dchesterton/amcrest2mqtt:1.0.16`) could not be confirmed from this page. It was not verified against the registry tag list in this fetch.
- Image size reported as 19.4 MB. Listing shows 500K+ pulls, 6 stars, last updated more than 4 years ago.
- Architectures: not shown on the page.

## Run instructions (from listing)
- `docker pull dchesterton/amcrest2mqtt`
- Compose example: container name `amcrest2mqtt`, restart `unless-stopped`, env `AMCREST_HOST`, `AMCREST_PASSWORD`, `MQTT_HOST`, `MQTT_USERNAME`, `MQTT_PASSWORD`, `HOME_ASSISTANT: "true"`.

## Ports
None exposed or mapped in the example.

## Volumes/paths
None shown. TLS cert paths would need to be reachable, but no mounts are documented.

## Env vars
Same set as the source summary: AMCREST_HOST and AMCREST_PASSWORD (required), AMCREST_PORT (80), AMCREST_USERNAME (admin), MQTT_USERNAME (required), MQTT_PASSWORD (empty), MQTT_HOST (localhost), MQTT_QOS (0), MQTT_PORT (1883), MQTT_TLS_ENABLED/MQTT_TLS_CA_CERT/MQTT_TLS_CERT/MQTT_TLS_KEY (TLS), HOME_ASSISTANT (false), HOME_ASSISTANT_PREFIX (homeassistant), STORAGE_POLL_INTERVAL (3600), DEVICE_NAME (optional).

## Gotchas
- Docker Compose is the recommended method per listing; Docker is the only supported deployment.
- Each instance supports one device.
