# Intel Device Plugins for Kubernetes (project README)

Source URL(s): https://raw.githubusercontent.com/intel/intel-device-plugins-for-kubernetes/main/README.md. Fetched 2026-11-26.

## What it is
- Framework for Kubernetes device plugins plus implementations: GPU, QAT, SGX, DSA, IAA, NPU.
- Prereqs: hardware/drivers, configured K8s cluster, Go >= 1.16 (dev).

## Images / tags
- Pre-built images on Docker Hub. `main` builds pushed as `devel`.
- Release images tagged `x.y.z` (e.g. `0.36.0`); branches `release-0.NN`; tags `vX.Y.Z`.
- Release images (not devel) signed keylessly with cosign (since 0.31); since 0.36 cosign v3 bundles via OCI referrers.

## Kubernetes support
- release-0.36 -> K8s 1.36; release-0.35 -> 1.35; release-0.34 -> 1.33-1.34; release-0.32 and older unsupported.
- Device plugin v1 API GA.

## Deployment
- Unified operator (CRDs per plugin); operatorhub.io; OpenShift catalog.
- Helm charts in separate repo: `https://intel.github.io/helm-charts`.
- Default `imagePullPolicy: IfNotPresent`; change via `scripts/set-image-pull-policy.sh`.

## Other
- Images carry license texts under `/licenses`.
- Developer guide: DEVEL.md.
