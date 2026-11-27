# kubernetes-csi docs: snapshot-controller.html

Source URL(s): https://kubernetes-csi.github.io/docs/snapshot-controller.html (fetched 2026-11-27, via WebFetch summary)

## What it is
- Snapshot controller: watches VolumeSnapshot and VolumeSnapshotContent (and VolumeGroupSnapshot / VolumeGroupSnapshotContent when group snapshots are enabled).
- Needed separately from the CSI sidecar for beta/GA snapshot features.

## Install steps (as documented; page refers to release-6.2 branch)
```
git clone https://github.com/kubernetes-csi/external-snapshotter/
cd ./external-snapshotter
git checkout release-6.2
kubectl kustomize client/config/crd | kubectl create -f -
kubectl -n kube-system kustomize deploy/kubernetes/snapshot-controller | kubectl create -f -
```
- Installs into namespace kube-system in the example.
- CRDs come from client/config/crd.

## Flags
- --enable-volume-group-snapshots (enables group snapshot watching). No defaults listed.

## Other
- No RBAC rules, ports, or metrics endpoint given; refers to upstream README.
- Image listed: registry.k8s.io/sig-storage/snapshot-controller:v8.2.0.
- Supported table: v8.2.0, v8.1.0, v8.0.2. Minimum Kubernetes v1.25.

## Gotchas
- Page is stale: release-6.2 checkout and v8.2.0 image vs current v8.7.1.
