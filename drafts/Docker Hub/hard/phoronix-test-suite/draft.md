# phoronix-test-suite

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: phoronix-test-suite
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/phoronix-test-suite
- **Source repository**: https://github.com/phoronix-test-suite/phoronix-test-suite
- **Documentation**: https://www.phoronix-test-suite.com/?k=docs
- **Website**: https://phoronix-test-suite.com/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/phoronix/pts

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: PHP CLI installed from a package on ubuntu, with PHP from apt.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: php-cli, phoronix-test-suite (vendor .deb v10.8.4), build-essential (inferred)
- python/pip: none
- node/npm: none
- other: Phoronix .deb (vendor), benchmark compile at runtime needs build tooling

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: none

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/phoronix-test-suite
- non-root: no - runAsUser 0 and runAsGroup 0, no override
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set in values (default false)
- other-security: none
- extra-persistence: /var/lib/phoronix-test-suite (pvc), /var/lib/phoronix-test-suite/test-results (pvc)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: benchmarks compile and download their test profiles at runtime, so the first run needs internet access and takes a long time (inferred).
- caveat: results for hardware benchmarks reflect the host, and GPU or disk tests need the matching host devices passed in (inferred).
- caveat: there are no ports, so the container is a CLI job runner and is not reached over the network.

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: phoronix-test-suite
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/phoronix/pts:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/phoronix-test-suite/phoronix-test-suite/blob/master/deploy/docker/ubuntu-pts-docker-build.sh)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/phoronix-test-suite/phoronix-test-suite)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/phoronix-test-suite/phoronix-test-suite/releases/download/v10.8.4/phoronix-test-suite_10.8.4_all.deb)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: No Dockerfile exists upstream, only a build helper script, so the image must be designed from scratch. Phoronix is a PHP CLI from git, but its test profiles compile benchmarks at runtime, which needs root-like build tooling and writable paths.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [phoronix/pts:latest](https://hub.docker.com/r/phoronix/pts)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
