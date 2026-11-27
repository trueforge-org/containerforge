# TrueCharts chart: headlamp

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/headlamp/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/headlamp/Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `headlamp` version 3.0.0, `appVersion: 0.46.0`. Kubernetes web UI. Deployment workload.

## Image
- Main: `ghcr.io/headlamp-k8s/headlamp` tag `v0.46.0@sha256:8a0ef97527544baa2b35825940ddf4db6e2d09c30cd5aa31fd269ff604cc8b75`, `pullPolicy: IfNotPresent`.
- Plugin init image: `oci.trueforge.org/containerforge/node` tag `rolling@sha256:ed253825019523201cd05d3e4086248649e8d236ccfd184ce6cb29f18bda5f00` (repo-internal node image, not web-fetched).

## Chart values (headlamp)
| Key | Value |
| --- | --- |
| inCluster | `true` |
| inClusterContextName | `main` |
| sessionTTL | `86400` |
| logLevel | `info` |
| auth.proxy.enabled | `false` (headers X-Forwarded-username/groups/email/Id-Token) |
| auth.unsafeServiceToken.enabled | `false` (allowEditing `false`) |
| plugins.flux | enabled, source artifacthub `headlamp_flux`, version 0.7.0 |
| plugins.certManager | enabled, source artifacthub `headlamp_cert-manager`, version 0.1.0 |

## Args passed to container (main)
- `-port={{targetPort}}` (4466), `-plugins-dir=/headlamp/plugins`, `-in-cluster=true`, `-in-cluster-context-name=main`, `-session-ttl=86400`, `-log-level=info`, `-unsafe-use-service-account-token=<rbac.main.enabled>`, `-proxy-auth-*-header`, `-proxy-auth=false`.

## Init container
- `download-plugins` (imageSelector `pluginImage`): `npx --yes @headlamp-k8s/pluginctl@latest install --config <plugins.yaml> --folderName /headlamp/plugins`. Uses `NPM_CONFIG_CACHE=/tmp/npm-cache`.

## Ports
- Service `main`: port `80` -> targetPort `4466`, protocol http.

## Volumes/paths
- `config`: emptyDir, Memory, mountPath `/.config`.
- `plugins`: emptyDir, Memory, mountPath `/headlamp/plugins`.
- `pluginconfig`: configmap `pluginconfig` key `plugins.yaml` -> `/headlamp/plugins/plugins.yaml` (read-only).

## Config files
- configmap `pluginconfig` `plugins.yaml` generated from enabled `headlamp.plugins` (name kebab-case, source, version).

## User/UID
- Not set in values. Upstream Dockerfile runs as user `headlamp` (see GitHub file).

## RBAC / SA
- ServiceAccount `main` (primary). RBAC `main` only enabled when `unsafeServiceToken.enabled` and `inCluster` are true; then `clusterWide: true` rules on apiGroups/resources `*` with verbs get, list, and `*` or `watch` (per allowEditing).

## Healthcheck
- Liveness, readiness, startup: HTTP on targetPort 4466.

## Other
- `podOptions.automountServiceAccountToken: true`, `priorityClassName: system-cluster-critical`.
- Workload type Deployment.

## Gotchas
- Chart plugin install depends on `npx @headlamp-k8s/pluginctl@latest` (unpinned at runtime).
- Chart uses `targetPort` 4466; service port 80.
