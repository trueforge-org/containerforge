# Context: leaf2mqtt

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/leaf2mqtt/values.yaml + Chart.yaml | truecharts-leaf2mqtt.md |
| https://raw.githubusercontent.com/mitsumaui/leaf2mqtt/v0.6/Dockerfile + README.md | github-mitsumaui-leaf2mqtt-v0-6.md |

Skipped: GitHub HTML blob page (https://github.com/mitsumaui/leaf2mqtt/blob/v0.6/Dockerfile, covered by raw), repo root (covered by raw README), https://github.com/k8s-at-home/container-images (upstream registry/org page, no build source). No Docker Hub URL (image is ghcr.io/k8s-at-home). No CLA, forgetool, templated or binary URLs.

Failures: none.

## plan.md corrections
- None edited. Plan line 104 says "no upstream variable is confirmed". The v0.6 README (fetched) documents the env set listed in the GitHub file (LEAF_USERNAME, LEAF_PASSWORD, LEAF_TYPE, MQTT_HOST, MQTT_PORT, MQTT_USERNAME, MQTT_PASSWORD, MQTT_BASE_TOPIC, UPDATE_INTERVAL_MINUTES, CHARGING_UPDATE_INTERVAL_MINUTES, COMMAND_ATTEMPTS, LOG_LEVEL). This is a design decision for the author (plan says add env only after README is read), so not edited.
