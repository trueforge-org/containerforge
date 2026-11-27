# TrueCharts csi-addons-controller (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/csi-addons-controller/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- CSI-Addons controller (manager) for Kubernetes. Chart version 4.0.0, appVersion 0.15.0. Depends on common 32.8.5 (oci://oci.trueforge.org/truecharts). kubeVersion >=1.33.0-0.
- Chart sources: github csi-addons/kubernetes-csi-addons, kubernetes-csi/external-snapshotter, quay.io/csiaddons/k8s-controller.

## Image
- repository: quay.io/csiaddons/k8s-controller
- tag: v0.15.0@sha256:e158b96957b9f6a4513129139d7d4f9eba147a4e05ac3ab3676671ef787d518c
- command: /csi-addons-manager

## Args (main)
- --namespace={{ .Release.Namespace }} ; --leader-elect ; --automaxprocs
- --reclaim-space-timeout=3m ; --max-concurrent-reconciles=100 ; --max-group-pvc=100 ; --schedule-precedence=pvc (pvc or storageclass)
- --health-probe-bind-address=:8081 ; --metrics-bind-address=:8080 ; --metrics-secure=false

## Ports
| Name | Port | Notes |
| --- | --- | --- |
| main | 8080 | metrics (metrics-bind-address) |
| health | 8081 | probes (not a chart service; bound by manager) |

## Probes
- liveness: GET /healthz :8081 ; readiness: GET /readyz :8081 ; startup: GET /metrics port main

## Resources
- limits cpu 1000m, memory 512Mi ; requests cpu 10m, memory 64Mi

## RBAC
- leader-election (namespaced): configmaps, leases, events
- manager (clusterWide): events, namespaces, pods, PVCs, PVs, leases (read), and csiaddons.openshift.io CRs (csiaddonsnodes, networkfences, reclaimspace*, encryptionkeyrotation*), replication.storage.openshift.io volume replication resources
- networkfenceclass editor/viewer roles (csiaddons.openshift.io)

## Other
- ServiceMonitor on port main, path /metrics.
- automountServiceAccountToken true.

## Gotchas
- Chart runs manager with --metrics-secure=false.
- Startup probe uses /metrics; liveness/readiness use port 8081.
