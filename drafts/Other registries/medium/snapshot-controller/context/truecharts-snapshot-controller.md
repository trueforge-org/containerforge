# TrueCharts snapshot-controller (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/snapshot-controller/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Deploys the Kubernetes CSI snapshot-controller plus a Snapshot Validation Webhook (chart sources point to kubernetes-csi/external-snapshotter and snapshot-controller/snapshot-controller).
- Chart version 7.0.1, appVersion 8.7.1, kubeVersion >=1.33.0-0, Helm min 3.14, max 4.1.
- Depends on `common` 32.8.5 from oci://oci.trueforge.org/truecharts.

## Image
- repository: registry.k8s.io/sig-storage/snapshot-controller
- tag: v8.7.1@sha256:d3c3893704c86f0fe428a6429c705b7103a653bea151db0fc5ab0fdb25bb2290

## Ports
| Name | Port | Proto | Notes |
| --- | --- | --- | --- |
| main | 8080 | http | metrics/health (`--http-endpoint=:8080`) |
| webhook | 8443 | https | webhook service, disabled by default (`workload.webhook.enabled: false`) |

## Container args (main)
- --http-endpoint=:{{ port 8080 }}
- --leader-election=true
- --leader-election-namespace={{ .Release.Namespace }}

## Webhook args (disabled by default)
- --tlsPrivateKeyFile=/etc/snapshot-validation/tls.key
- --tlsCertFile=/etc/snapshot-validation/tls.crt
- --port=8443

## Probes
- main liveness/readiness/startup: HTTP GET /metrics
- webhook liveness/readiness/startup: HTTPS /readyz on 8443

## RBAC (clusterWide)
- persistentvolumes, nodes, events, persistentvolumeclaims(+update), storageclasses (storage.k8s.io)
- snapshot.storage.k8s.io: volumesnapshotclasses (get/list/watch), volumesnapshotcontents (full CRUD + status patch), volumesnapshots (get/list/watch/update/patch, status update/patch)
- groupsnapshot.storage.k8s.io volumegroupsnapshotclasses (list/watch)
- namespaced Role: coordination.k8s.io leases (get/watch/list/delete/update/create)

## Other
- ServiceMonitor metrics endpoint on port `main` path /metrics.
- Chart icon/home: https://truecharts.org/charts/stable/snapshot-controller

## Gotchas
- Webhook is opt-in; enabling it needs TLS files at /etc/snapshot-validation.
