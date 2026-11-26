# TrueCharts valetudo-mapper chart

**Source URL(s) + fetch date**
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/valetudo-mapper (chart directory)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/valetudo-mapper/values.yaml (fetched 2026-11-26)

**What it is**
The chart that uses the `rand256/valetudo-mapper` image as its main container.

**Image (values.yaml)**
- repository `docker.io/rand256/valetudo-mapper`
- tag `latest@sha256:4ca244330be0baf945db767b6d4d80e7c0f786ba372e8e2509b005183522b717`
- pullPolicy `IfNotPresent`

**Security context**
- runAsUser `0`, runAsGroup `0`, readOnlyRootFilesystem `false`. privileged not set.

**Env**
None.

**Persistence**
Empty map (`{}`): no volumes. The config must be provided some other way (the chart does not mount `/config` or `/app/config.json`).

**Service/ports**
- Main service disabled, port entry disabled. No port numbers. The web server (port 3000 when enabled) is not exposed by the chart.

**Probes**
- liveness, readiness, startup disabled.

**Gotchas**
- The chart mounts no config, so the mapper runs on the image default (`/app/config.json` is empty from `touch`); the default broker is the placeholder. The chart does not yet provide a working MQTT configuration.
- Runs as root with a writable rootfs, unlike the plan's non-root read-only target.
