# apache-musicindex

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: apache-musicindex
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/apache-musicindex
- **Website**: https://packages.ubuntu.com/resolute/libapache2-mod-musicindex

## Potentially relevant resources

- **Container image**: https://ghcr.io/k8s-at-home/apache-musicindex

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Apache with an apt-installed module, so no language runtime base is needed.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: apache2 (inferred), libapache2-mod-musicindex
- python/pip: none
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 80/http (Apache, inferred), 443/https (Apache TLS, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/apache-musicindex
- non-root: no - chart sets runAsNonRoot false, runAsUser 0, runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, default false
- other-security: none
- extra-persistence: none
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: no public Dockerfile exists for the image, so it cannot be rebuilt from upstream source (upstream status, per draft)
- caveat: the music library must be mounted read-only into the container and the module must be able to read it (data gotcha, inferred)
- caveat: the Apache config must be rewritten for a read-only rootfs and a non-root user, which is manual work (inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: apache-musicindex
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/k8s-at-home/apache-musicindex:v1.4.1-2`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

`-` means no public Dockerfile could be found.

- **Dockerfile**: -

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://packages.ubuntu.com/resolute/libapache2-mod-musicindex)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:libapache2-mod-musicindex`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Apache mod_musicindex music streaming module; the k8s-at-home Dockerfile is gone so there is no public source for this image. It would be Apache plus the Ubuntu libapache2-mod-musicindex package on containerforge-ubuntu, rootless on a read-only rootfs with a rewritten config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/k8s-at-home/apache-musicindex:v1.4.1-2](https://ghcr.io/k8s-at-home/apache-musicindex)
- **copy-from arm64**: [ghcr.io/k8s-at-home/apache-musicindex:v1.4.1-2](https://ghcr.io/k8s-at-home/apache-musicindex)

### Dependency containers

- **Dependency containers**: none
