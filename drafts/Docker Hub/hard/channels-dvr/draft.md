# channels-dvr

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: channels-dvr
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/channels-dvr
- **Website**: https://getchannels.com/
- **Documentation**: https://getchannels.com/docs/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/fancybits/channels-dvr

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Vendor Linux package with no language runtime needed.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none (vendor .deb, dependencies unknown)
- python/pip: none
- node/npm: none
- other: vendor Linux package from getchannels.com (closed source; tve variant)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8089/http (web UI)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/channels-dvr
- non-root: possible - no securityContext override, runAsUser 568 default; tuner and network device access may need more
- read-only-rootfs: yes - default readOnlyRootFilesystem true
- privileged: no - not set, common default false; tuner device access (draft) is not in values
- other-security: tuner and network device access (draft, not in values)
- extra-persistence: /shares/DVR (pvc, recordings; chart mount)
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: channels-dvr
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/fancybits/channels-dvr:latest, tve`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

`-` means no public Dockerfile could be found.

- **Dockerfile**: -

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://getchannels.com/)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://getchannels.com/dvr/)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Closed-source commercial Channels DVR with two image variants, tve and standard. It is downloadable from the vendor as a Linux package, so it is not very-hard. It also needs tuner and network device access, which is hard for a rootless read-only image.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [fancybits/channels-dvr:latest](https://hub.docker.com/r/fancybits/channels-dvr)
- **copy-from arm64**: [fancybits/channels-dvr:latest](https://hub.docker.com/r/fancybits/channels-dvr)

### Dependency containers

- **Dependency containers**: none
