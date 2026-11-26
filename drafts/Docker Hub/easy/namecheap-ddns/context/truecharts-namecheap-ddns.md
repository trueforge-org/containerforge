# truecharts namecheap-ddns chart

**Source URL(s) + fetch date**
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/namecheap-ddns (directory listing)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/namecheap-ddns/values.yaml
- Fetched 2026-11-26.

**What it is**
- TrueCharts Helm chart for the upstream namecheap_ddns script. Chart is not maintained upstream; issues go to TrueCharts.
- Install: `helm install mychart oci://oci.trueforge.org/truecharts/namecheap-ddns`.
- Chart directory: `templates/`, `.helmignore`, `CHANGELOG.md`, `Chart.yaml`, `README.md`, `icon-small.webp`, `icon.webp`, `values.schema.json`, `values.yaml`.

**Container image used by chart**
- `image.repository: docker.io/edchamberlain/namecheap_ddns`
- `image.tag: latest@sha256:fb6e8ad8647cf37b4e82a084d52e2c5b2fc0f3d4ceaa83690f7edf4a16eed19b`
- `pullPolicy: IfNotPresent`

**Config and security settings in values.yaml**
- `persistence: {}` (no persistent volumes).
- `securityContext.container`: `readOnlyRootFilesystem: false`, `runAsUser: 0`, `runAsGroup: 0`. No `privileged` setting in this file (common default applies).
- `service.main.enabled: false` and `service.main.ports.main.enabled: false` (no service or port).
- Probes: liveness, readiness, startup all `enabled: false`.
- Env: `APP_DOMAIN: ""`, `APP_HOST: ""`, `APP_PASSWORD` from secretKeyRef `env-secrets/APP_PASSWORD`.
- Secret `env-secrets` enabled, with `APP_PASSWORD: ""`.

**Gotchas**
- Chart runs as UID/GID 0 and with a writable rootfs. Upstream does not need either (no files written, no root-only operation), so the ContainerForge image can run rootless.
- Chart uses a pinned digest with `latest`; the ContainerForge version should follow the upstream source commit, not this tag.
- Values do not set any port or persistence, consistent with the plan.
