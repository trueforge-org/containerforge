# TrueCharts openaudible chart values.yaml

Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/openaudible (raw values.yaml fetched) · fetched 2026-11-26

- Image: `docker.io/openaudible/openaudible`, tag latest, digest sha256:de29753b…; IfNotPresent.
- Service port 10325 -> container 3000 (http).
- Env: none defined.
- Persistence: config volume at /config/OpenAudible.
- securityContext: uid/gid 0; readOnlyRootFilesystem false.
- Probes and command/args: none.
