# csi-addons.github.io + github.com/csi-addons/kubernetes-csi-addons (repo page)

Source URL(s): https://csi-addons.github.io ; https://github.com/csi-addons/kubernetes-csi-addons (WebFetch, fetched 2026-11-27; repo page fetched after one transient EAI_AGAIN on releases page)

## What it is
- CSI-Addons: extends CSI with DR, performance and operations (volume replication, reclaim space, network fencing, volume groups, encryption key rotation, identity). Controller manager + sidecar in CSI driver pods. License Apache-2.0.
- Sidecar registers itself via CSIAddonsNode CR.
- Manager and sidecar have --enable-auth (SA token headers + TLS on manager; sidecar self-signed certs and TokenReview).

## CRDs
CSIAddonsNode, EncryptionKeyRotationCronJob, EncryptionKeyRotationJob, NetworkFence, NetworkFenceClass, ReclaimSpaceCronJob, ReclaimSpaceJob, VolumeGroupReplication, VolumeGroupReplicationClass, VolumeGroupReplicationContent, VolumeReplicationClass.

## Install (site, example release v0.14.0)
- kubectl create -f .../releases/download/${RELEASE}/crds.yaml ; rbac.yaml ; setup-controller.yaml
- Kustomize: git clone repo; cd; make deploy
- OperatorSDK: kubectl create namespace storage-csi-addons ; operator-sdk run bundle -n storage-csi-addons quay.io/csiaddons/k8s-bundle:latest

## Gotchas
- Site example version (v0.14.0) differs from chart appVersion 0.15.0. Not a plan fact; noted only.
- Repo page does not state default namespace or ports; see deploy doc.
