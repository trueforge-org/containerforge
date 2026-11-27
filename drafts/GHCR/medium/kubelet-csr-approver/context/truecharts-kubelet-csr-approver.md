# TrueCharts chart: kubelet-csr-approver

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/kubelet-csr-approver/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- "Automatically approve internal Kubelet Certificate Signing Requests". Chart 5.0.0, `appVersion 1.2.16`. Category operators.
- Dependency `common` 32.8.5 (oci://oci.trueforge.org/truecharts).
- Sources: ghcr.io/postfinance/kubelet-csr-approver, github.com/kubelet-csr-approver/kubelet-csr-approver (chart source, see Gotchas).

## Image
- Repository `ghcr.io/postfinance/kubelet-csr-approver`
- Tag `v1.2.16@sha256:3a09df2f9e1e628863fccbe5479e63b11bbc1f411c82134ee975778e1a25b5e6`, pullPolicy IfNotPresent.

## Ports
| Name | Port | Use |
| --- | --- | --- |
| main | 8080 | metrics (`-metrics-bind-address :8080`), servicemonitor `/metrics` |
| probe | 8081 | `-health-probe-bind-address :8081`, probes `/healthz` |

## Args
- `-metrics-bind-address :8080`, `-health-probe-bind-address :8081`, `-level 0`.

## Env vars (chart)
| Name | Value |
| --- | --- |
| PROVIDER_REGEX | `.*` |
| BYPASS_DNS_RESOLUTION | true |
| IGNORE_NON_SYSTEM_NODE | false |
| ALLOWED_DNS_NAMES | 1 |
| BYPASS_HOSTNAME_CHECK | false |
| LEADER_ELECTION | true |

## Probes
- liveness, readiness, startup: HTTP `/healthz` on port 8081.

## Workload
- replicas 3. Chart uses cluster-wide RBAC.
- RBAC rules: coordination.k8s.io leases (create, get, update); events (create); certificates.k8s.io certificatesigningrequests (get, list, watch); certificatesigningrequests/approval (update); signers `kubernetes.io/kubelet-serving` (approve).
- serviceAccount enabled. automountServiceAccountToken true. `operator.register: true`. `manifestManager.enabled: false`.

## Metrics
- ServiceMonitor on port `main`, path `/metrics`. PrometheusRule disabled.

## Gotchas
- Chart's `sources` list points at the kubelet-csr-approver GitHub org, but the image is built from postfinance (see GitHub file).
- Chart runs replicas 3 with LEADER_ELECTION true.
