# kubernetes-csi/external-snapshotter README (master)

Source URL(s): https://raw.githubusercontent.com/kubernetes-csi/external-snapshotter/master/README.md (fetched 2026-11-27; output truncated at ~4 KB)

## What it is
- CSI snapshotter: CSI sidecar implementing volume snapshot and volume group snapshot features.
- Volume snapshot GA in Kubernetes 1.20; supports CSI v1.0+.
- Volume group snapshot: alpha in Kubernetes 1.27, needs CSI v1.10.0+; disabled by default, enabled via command-line option.
- Snapshot controller and external-snapshotter both use the controller/informer pattern.

## Compatibility table (README, outdated)
- Lists k8s.gcr.io/sig-storage/csi-snapshotter, snapshot-controller, snapshot-conversion-webhook with min K8s 1.20. Registry path is stale (current is registry.k8s.io).
- v1beta1 snapshot CRDs deprecated since csi-snapshotter 4.1; v1 CRDs required.
- With volume group snapshots enabled, controllers need v1beta2 volumegroupsnapshot CRDs.

## Gotchas
- Table and registry names are stale; use the release-tag files and docs pages for current versions.
