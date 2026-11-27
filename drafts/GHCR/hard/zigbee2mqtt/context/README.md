# Context: zigbee2mqtt

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/zigbee2mqtt/values.yaml + Chart.yaml | truecharts-zigbee2mqtt.md |
| https://hub.docker.com/v2/repositories/koenkk/zigbee2mqtt/ | dockerhub-zigbee2mqtt.md |
| https://raw.githubusercontent.com/Koenkk/zigbee2mqtt/2.14.3/docker/Dockerfile (+ github.com blob duplicate) | github-koenkk-zigbee2mqtt-dockerfile.md |
| https://github.com/Koenkk/zigbee2mqtt/releases/tag/2.14.3 (alt for api releases) | github-koenkk-zigbee2mqtt-release.md |
| https://www.zigbee2mqtt.io (+ /guide/installation/, /guide/installation/02_docker.html) | zigbee2mqtt-io.md |

Skipped: none of the listed categories present in urls.txt (already filtered). Duplicate: github.com blob Dockerfile URL (same as raw).

## Failures
- https://api.github.com/repos/Koenkk/zigbee2mqtt: 403, no alternative fetched.
- https://api.github.com/repos/Koenkk/zigbee2mqtt/releases/tags/2.14.3: 403; HTML release page used instead (succeeded).

## plan.md corrections
- None. Ports (8080), `/app/data` and Dockerfile facts match fetched sources. Upstream base is alpine, plan uses python-node by design (not a factual error).
