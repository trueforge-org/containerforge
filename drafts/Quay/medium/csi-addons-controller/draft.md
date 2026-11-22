# csi-addons-controller

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Quay
- **Difficulty**: medium
- **Chart**: csi-addons-controller
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/csi-addons-controller
- **Source repository**: https://github.com/csi-addons/kubernetes-csi-addons
- **Website**: https://csi-addons.github.io/

## Potentially relevant resources

- **Source code repository**: https://github.com/kubernetes-csi/external-snapshotter
- **Container image**: https://quay.io/csiaddons/k8s-controller

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go Kubernetes controller compiled from source.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: Go modules, compile from source

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (metrics, inferred), 8081/http (health probe, inferred), 9443/https (webhook, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/csi-addons-controller
- non-root: yes - no securityContext override, common default 568
- read-only-rootfs: yes - common default readOnlyRootFilesystem true; no runtime state
- privileged: no - not set, common default false
- other-security: none in container security; automountServiceAccountToken true; broad cluster-wide RBAC for PVCs and csiaddons resources
- extra-persistence: none
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: only useful inside a Kubernetes cluster with a CSI driver and the csi-addons CRDs installed (inferred)
- caveat: the webhook uses TLS, so a certificate must be provided, typically by cert-manager (inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: csi-addons-controller
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `quay.io/csiaddons/k8s-controller:v0.15.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/csi-addons/kubernetes-csi-addons/blob/c92032331fe7fb165dd1a40dfb7ebb6c83a3b5cb/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/csi-addons/kubernetes-csi-addons)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Go Kubernetes controller built from source and run on distroless nonroot, so it is rootless and cluster-only. Compile it per arch with a Go build stage on the Ubuntu base; modest single-binary build.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [quay.io/csiaddons/k8s-controller:v0.15.0](https://quay.io/repository/csiaddons/k8s-controller)
- **copy-from arm64**: [quay.io/csiaddons/k8s-controller:v0.15.0](https://quay.io/repository/csiaddons/k8s-controller)

### Dependency containers

- **Dependency containers**: none
