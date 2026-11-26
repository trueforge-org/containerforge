# TrueCharts reaparr values.yaml

Source: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/reaparr (raw values.yaml), fetched 2026-11-26

- image: docker.io/reaparr/reaparr, tag 0.40.0@sha256:58dde1ccabf135abbfe0e15bcda952f32921669891cd8fce30350091c2146c37
- service main: port 7000, protocol http, targetPort 7000
- env: LOG_LEVEL=INFORMATION, LOG_ENV_VARS=false, UNMASKED=false
- persistence: config -> /Config; downloads -> /Downloads
- securityContext: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0

## Gotchas
- Chart mounts only /Config and /Downloads; Dockerfile VOLUME also declares /Movies and /TvShows.
