# truecharts: tubearchivist-redisjson (chart 11.0.0)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tubearchivist-redisjson/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Dependency chart "TubeArchivist" for the Redis+RedisJSON sidecar (category MediaServer-Other).
- Chart `version: 11.0.0`, `appVersion: latest`, kubeVersion `>=1.33.0-0`.
- Depends on `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.

## Chart sources listed
- https://github.com/RedisJSON/RedisJSON
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/tubearchivist-redisjson
- https://hub.docker.com/r/redislabs/rejson

## values.yaml (only overrides)
| Key | Value |
| --- | --- |
| image.repository | `docker.io/redislabs/rejson` |
| image.tag | `latest@sha256:465de6df02d82dfc3a7cc0173f305a9acfcdfc1155e2f84234a4434112c84047` |
| image.pullPolicy | IfNotPresent |
| persistence.data | enabled, mountPath `/data` |
| securityContext.container | readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0 |
| service.main.ports.main | port 6379/tcp -> targetPort 6379 |

## Gotchas
- Chart pins the image by `latest` digest, not a version tag.
- Runs as root (UID/GID 0) with writable rootfs in this chart.
