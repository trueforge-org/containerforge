# TrueCharts rss-proxy values.yaml

Source: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/rss-proxy (raw values.yaml), fetched 2026-11-26

- image: docker.io/damoeb/rss-proxy, tag latest@sha256:2637cb10003fa19a31b48831ee7bd0941c668db73180c17a833c723ef894ff7d (chart uses `latest`, not 2.1.x)
- persistence: none
- service main: disabled (port 8080 not exposed by chart)
- probes: all disabled
- securityContext: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0

## Gotchas
- Chart disables its own service, so no port is wired in the chart.
