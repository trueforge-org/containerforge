# TrueCharts spaceengineers chart (reference only)

Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/spaceengineers (values.yaml raw, fetched 2026-11-26).

## values.yaml facts
- Image: `docker.io/devidian/spaceengineers`, tag `latest@sha256:15bd1fff0d524dbfbb6cfd50c9d64deec57e778d9bf86598275f28427bfaa7a9`
- `runAsUser: 0`, `runAsGroup: 0`, `runAsNonRoot: false`, `readOnlyRootFilesystem: false`
- Service ports: main 27017/udp, steam 27018/udp, api 18080/http (api port used for RemoteApiPort in config patch)
- Env: `INSTANCE_NAME` = "TestInstance", `PUBLIC_IP` = "1.2.3.4"
- Chart has an exec-type config-patch hook that rewrites ServerPort/SteamPort/RemoteApiPort in SpaceEngineers-Dedicated.cfg under the instances path.
- Port numbers differ from docs (27016 in upstream examples) - chart uses 27017/27018/18080.
