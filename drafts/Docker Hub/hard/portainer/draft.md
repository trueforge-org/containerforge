# portainer

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: portainer
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/portainer
- **Source repository**: https://github.com/portainer/portainer
- **Documentation**: https://docs.portainer.io/
- **Website**: https://www.portainer.io/

## Potentially relevant resources

- **Website**: https://docs.portainer.io/start/install-ce/server
- **Website**: https://docs.portainer.io/start/install/server
- **Container image**: https://hub.docker.com/r/portainer/portainer-ce
- **Container image**: https://hub.docker.com/r/portainer/portainer-ee

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Vendor binary extracted from an official image and installed on ubuntu.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: Portainer EE binary and UI extracted from portainer/portainer-ee image (/portainer and /public), licence restricted

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 9000/http (web UI), 9443/https (web UI TLS), 8000/tcp (edge agent tunnel)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/portainer
- non-root: yes - common runAsUser 568 default, no root override in values
- read-only-rootfs: yes - common default readOnlyRootFilesystem true, no override
- privileged: no - not set in values (default false)
- other-security: none
- extra-persistence: /data (pvc), /.cache (emptyDir)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the Business Edition is license-restricted, so a valid Portainer license is needed for paid features and redistribution of the extracted binary is not allowed.
- caveat: the container needs the Docker socket and a writable /data volume, which means host-level Docker access.
- caveat: there is no arm64 build; the Community Edition may be the practical option if arm64 is needed (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: portainer
- **Role**: sidecar (beImage)

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/portainer/portainer-ee:3.1.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

`-` means no public Dockerfile could be found.

- **Dockerfile**: -

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/portainer/portainer)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Closed-source Portainer Business Edition; no public Dockerfile. Binary and UI could be extracted from the official image but redistribution is licence-restricted, and it needs the Docker socket and /data. A CE sibling is the practical alternative.

### amd64 / arm64

How we get the application for that architecture.

- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.

- **amd64**: no
- **arm64**: no

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

A path in backticks is where the binary sits inside the image.

- **copy-from amd64**: [portainer/portainer-ee:latest](https://hub.docker.com/r/portainer/portainer-ee) (`/portainer and /public`)
- **copy-from arm64**: [portainer/portainer-ee:latest](https://hub.docker.com/r/portainer/portainer-ee) (`/portainer and /public`)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

- **Dependency containers**: -
