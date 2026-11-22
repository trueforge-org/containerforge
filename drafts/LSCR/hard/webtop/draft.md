# webtop

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: LSCR
- **Difficulty**: hard
- **Chart**: webtop
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/webtop
- **Source repository**: https://github.com/selkies-project/selkies
- **Documentation**: https://docs.linuxserver.io/images/docker-webtop/
- **Documentation**: https://docs.selkies.io/

## Potentially relevant resources

- **Container image**: https://fleet.linuxserver.io/image?name=linuxserver/webtop
- **Source code repository**: https://github.com/linuxserver/docker-webtop#readme
- **Source code repository**: https://github.com/linuxserver/gclient
- **Source code repository**: https://github.com/orgs/linuxserver/packages/container/package/webtop

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Desktop environment with packages from apt; no single language runtime.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: desktop/X packages (inferred, varies by DE variant)
- python/pip: selkies
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 3000/http (selkies desktop web UI, inferred), 3001/https (selkies desktop web UI over TLS, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/webtop
- non-root: no - chart sets runAsUser 0, runAsGroup 0, runAsNonRoot false
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: none in values; desktop session on port 33000 (http)
- extra-persistence: none beyond chart's /config
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: webtop
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `lscr.io/linuxserver/webtop:alpine-i3, alpine-icewm, alpine-kde (+21)`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/linuxserver/docker-webtop/blob/b1c6c9e22abe066d2d637377229de773dd45044f/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/selkies-project/selkies)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `pip:selkies`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Browser-accessed desktop environment with many DE variants on a linuxserver selkies base, so it is a desktop image with a display, services and many packages. It is not a single application, which makes it hard to port and maintain.

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
