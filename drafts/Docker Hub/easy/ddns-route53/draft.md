# ddns-route53

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: ddns-route53
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ddns-route53
- **Source repository**: https://github.com/crazy-max/ddns-route53
- **Documentation**: https://crazymax.dev/ddns-route53/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/crazymax/ddns-route53

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Single Go binary run from the release tarball.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: ddns-route53 Go release tarball (per arch)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: ddns-route53
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/crazymax/ddns-route53:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/crazy-max/ddns-route53/blob/d8e3a348afe6152e8919e9f2360ad4fec2a2b323/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/crazy-max/ddns-route53)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/crazy-max/ddns-route53/releases/download/v2.16.1/ddns-route53_2.16.1_linux_amd64.tar.gz) · [arm64](https://github.com/crazy-max/ddns-route53/releases/download/v2.16.1/ddns-route53_2.16.1_linux_arm64.tar.gz)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Single Go binary that updates Route53 DNS records, built with xx-go and copied into alpine. Use the GitHub release tarball on containerforge-ubuntu, run rootless with configuration from environment variables; no other services.

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
