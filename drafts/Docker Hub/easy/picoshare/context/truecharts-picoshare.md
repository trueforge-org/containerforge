# truecharts picoshare chart

**Source URL(s) + fetch date**
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/picoshare (listed in draft; not separately fetched)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/picoshare/values.yaml (fetched 2026-11-26)

**Container image used by chart**
- `image.repository: docker.io/mtlynch/picoshare`
- `image.tag: v1.5.5@sha256:4f4bd8e09aaa4649ec7904e12a395ae437e4aad3b20fba9c53be387d34cd779f`, `pullPolicy: IfNotPresent`

**Ports**
- `service.main.ports.main.port: 10209`; env `PORT` is templated from it (so the chart listens on 10209, not 4001).

**Persistence**
- `persistence.data` enabled, mountPath `/data`. ContainerForge uses `/config` (plan.md), so the chart mount must change.

**Env and secrets**
- `PS_SHARED_SECRET` from secret `env-secrets` (comment: "web admin password"); the secret's example value is a placeholder `somesecretcode`.
- `LITESTREAM_BUCKET: ""`, `LITESTREAM_ENDPOINT: ""`, `LITESTREAM_ACCESS_KEY_ID` and `LITESTREAM_SECRET_ACCESS_KEY` from `env-secrets` (empty values).
- `LITESTREAM_RETENTION: 72h`.

**Security and probes**
- No `securityContext` and no probes in the values file (common library defaults apply; plan.md expects non-root 568 and read-only rootfs, not verified in this file).

**Gotchas**
- The chart's port 10209 differs from upstream default 4001; ContainerForge's default (4001 per plan) must be reflected in the chart's values (not in this repo).
