# TrueCharts traggo chart

**Source URL(s) + fetch date**
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/traggo (chart directory)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/traggo/values.yaml (fetched 2026-11-26)

**What it is**
The chart that uses the `traggo/server` image as its main container.

**Image (values.yaml)**
- repository `docker.io/traggo/server`
- tag `0.8.3@sha256:8bf510774ce1729b5bd9a8930e174de03ebec8c25ca4aaa087c0e56e2bcbb67a`
- pullPolicy `IfNotPresent`

**Security context**
Not present in values.yaml.

**Env**
- Chart values: `traggo` block sets username `admin`, password `admin`, `pass_strength` 10, `log_level` `info`.
- Main container also uses `envFrom` with a secret named `secret`.

**Persistence**
- `config` enabled, mountPath `/opt/traggo/data` (not `/config`).

**Service/ports**
- `service.main.ports.main`: protocol `http`, port `12117`. The targetPort is not shown in the fetched content; the upstream listens on 3030 by default.

**Gotchas**
- The chart mounts the data volume at `/opt/traggo/data`, the upstream Docker layout, not `/config`.
- The chart pins the same digest as the Docker Hub `latest` tag.
- The chart service port (12117) differs from the upstream default (3030); the chart's env mapping for `TRAGGO_PORT` is not shown.
