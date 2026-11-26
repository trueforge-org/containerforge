# truecharts owncast chart

**Source URL(s) + fetch date**
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/owncast (listed in draft; not separately fetched)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/owncast/values.yaml (fetched 2026-11-26)

**Container image used by chart**
- `image.repository: docker.io/gabekangas/owncast`
- `image.tag: 0.3.0@sha256:efca3c284ac1d6d7d775d193e74f92f718774a4aa0d621f55dce449222ca5bff`, `pullPolicy: IfNotPresent`

**Ports**
- `service.main`: port 10088, targetPort 8080 (web).
- `service.rtmp` enabled: port 1935, targetPort 1935. `externalTrafficPolicy: Local` commented out.

**Persistence**
- `persistence.config` enabled, mountPath `/app/data` (ContainerForge must mount `/config` instead, per plan.md).

**Security**
- `securityContext.container`: `readOnlyRootFilesystem: false`, `runAsNonRoot: false`, `runAsUser: 0`, `runAsGroup: 0`.

**Env and probes**
- No env or probes in the values file as fetched.

**Gotchas**
- Chart runs as root with writable rootfs; upstream image runs as UID 101 and the Dockerfile sets `USER owncast`.
