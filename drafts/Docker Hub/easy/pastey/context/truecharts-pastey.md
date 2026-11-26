# truecharts pastey chart

**Source URL(s) + fetch date**
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/pastey (listed in draft; not separately fetched)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pastey/values.yaml (fetched 2026-11-26)

**Container images used by chart**
- `image.repository: docker.io/cesura/pastey`, `image.tag: 0.5.1@sha256:4c4f6e7a31f574a2034e0807bf874e03e350c8931d4477521fae2b3f3e2aecfe`, `pullPolicy: IfNotPresent`
- `slimImage.repository: docker.io/cesura/pastey`, `slimImage.tag: 0.5.1-slim@sha256:dc994c07aa45ce94e7f67958c4d03a6dac95f56427e7113500f0e88a258d3b13`
- `workload.main.podSpec.containers.main.imageSelector: image` (the full image by default)

**Ports**
- `service.main.ports.main`: `protocol: http`, `port: 5000`.

**Persistence**
- `persistence.data` enabled, mountPath `/app/data`.

**Security**
- `securityContext.container`: `runAsNonRoot: false`, `readOnlyRootFilesystem: false`, `runAsUser: 0`, `runAsGroup: 0`.

**Probes**
- Liveness, readiness and startup: HTTP GET `/`.

**Env (chart-set PASTEY_* values)**
- `PASTEY_LISTEN_PORT` from the service port (5000), `PASTEY_LISTEN_ADDRESS: "0.0.0.0"`, `PASTEY_BEHIND_PROXY: false`, `PASTEY_GUESS_THRESHOLD: "0.20"`, `PASTEY_RATE_LIMIT: 5/hour`, `PASTEY_RECENT_PASTES: "10"`, `PASTEY_RESTRICT_PASTING: false`, `PASTEY_USE_WHITELIST: true`, `PASTEY_WHITELIST_CIDR` (same four CIDRs as upstream), `PASTEY_BLACKLIST_CIDR` commented out, `PASTEY_DEFAULT_THEME: "Dark"` (upstream default is Light), `PASTEY_PURGE_INTERVAL: 3600`, `PASTEY_FORCE_SHOW_RECENT: false`, `PASTEY_IGNORE_GUESS: "TeX,SQL"`, `PASTEY_SHOW_CLI_BUTTON: true`.

**Gotchas**
- The chart runs as root with a writable rootfs; the ContainerForge image should run as `apps` with a read-only rootfs and `/config` (per plan.md).
- The chart's `PASTEY_DEFAULT_THEME` is `Dark`; upstream default is `Light`. Chart choice, not an upstream fact.
- Chart `/app/data` must move to `/config/data` for ContainerForge.
