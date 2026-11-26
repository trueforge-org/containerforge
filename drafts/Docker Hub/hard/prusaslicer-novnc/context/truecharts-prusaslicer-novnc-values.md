# TrueCharts prusaslicer-novnc values.yaml

Source: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/prusaslicer-novnc (raw values.yaml), fetched 2026-11-26

- image: docker.io/mikeah/prusaslicer-novnc, tag latest@sha256:9d940dcadb1ff9aa9ccee05ee26a1a8804b6d0adfbef4600e392f152a9a67350
- persistence: configsfolder -> /configs/, prints -> /prints/
- service main: port 16080 (http) -> targetPort 8080
- securityContext: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0, runAsNonRoot false
- env: SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

## Gotchas
- Chart runs as root and no GPU settings in values.
