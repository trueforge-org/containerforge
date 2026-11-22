# kubernetes-reflector

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: kubernetes-reflector
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/kubernetes-reflector
- **Source repository**: https://github.com/emberstack/kubernetes-reflector

## Potentially relevant resources

- **Container image**: https://ghcr.io/emberstack/kubernetes-reflector

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: .NET controller, so the .NET runtime is installed on ubuntu.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: dotnet-sdk-10.0 (Microsoft repo, inferred), aspnetcore-runtime-10.0 (Microsoft repo, inferred)
- python/pip: none
- node/npm: none
- other: none (built from source with dotnet publish)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (health endpoint, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/kubernetes-reflector
- non-root: yes - chart sets runAsNonRoot true and inherits runAsUser 568 default
- read-only-rootfs: yes - chart sets readOnlyRootFilesystem true
- privileged: no - not set in values
- other-security: automountServiceAccountToken true; ClusterRole rules for reading and watching secrets and configmaps across namespaces (API access, not a host capability)
- extra-persistence: none
- confidence: high

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: kubernetes-reflector
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/emberstack/kubernetes-reflector:10.0.80`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/emberstack/kubernetes-reflector/blob/b26ca679e185e5da9c2ae100ea049e251701c606/src/ES.Kubernetes.Reflector/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/emberstack/kubernetes-reflector)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Small .NET 10 controller built with dotnet publish and run on the aspnet runtime. ContainerForge has no .NET stack, so a new runtime base would have to be added. It is a single process talking to the Kubernetes API, and there is no upstream binary artifact to reuse.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/emberstack/kubernetes-reflector:10.0.80](https://ghcr.io/emberstack/kubernetes-reflector)
- **copy-from arm64**: [ghcr.io/emberstack/kubernetes-reflector:10.0.80](https://ghcr.io/emberstack/kubernetes-reflector)

### Dependency containers

- **Dependency containers**: none
