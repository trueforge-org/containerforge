# flexo

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: flexo
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/flexo
- **Source repository**: https://github.com/nroi/flexo
- **Documentation**: https://github.com/nroi/flexo/wiki

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/nroi/flexo

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Rust binary compiled with cargo.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: cargo, rustc, pkg-config, libssl-dev (all inferred, build only)
- python/pip: none
- node/npm: none
- other: Rust crate deps via cargo from nroi/flexo 1.6.14 source

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 7878/http (inferred, Arch mirror cache)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/flexo
- non-root: possible - no securityContext override, common default 568 applies
- read-only-rootfs: possible - common default true, no override; cache at /var/cache/flexo and /tmp per draft
- privileged: no - not set, common default false
- other-security: none in values
- extra-persistence: /var/cache/flexo as emptyDir (chart persistence, size 10Gi)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the cache is an emptyDir of 10Gi in the chart, so cached packages are lost whenever the pod restarts.
- caveat: flexo is only useful once Arch clients are pointed at it, so client configuration is a manual step.

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: flexo
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/nroi/flexo:1.6.14`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

`-` means no public Dockerfile could be found.

- **Dockerfile**: -

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/nroi/flexo)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: No production Dockerfile exists in the repo, only test fixtures. Flexo is a Rust Arch package cache proxy, so it has to be compiled from source with cargo and written with its own cache layout, which must map to /config and /tmp.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [nroi/flexo:1.6.14](https://hub.docker.com/r/nroi/flexo)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
