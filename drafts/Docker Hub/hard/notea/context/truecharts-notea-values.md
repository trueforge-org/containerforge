# TrueCharts notea chart values.yaml

Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/notea (raw values.yaml fetched) · fetched 2026-11-26

- Image: `docker.io/diamkil/notea`, tag `latest`, pinned by digest (sha256 e331f787…2aa1), pullPolicy IfNotPresent.
- Main service and its port disabled (nothing exposed by default).
- Env from secret `env-secrets`: `PASSWORD`, `STORE_PASSWORD` (both empty defaults); `STORE_USER` default empty.
- Persistence: empty map (no volumes defined).
- securityContext: runs as uid/gid 0; readOnlyRootFilesystem false.
- Probes (liveness/readiness/startup): disabled.
- No command/args.
