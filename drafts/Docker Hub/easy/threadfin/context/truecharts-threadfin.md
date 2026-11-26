# TrueCharts threadfin chart

**Source URL(s) + fetch date**
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/threadfin (chart directory)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/threadfin/values.yaml (fetched 2026-11-26)

**What it is**
The chart that uses the `fyb3roptik/threadfin` image as its main container.

**Image (values.yaml)**
- repository `docker.io/fyb3roptik/threadfin`
- tag `1.2.37@sha256:96122ab220e14b881cbd40d7f8c7b022e1f9c6ecfe05aca2ab801e0321dc0d61`
- pullPolicy `IfNotPresent`

**Security context / env**
Not defined in the fetched values.yaml (no runAsUser, readOnlyRootFilesystem, privileged or env set).

**Persistence**
- `config`: enabled, mountPath `/home/threadfin/conf`
- `temp`: enabled, mountPath `/tmp/threadfin`, type `emptyDir`

**Service/ports**
- `service.main.ports.main.port`: `34400`

**Gotchas**
- The chart mounts the config PVC at `/home/threadfin/conf`, which matches the upstream image layout.
- No security context in the chart: the chart does not force a non-root user.
