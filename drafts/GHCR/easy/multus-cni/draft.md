# multus-cni

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: multus-cni
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/multus-cni
- **Source repository**: https://github.com/containernetworking/plugins

## Potentially relevant resources

- **Container image**: https://ghcr.io/k8snetworkplumbingwg/multus-cni
- **Container image**: https://ghcr.io/siderolabs/cni
- **Source code repository**: https://github.com/k8snetworkplumbingwg/multus-cni
- **Container image**: https://hub.docker.com/r/alpine/crane

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Static Go CNI plugin binaries delivered as files, no runtime needed.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: containernetworking plugins release tarball (cni-plugins-linux-<arch>-v1.9.0.tgz)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: none

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/multus-cni
- non-root: no - chart runs privileged installer containers as runAsUser 0 and writes host CNI directories
- read-only-rootfs: possible - common default readOnlyRootFilesystem true, but the hostPath mounts must be writable
- privileged: yes - chart sets privileged true on its installer containers
- other-security: hostNetwork true, hostPID true, hostPath mounts of / , /run, /run/netns, /run/k8s.cni.cncf.io, /var/lib/kubelet, /opt/cni/bin, /etc/cni/net.d, /var/lib/cni/multus
- extra-persistence: hostPath /opt/cni/bin (the draft's target), /etc/cni/net.d, /var/lib/cni/multus, and the host paths above (hostPath)
- confidence: medium (the chart's privileged workloads may use a different image than this file-only bundle)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: multus-cni
- **Role**: sidecar (talosCniImage)

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/siderolabs/cni:v1.14.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/siderolabs/pkgs/blob/main/cni/pkg.yaml)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/containernetworking/plugins)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/containernetworking/plugins/releases/download/v1.9.0/cni-plugins-linux-amd64-v1.9.0.tgz) · [arm64](https://github.com/containernetworking/plugins/releases/download/v1.9.0/cni-plugins-linux-arm64-v1.9.0.tgz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Bundle of containernetworking plugins copied to /opt/cni/bin; the ContainerForge cni-plugins sibling already does this. Static Go binaries, just file delivery; needs root only on the host side when installed.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/siderolabs/cni:v1.14.0](https://ghcr.io/siderolabs/cni)
- **copy-from arm64**: [ghcr.io/siderolabs/cni:v1.14.0](https://ghcr.io/siderolabs/cni)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

- **Dependency containers**: -
