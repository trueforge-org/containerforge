# kubelet-csr-approver

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: kubelet-csr-approver
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/kubelet-csr-approver
- **Source repository**: https://github.com/postfinance/kubelet-csr-approver

## Potentially relevant resources

- **Container image**: https://ghcr.io/postfinance/kubelet-csr-approver
- **Source code repository**: https://github.com/kubelet-csr-approver/kubelet-csr-approver

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Small compiled Go controller binary.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: kubelet-csr-approver
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/postfinance/kubelet-csr-approver:v1.2.16`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

`-` means no public Dockerfile could be found.

- **Dockerfile**: -

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/postfinance/kubelet-csr-approver)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: The controller is a small Go binary that upstream builds only through ko, so there is no release binary to reuse. We would compile the cmd package in a golang stage and copy it onto containerforge-ubuntu, running as a non-root user. Cluster RBAC and kube-API certificates are deployment concerns, not image ones.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/postfinance/kubelet-csr-approver:v1.2.16](https://ghcr.io/postfinance/kubelet-csr-approver)
- **copy-from arm64**: [ghcr.io/postfinance/kubelet-csr-approver:v1.2.16](https://ghcr.io/postfinance/kubelet-csr-approver)

### Dependency containers

- **Dependency containers**: none
