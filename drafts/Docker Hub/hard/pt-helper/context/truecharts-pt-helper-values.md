# TrueCharts pt-helper values.yaml

Source: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/pt-helper (raw values.yaml), fetched 2026-11-26

- image: docker.io/crazyq/pt_helper, tag latest@sha256:43a4f8707b2c95a767185fabdeb5005aac1109af62fbad74249e24471ba976a8
- persistence: data -> /data (enabled)
- service main: port 8192, protocol tcp, targetPort 8192
- securityContext: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0

## Gotchas
- Chart runs as root; only /data persisted.
