# TrueCharts piaware chart values

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/piaware/values.yaml (fetched)
Chart page: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/piaware (not fetched)

- Image: docker.io/mikenye/piaware:v10.0 (sha256 pinned), pullPolicy IfNotPresent. NOTE: the mikenye image is archived/deprecated.
- Main service port 10092 -> targetPort 8080
- Env defaults (FEEDER/ADSB/BEAST/MLAT): none defined
- Persistence: config -> /config
- Probes: none
- securityContext: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false
- Devices: none; deps: none; affinity {}
