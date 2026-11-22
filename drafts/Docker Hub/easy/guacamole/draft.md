# guacamole

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: guacamole
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/guacamole
- **Source repository**: https://github.com/apache/guacamole-server
- **Documentation**: http://guacamole.apache.org/doc/gug/
- **Website**: http://guacamole.apache.org/

## Potentially relevant resources

- **Source code repository**: https://github.com/apache/guacamole-client
- **Container image**: https://hub.docker.com/r/guacamole/guacamole
- **Container image**: https://hub.docker.com/r/guacamole/guacd

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: guacd daemon installed from apt on the ubuntu base.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: guacamole
- **Role**: sidecar (guacdImage)

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/guacamole/guacd:1.6.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/apache/guacamole-server/blob/1f664e08feae6e7d15d8146b78acab2e6fb470ae/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/apache/guacamole-server)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Apache Guacamole proxy daemon (C, 1.6.x). Ubuntu ships guacd as an apt package (present in resolute, 26.04) with libguac client plugins for RDP, VNC and SSH on both architectures, so install via apt, no source build. Single process on port 4822, no state needed.

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

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

- **Dependency containers**: -
