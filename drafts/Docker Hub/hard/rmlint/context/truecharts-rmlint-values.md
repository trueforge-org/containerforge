# TrueCharts rmlint values.yaml

Source: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/rmlint (raw values.yaml), fetched 2026-11-26

- image: docker.io/bobbintb/docker-rmlint-unraid, tag latest@sha256:7ebbd4b68173e8be8ed650f2082719cfa176af4cebcc934158c69fdef646433b
- service main: port 8321, protocol tcp (no targetPort, no 8322)
- persistence: config -> /config; searchlocation -> /root (search root)
- securityContext: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0
- env: GUAC_PASS from secret `env-secrets` key GUAC_PASS; GUAC_USER ""

## Gotchas
- Chart runs as root.
- Chart env names GUAC_USER/GUAC_PASS (Guacamole) differ from the Dockerfile's Selkies base (CUSTOM_PORT etc.).
