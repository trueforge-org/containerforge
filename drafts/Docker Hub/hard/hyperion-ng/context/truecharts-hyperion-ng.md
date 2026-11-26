# TrueCharts hyperion-ng chart (reference only)

Source URLs:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/hyperion-ng/values.yaml (fetched 2026-11-26)
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/hyperion-ng (not fetched; values.yaml read instead)

## Image (values.yaml)
| Key | Value |
| --- | --- |
| repository | docker.io/sirfragalot/hyperion.ng |
| tag | 2.2.0@sha256:1848762c12cdd24a29dc311f100ee9f864f813c9d3b2aacf0b1e3f7876117e55 |
| pullPolicy | IfNotPresent |

Digest matches the Docker Hub `latest` digest (sha256:1848762c...) seen in dockerhub-sirfragalot-hyperion-ng.md.

## Ports
| Service | Port | Target |
| --- | --- | --- |
| main (web UI) | 10065 | 8090 |
| jsonservice | 19444 | 19444 |
| protobufservice | 19445 | 19445 |
| boblightservice | 19333 | 19333 |

## Persistence
- config: mountPath `/root/.hyperion`

## Security context
- container: runAsNonRoot false, runAsUser 0, runAsGroup 0. No podSecurityContext, no env block.

## Gotchas
- Chart runs as root. Chart tag is 2.2.0, matching GitHub latest series (2.2.1 released 2026-04-06, so the chart is one patch behind).
