# TrueCharts tvhproxy chart

**Source URL(s) + fetch date**
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/tvhproxy (chart directory)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tvhproxy/values.yaml (fetched 2026-11-26)

**What it is**
The chart that runs the third-party `chvb/docker-tvhproxy` image as its main container.

**Image (values.yaml)**
- repository `docker.io/chvb/docker-tvhproxy`
- tag `latest@sha256:e27e4c750121fd95cb1d109c6802d3bdddf42f51c4dc4404cc0eec184397fd79`
- pullPolicy `IfNotPresent`

**Security context**
- runAsUser `0`, runAsGroup `0`, readOnlyRootFilesystem `false`. privileged not set.

**Env**
- `TVH_TUNER_COUNT`: `"4"`
- `TVH_URL`: `"http://username:password@tvheadendip:9981"` (example placeholder values)

**Persistence**
- Empty map (`{}`): no volumes.

**Service/ports**
- Main service disabled, port entry disabled. No port numbers listed. The container listens on 5004 (upstream code), so the chart exposes nothing.

**Probes**
- liveness, readiness, startup all disabled.

**Gotchas**
- The chart runs as root with a writable rootfs, unlike the plan's non-root read-only target.
- `TVH_PROXY_URL` is not set in the chart, so discovery advertises the default `http://localhost`.
