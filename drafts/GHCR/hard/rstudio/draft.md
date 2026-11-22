# rstudio

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: rstudio
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/rstudio
- **Source repository**: https://github.com/rstudio/rstudio

## Potentially relevant resources

- **Container image**: https://ghcr.io/rocker-org/rstudio
- **Source code repository**: https://github.com/rocker-org/rocker-versioned2

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: R and rserver installed from system packages, so ubuntu fits.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: r-base (inferred)
- python/pip: none
- node/npm: none
- other: rstudio-server .deb from posit.co (no Ubuntu archive package)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8787/http (RStudio Server web UI)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/rstudio
- non-root: no - chart sets runAsUser 0 and runAsGroup 0; GROUPID from fsGroup
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set in values
- other-security: none in values; draft notes rserver spawns per-user sessions with PAM
- extra-persistence: /home/rstudio/.config/rstudio (config, pvc chart default); /home/rstudio/workspace (workspace, pvc chart default)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: RStudio Server logs in through PAM against system users, so each login user must exist inside the container, which is hard to do rootless (inferred)
- caveat: the rstudio-server .deb is downloaded from posit.co at build time, so the build needs that site reachable (inferred)
- caveat: per-user rsession processes write under /home/rstudio, which conflicts with a read-only rootfs (inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: rstudio
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/rocker-org/rstudio:4.6.2`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/rocker-org/rocker-versioned2/blob/500642d/dockerfiles/rstudio_4.6.2.Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/rstudio/rstudio)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://posit.co/download/rstudio-server/)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: RStudio Server needs R plus the rserver daemon, which spawns per-user rsession processes and authenticates through PAM. That makes a multi-process image that expects system users and writable system paths. Running it rootless and read-only is significant work even though the vendor package exists.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/rocker-org/rstudio:4.6.2](https://ghcr.io/rocker-org/rstudio)
- **copy-from arm64**: [ghcr.io/rocker-org/rstudio:4.6.2](https://ghcr.io/rocker-org/rstudio)

### Dependency containers

- **Dependency containers**: none
