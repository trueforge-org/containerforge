# tracks

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: tracks
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/tracks
- **Source repository**: https://github.com/tracksapp/tracks
- **Documentation**: https://getontracks.org/manual
- **Website**: https://getontracks.org/

## Potentially relevant resources

- **Container image**: https://ghcr.io/tracksapp/tracks

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Ruby on Rails app with Ruby installed from Ubuntu apt.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: ruby-full, build-essential (inferred, native gems)
- python/pip: none
- node/npm: none
- other: bundler gem and Ruby gems installed into /app at build

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 3000/http (web UI, inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: tracks
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/tracksapp/tracks:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/tracksapp/tracks/blob/8dcca98c6c48404d8328bbee220a8b19d48799ce/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/tracksapp/tracks)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/tracksapp/tracks/releases/tag/v2.7.1)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Ruby on Rails 3.3 app with some native gems and no Ruby runtime in ContainerForge, so install Ruby from Ubuntu apt and bundle gems into /app at build. Needs an external database and writable paths moved to /config and /tmp; no extra services.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/tracksapp/tracks:latest](https://ghcr.io/tracksapp/tracks)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
