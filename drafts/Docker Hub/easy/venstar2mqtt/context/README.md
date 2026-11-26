# Context sources: venstar2mqtt

Fetched 2026-11-26.

## Source URL -> file

| Source URL | File |
| --- | --- |
| https://github.com/terafin/mqtt-venstar-bridge (README, Dockerfile @423f9bd, package.json, tags) | github-terafin-mqtt-venstar-bridge.md |
| https://github.com/terafin/homeautomation-js-lib | github-terafin-homeautomation-js-lib.md |
| https://github.com/terafin/homeautomation-js-lib.git | github-terafin-homeautomation-js-lib.md (same repo) |
| https://github.com/terafin/mqtt-venstar-bridge/blob/423f9bd/Dockerfile | github-terafin-mqtt-venstar-bridge.md (fetched raw at 423f9bd) |
| https://hub.docker.com/r/terafin/mqtt-venstar-bridge | dockerhub-terafin-mqtt-venstar-bridge.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/venstar2mqtt | truecharts-venstar2mqtt.md |
| https://github.com/terafin/mqtt-venstar-bridge/tags | github-terafin-mqtt-venstar-bridge.md (tags section) |

## Skipped

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA page |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema URL |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link |
| https://github.com/terafin/mqtt-venstar-bridge/archive/refs/heads/master.zip | direct archive download |
| https://github.com/terafin/mqtt-venstar-bridge/archive/${VERSION}.tar.gz | archive download, placeholder |
| https://github.com/terafin/mqtt-venstar-bridge/archive/ | archive download, incomplete |
| ghcr.io/trueforge-org/python-node, ghcr.io/trueforge-org/ubuntu | ghcr image refs, not web pages |
| docker.io/terafin/mqtt-venstar-bridge:latest | image ref, covered by the Docker Hub page above |

Asset naming: source tarball pattern `https://github.com/terafin/mqtt-venstar-bridge/archive/<sha>.tar.gz` (not downloaded).

## Fetch failures

None.

## plan.md corrections

None. Checked against the fetched sources: Dockerfile base, npm install, npm start, no EXPOSE/USER, MIT license, package version 1.0.0, no tags, and the env var list all agree. Notes (not edits):
- unverified: homeautomation-js-lib env vars (`HEALTH_CHECK_*`) and port `0.0.0.0` health server were not confirmed by the README or package.json.
- unverified: `MQTT_RETAIN`, `MQTT_NAME`, `LOG_LEVEL`, `MQTT_STATUS_TOPIC_PREFIX` defaults are from code reading, not in fetched docs.
