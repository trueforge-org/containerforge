# TrueCharts chart: farmos

**Source URL(s) + date:** https://github.com/trueforge-org/truecharts/tree/master/charts/stable/farmos (dir listing not read); raw `charts/stable/farmos/Chart.yaml` and `values.yaml` on master. Fetched 2026-11-26.

**What it is:** TrueCharts Helm chart `farmos`, chart version `11.0.0`, `appVersion: latest`, common library dependency `common` 32.8.5 (oci://oci.trueforge.org/truecharts). Category Productivity, train stable. Sources listed: farmOS/farmOS, the chart dir, hub.docker.com/r/farmos/farmos.

**Container (values.yaml):**
- `image.repository`: `docker.io/farmos/farmos`
- `image.tag`: `latest@sha256:6e98e57f5216c43d8cfdd3cd7c9b4f842f13da39701450d237ef1400a892decc`
- `image.pullPolicy`: `IfNotPresent`

**Persistence:** `persistence.sitesdirectory`: enabled, `mountPath: /var/www/html/sites` (type and size not set in values).

**Security context (values.yaml):** `securityContext.container`: `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`. No privileged, fsGroup or podSecurityContext in file.

**Service:** `service.main.ports.main`: port 80, tcp, targetPort 80.

**Env, probes:** none in values.yaml (common defaults apply, not fetched).

**Version/asset naming:** chart version 11.0.0; image pinned by digest.

**Gotchas**
- `/var/www/html/sites` is the chart mount point; in the upstream image `/var/www/html` links to `/opt/drupal`, so the upstream sites dir is `/opt/drupal/web/sites`.
- Chart runs as root (uid/gid 0), not rootless.

**Fetch failures:** none.
