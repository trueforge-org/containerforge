# TrueCharts passwordpusherephemeral chart values

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/passwordpusherephemeral/values.yaml (fetched)
Chart page: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/passwordpusherephemeral (not fetched)

- Image: docker.io/pglombardo/pwpush-ephemeral, tag latest, sha256 pinned, pullPolicy IfNotPresent
- Main service: enabled false; main port disabled
- Env defaults: none
- Persistence: empty object (no volumes)
- Probes (liveness/readiness/startup): disabled on main container
- securityContext: runAsUser 0, runAsGroup 0 (root), readOnlyRootFilesystem false
- Dependencies: none
- Schema: values.schema.json referenced
