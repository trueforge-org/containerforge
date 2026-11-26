# Context: ring-mqtt

| Source URL | File |
| --- | --- |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ring-mqtt | truecharts-ring-mqtt-values.md |
| https://github.com/tsightler/ring-mqtt | ring-mqtt-readme.md |
| https://github.com/tsightler/ring-mqtt/blob/59aab41/Dockerfile | ring-mqtt-dockerfile.md |
| https://github.com/tsightler/ring-mqtt/releases/tag/v5.9.3 | ring-mqtt-release-v5.9.3.md |
| https://github.com/tsightler/ring-mqtt/wiki | (no file, see failures) |
| https://hub.docker.com/r/tsightler/ring-mqtt | dockerhub-tsightler-ring-mqtt.md |

Skipped categories: none beyond pre-filtering (urls.txt already filtered).
Failures:
- https://github.com/tsightler/ring-mqtt/wiki: fetched (200) but the response is JS-rendered navigation only, no wiki text. Alternative not tried (wiki pages not linked from urls.txt). Install/config/env docs therefore not summarised.

## plan.md corrections
- None made. Checked plan.md against fetched facts (5.9.3 tag, go2rtc v1.9.14 pin, s6 3.2.2.0, bashio 0.17.5, Node jod base, ports 55123 and 8554, /data, no release assets). All consistent.
- Note for licence (plan line 10, left unchanged): the Dockerfile LABEL `org.opencontainers.image.licenses="MIT"` supports MIT, but LICENSE file itself was not read.
- Unverified (wiki unavailable): plan line 15 (55123 web UI for Ring auth), line 16 (BRANCH env, RINGTOKEN/MQTTHOST absent), and plan line 9 (latest go2rtc v1.9.15).
