# truecharts plex-auto-languages chart

**Source URL(s) + fetch date**
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/plex-auto-languages (listed in draft; not separately fetched)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/plex-auto-languages/values.yaml (fetched 2026-11-26)

**Container image used by chart**
- `image.repository: docker.io/remirigal/plex-auto-languages`
- `image.tag: latest@sha256:54bd9cf5d399514b8ed3052ce1d01a14375825a429653cb06da129685740889e`, `pullPolicy: IfNotPresent`

**Ports and service**
- `service.main` disabled, `service.main.ports.main` disabled (no service; no port).

**Persistence**
- `persistence.config` enabled, mountPath `/config`.

**Security**
- `securityContext.container`: `readOnlyRootFilesystem: false`, `runAsNonRoot: false`, `runAsUser: 0`, `runAsGroup: 0`.

**Probes**
- Liveness, readiness and startup all disabled. (Upstream image HEALTHCHECK on port 9880 is not used by the chart.)

**Env and secrets**
- `PLEX_URL: http://plex:32400` (chart's in-cluster Plex).
- `PLEX_TOKEN` from secret `env-secrets` key `PLEX_TOKEN` (placeholder value in chart values).

**Gotchas**
- Chart runs as root with a writable rootfs; upstream image has no USER; ContainerForge image should run as `apps` with read-only rootfs (plan.md).
- The chart does not expose 9880, consistent with its probes being disabled.
