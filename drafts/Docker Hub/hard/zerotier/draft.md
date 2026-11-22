# zerotier

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: zerotier
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/zerotier
- **Source repository**: https://github.com/zerotier/ZeroTierOne
- **Documentation**: https://docs.zerotier.com/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/zerotier/zerotier

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Network daemon installed from its apt repository on ubuntu.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: zerotier-one (ZeroTier apt repo), iproute2 (inferred)
- python/pip: none
- node/npm: none
- other: ZeroTier apt repository and signing key

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 9993/udp (peer transport)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/zerotier
- non-root: no - chart sets runAsUser 0, runAsGroup 0, runAsNonRoot false
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - default false; NET_ADMIN is added instead
- other-security: capability NET_ADMIN added; hostPath /dev/net/tun mounted
- extra-persistence: /var/lib/zerotier-one (pvc, config), /dev/net/tun (hostPath device)
- confidence: high

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: zerotier
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/zerotier/zerotier:1.14.2`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/zerotier/ZeroTierOne/blob/185a3a2c76e6bf1b1c0415871f43076638eb007c/Dockerfile.release)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/zerotier/ZeroTierOne)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:zerotier-one`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Runs zerotier-one as root and needs /dev/net/tun plus NET_ADMIN to create the virtual network interface, so this is a device and privilege case. The package installs from ZeroTier's apt repo on ubuntu with no compile, but the capability needs make it hard.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [zerotier/zerotier:1.14.2](https://hub.docker.com/r/zerotier/zerotier)
- **copy-from arm64**: [zerotier/zerotier:1.14.2](https://hub.docker.com/r/zerotier/zerotier)

### Dependency containers

- **Dependency containers**: none
