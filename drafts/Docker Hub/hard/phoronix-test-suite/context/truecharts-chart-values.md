# TrueCharts phoronix-test-suite chart values

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/phoronix-test-suite/values.yaml (fetched)
Chart page: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/phoronix-test-suite (not fetched)

- Image: docker.io/phoronix/pts, tag latest, sha256 pinned (cfd4f4fc...), pullPolicy IfNotPresent
- Main service disabled; ports disabled; probes disabled
- Env defaults: none
- Persistence: appdata -> /var/lib/phoronix-test-suite; results -> /var/lib/phoronix-test-suite/test-results
- securityContext: runAsUser 0, runAsGroup 0 (root), readOnlyRootFilesystem false
- No privileged flag, no device mounts, no deps
