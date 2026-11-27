# csi-addons docs/deploy-controller.md (main)

Source URL(s): https://raw.githubusercontent.com/csi-addons/kubernetes-csi-addons/main/docs/deploy-controller.md (fetched 2026-11-27)

## Flags (default)
| Flag | Default |
| --- | --- |
| --metrics-bind-address | :8080 |
| --health-probe-bind-address | :8081 |
| --leader-elect | false |
| --reclaim-space-timeout | 3m |
| --max-concurrent-reconciles | 100 |
| --enable-auth | true (SA tokens in headers + TLS) |
| --volume-health-cleanup-interval | 30m |
| --volume-health-stale-threshold | 2h |
- --enable-volume-health-cleanup=false disables cleanup worker. Some options also via configmap csi-addons-config.

## Install paths
- Latest (main): kubectl apply -k "https://github.com/csi-addons/kubernetes-csi-addons/deploy/controller?ref=main" (namespace csi-addons-system). Image quay.io/csiaddons/k8s-controller:latest.
- Versioned: RELEASE=vX ; kubectl create -f releases/download/${RELEASE}/{crds.yaml,rbac.yaml,setup-controller.yaml} (doc example v0.8.0). Recommended path per doc.
- operator-sdk bundle: quay.io/csiaddons/k8s-bundle:latest in namespace storage-csi-addons.
- Kustomize: make deploy.

## Gotchas
- Tag-based -k is not a pinned install; use release assets for pinned.
