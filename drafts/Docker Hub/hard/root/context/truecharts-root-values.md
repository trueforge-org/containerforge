# TrueCharts root values.yaml

Source: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/root (raw values.yaml), fetched 2026-11-26

- image: docker.io/bgameiro/arch-cern-root, tag latest@sha256:c3564208c619f05e6b5f81a2bac9fcb0cae5bfe8e522e60f7c3875566e5751ca
- service main: port 9999 (tcp) -> targetPort 8888
- persistence: appdata -> /appdata
- securityContext: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0

## Gotchas
- Chart exposes 9999 externally and maps to container 8888.
- Chart uses /appdata (the image's VOLUME), not /config.
