# TrueCharts chart: portainer

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/portainer/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/portainer/Chart.yaml
- Fetched 2026-11-27

## What it is
- Helm chart `portainer`, chart version 15.0.0, appVersion 2.45.4.
- Library dependency `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.

## Images
| Edition | Repository | Tag | pullPolicy |
| --- | --- | --- | --- |
| CE | docker.io/portainer/portainer-ce | 2.45.4@sha256:18616fff2998f8ca0e8ebe7f028658ae1682859cf43f212f81a849c1093ad639 | IfNotPresent |
| BE | docker.io/portainer/portainer-ee | 3.1.0@sha256:8fd951c7f9cc63d9cfa953f2127eacbe5a0ac1b2ec5f62a79cddcbcfb1674b5d | IfNotPresent |

## Ports
| Service | Port | Protocol | Target |
| --- | --- | --- | --- |
| main | 10400 | https | 9443 |
| edge | 10401 | (enabled) | 10401 |

## Env vars
- None set. App settings under `portainer`: edge_compute false, snapshot_interval 5m, logo empty.

## Volumes/paths
| Persistence | Mount | Type |
| --- | --- | --- |
| data | /data | PVC |
| cache | /.cache | emptyDir |

## User/UID
- Not set in values (common library defaults not shown; plan.md cites runAsUser 568 and readOnlyRootFilesystem true, not verified here).
- automountServiceAccountToken true; ServiceAccount `main` enabled; RBAC `main` clusterWide with `*` on apiGroups/resources/verbs.

## Probes
- liveness, readiness, startup: HTTPS on port 9443.

## Gotchas
- Chart grants cluster-wide RBAC with wildcard verbs (Kubernetes-side, not container).
- Chart ships a BE (portainer-ee 3.1.0) image reference alongside CE; the container build in this repo is CE only.
