# kubernetes-csi docs: external-snapshotter.html

Source URL(s): https://kubernetes-csi.github.io/docs/external-snapshotter.html (fetched 2026-11-27, via WebFetch summary)

## What it is
- CSI sidecar: watches VolumeSnapshotContent and calls CSI CreateSnapshot / DeleteSnapshot / ListSnapshots.
- With --enable-volume-group-snapshots also watches VolumeGroupSnapshotContent (CreateVolumeGroupSnapshot / DeleteVolumeGroupSnapshot / GetVolumeGroupSnapshot).
- Status GA v4.0.0+. Repo: https://github.com/kubernetes-csi/external-snapshotter

## CRDs
- VolumeSnapshot, VolumeSnapshotContent, VolumeSnapshotClass
- VolumeGroupSnapshot, VolumeGroupSnapshotContent, VolumeGroupSnapshotClass

## Flags / settings
- --enable-volume-group-snapshots
- --extra-create-metadata (v4.0.0+): adds csi.storage.k8s.io/volumesnapshot/name, .../volumesnapshot/namespace, .../volumesnapshotcontent/name
- Reserved class keys: csi.storage.k8s.io/snapshotter-secret-name and -namespace (v1.0.1+); snapshotter-list-secret-name and -namespace (v2.1.0+)

## Supported versions
| Version | Min K8s | Min CSI spec |
| --- | --- | --- |
| v8.2.0 | 1.25 | 1.11.0 |
| v8.1.0 | 1.25 | 1.11.0 |
| v8.0.2 | 1.25 | 1.9.0 |

## Images listed
- registry.k8s.io/sig-storage/csi-snapshotter:v8.2.0
- registry.k8s.io/sig-storage/snapshot-validation-webhook:v8.1.0 (v8.1.0 and v8.0.2)

## Gotchas
- No install commands on this page; refers to README and release-6.2 example YAML.
- Drivers must advertise CREATE_DELETE_SNAPSHOT (and CREATE_DELETE_GET_VOLUME_GROUP_SNAPSHOT for group snapshots).
