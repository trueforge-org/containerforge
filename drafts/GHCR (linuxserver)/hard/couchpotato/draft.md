# couchpotato

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR (linuxserver)
- **Difficulty**: hard
- **Chart**: couchpotato
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/couchpotato
- **Source repository**: https://github.com/CouchPotato/CouchPotatoServer

## Potentially relevant resources

- **Container image**: https://ghcr.io/linuxserver/couchpotato

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Python app that needs a Python 3 port, which fits the python base.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none | none
- python/pip: none | none
- node/npm: none | none
- other: CouchPotatoServer source tarball, needs Python 3 port (no python2 on base)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 5050/http (web UI)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/couchpotato
- non-root: possible - chart runAsUser 0 for linuxserver; draft is a Python 3 port on python base
- read-only-rootfs: possible - no override, chart default true; state in /config
- privileged: no - not set in values
- other-security: none
- extra-persistence: none
- confidence: low

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: couchpotato
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/linuxserver/couchpotato:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/linuxserver/docker-couchpotato/blob/273f98c4d935e5c5629b3978685c4066402c8490/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/CouchPotato/CouchPotatoServer)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/CouchPotato/CouchPotatoServer/releases/tag/build%2F3.0.1)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: CouchPotatoServer source tarball run as Python by linuxserver, whose Dockerfile installs python2. Ubuntu 26.04 and the ContainerForge python base have no Python 2, so it needs a Python 3 port or custom interpreter. State goes in /config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
