# csi-addons/kubernetes-csi-addons Makefile (main, raw)

Source URL(s): https://raw.githubusercontent.com/csi-addons/kubernetes-csi-addons/main/Makefile (fallback after api.github.com contents call was rate-limited; fetched 2026-11-27, grep excerpt)

- CONTROLLER_IMG ?= quay.io/csiaddons/k8s-controller ; CONTROLLER_IMG := $(CONTROLLER_IMG):$(TAG)
- GO_PROJECT=github.com/csi-addons/kubernetes-csi-addons
- CONTAINER_CMD prefers podman, falls back to docker.
- Targets: manifests (controller-gen + kustomize), build (generate fmt vet build-manager build-sidecar build-tool), deploy (manifests then apply to cluster from ~/.kube/config).
- Full build/tag variables not captured by the grep excerpt.
