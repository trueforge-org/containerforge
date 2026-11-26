# TrueCharts chart: jelu
Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/jelu (raw values.yaml + Chart.yaml fetched 2026-11-26)

## Chart.yaml
- version 11.0.0, appVersion latest; common 32.8.5; min helm 3.14, max helm 4.1

## values.yaml
| Key | Value |
| --- | --- |
| image.repository | docker.io/wabayang/jelu |
| image.tag | latest@sha256:5b381c6e66df043e53215da8722576ab2a22ac01ecebd607b6541290df97f7aa |
| service.main.ports.main | tcp port 11111 -> targetPort 11111 |
| persistence.config | mountPath /config |
| persistence.databasepath | mountPath /database |
| persistence.imagespath | mountPath /files/images |
| persistence.importspath | mountPath /files/imports |
| securityContext.container | runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false |

## Notes
- No env vars, probes or healthcheck set in chart values.
- Chart mount paths match upstream docker-compose sample (/config, /database, /files/images, /files/imports).
