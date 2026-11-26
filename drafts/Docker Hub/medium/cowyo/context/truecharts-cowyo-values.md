# trueforge-org/truecharts charts/stable/cowyo values.yaml

Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/cowyo/values.yaml (raw variant; fetched 2026-11-26)

- Image: docker.io/schollz/cowyo, tag latest pinned by digest (0ab02a43...), IfNotPresent
- Service main: TCP 8050 -> container 8050 (upstream EXPOSE is 8001)
- Env: none
- Persistence: data volume at /data
- securityContext: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false
- Chart.yaml: NOT fetched (see README)
