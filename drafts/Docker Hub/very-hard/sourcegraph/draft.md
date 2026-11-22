# sourcegraph

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: very-hard
- **Chart**: sourcegraph
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/sourcegraph
- **Source repository**: https://github.com/sourcegraph/sourcegraph
- **Documentation**: https://sourcegraph.com/docs

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/sourcegraph/server

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Guess: no public Dockerfile or binaries exist, so no runtime is clearly needed and ubuntu is a default.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 7080/http (web UI), 7443/https (inferred), 3178/tcp (gitserver, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/sourcegraph
- non-root: possible - chart sets runAsUser and runAsGroup 0; the draft cannot be rebuilt, so this is only a runtime guess
- read-only-rootfs: no - chart sets false and the app writes state to /var/opt/sourcegraph and /etc/sourcegraph
- privileged: unknown - not in values
- other-security: extra service ports 2633 (admin console) and 3370 (grafana); no caps or hostNetwork shown
- extra-persistence: /var/opt/sourcegraph pvc and /etc/sourcegraph pvc (chart)
- confidence: low

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: The upstream image is a large multi-service monolith, so it needs substantial CPU and RAM and may depend on services outside the single container (inferred).
- caveat: No public Dockerfile exists, and the source is no longer open, so the image can only be run as published and cannot be rebuilt here.
- caveat: Initial admin setup, licence and site configuration are done in the web UI after the first start (inferred).
- caveat: Only amd64 images are published, so arm64 hosts cannot run it.

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: sourcegraph
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/sourcegraph/server:6.12.5040`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

`-` means no public Dockerfile could be found.

- **Dockerfile**: -

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/sourcegraph/sourcegraph)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`very-hard`: closed source with no redistributable artifact, or kernel/host-level tools.

- **Difficulty**: very-hard

### Reason

- **Reason**: Sourcegraph 6.x is a large multi-service monolith (frontend, gitserver, searcher, Postgres, Redis) and the code is no longer open source. No public Dockerfile or standalone binaries are available, only Docker images, so it cannot realistically be rebuilt on containerforge-ubuntu.

### amd64 / arm64

How we get the application for that architecture.

- `no`: neither works for that architecture, for example closed-source software where the vendor only ships an amd64 executable.

- **amd64**: no
- **arm64**: no

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [sourcegraph/server:6.12.5040](https://hub.docker.com/r/sourcegraph/server)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
