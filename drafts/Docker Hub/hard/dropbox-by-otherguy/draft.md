# dropbox-by-otherguy

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: dropbox-by-otherguy
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/dropbox-by-otherguy
- **Website**: https://www.dropbox.com/install
- **Documentation**: https://help.dropbox.com/
- **Website**: https://www.dropbox.com/

## Potentially relevant resources

- **Source code repository**: https://github.com/otherguy/docker-dropbox
- **Container image**: https://hub.docker.com/r/otherguy/dropbox

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Closed-source vendor daemon downloaded at runtime with no language runtime.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: Dropbox vendor daemon tarball (amd64 only, downloaded at runtime); monitor script from otherguy/docker-dropbox

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 17500/http (inferred, Dropbox web UI)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/dropbox-by-otherguy
- non-root: no - runAsUser 0, runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: none in values
- extra-persistence: /opt/dropbox/.dropbox, /opt/dropbox/Dropbox (chart persistence, type not shown)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the Dropbox daemon is amd64 only and is downloaded at runtime, so arm64 is not supported and first start needs internet.
- caveat: the account must be linked to the daemon through its web setup before any sync happens (manual setup, account needed).
- caveat: the image tracks latest and the closed-source daemon updates without notice, so behaviour can change between pulls.

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: dropbox-by-otherguy
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/otherguy/dropbox:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/otherguy/docker-dropbox/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://www.dropbox.com/install)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://www.dropbox.com/download?plat=lnx.x86_64)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: The Dockerfile only sets up a user, an entrypoint and a monitor script, and the Dropbox daemon is downloaded at runtime. That daemon is a closed-source vendor binary that writes to its own paths and needs root-like setup, so it needs rework.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.

- **amd64**: yes
- **arm64**: no

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [otherguy/dropbox:latest](https://hub.docker.com/r/otherguy/dropbox)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
