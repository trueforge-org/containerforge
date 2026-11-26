# truecharts newyearcountdownclock chart

**Source URL(s) + fetch date**
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/newyearcountdownclock (listed in draft; not separately fetched)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/newyearcountdownclock/values.yaml
- Fetched 2026-11-26.

**Container image used by chart**
- `image.repository: docker.io/modem7/newyearcountdown`
- `image.tag: latest@sha256:7a3b00067ae17a7c8792f184a91542ed20218d690e65b370444d8a43ac3acf88`
- `pullPolicy: IfNotPresent`

**Config and security settings in values.yaml**
- `persistence: {}` (no volumes).
- `securityContext.container`: `readOnlyRootFilesystem: false`, `runAsUser: 0`, `runAsGroup: 0`.
- `service.main.enabled: false`, `service.main.ports.main.enabled: false` (the chart does not expose the service; common library defaults apply).
- Probes: liveness, readiness, startup all disabled.
- No env vars defined.

**Gotchas**
- The chart runs the image as root with a writable rootfs; upstream runs as UID 101 and needs neither, so the ContainerForge image should run rootless with a read-only rootfs.
- The chart pins the digest together with `latest`; it is not a version pin.
