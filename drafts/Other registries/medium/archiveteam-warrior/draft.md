# archiveteam-warrior

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Other registries
- **Difficulty**: medium
- **Chart**: archiveteam-warrior
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/archiveteam-warrior
- **Source repository**: https://github.com/ArchiveTeam/warrior-code2
- **Documentation**: https://wiki.archiveteam.org/index.php/ArchiveTeam_Warrior
- **Website**: https://warriorhq.archiveteam.org/

## Potentially relevant resources

- No additional resources were listed in the TrueCharts chart sources.

## Base container

- **Foundation**: ubuntu (`ghcr.io/trueforge-org/ubuntu:26.4`), which every ContainerForge runtime image is built on
- **Runtime image**: python
- **Reason**: Python web app pip-installed into /app on the python base.

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: archiveteam-warrior
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `atdr.meo.ws/archiveteam/warrior-dockerfile:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ArchiveTeam/warrior-dockerfile/blob/061524dc03515df50bc0c45bd96af907f401cf39/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/ArchiveTeam/warrior-code2)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Python web app (warrior-code2) git-cloned at build time on top of ArchiveTeam grab-base. We would pip install it into /app on the ContainerForge python base, pin a git revision, and keep state in /config. Upstream runs as root, so the rootless rework adds effort.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

A path in backticks is where the binary sits inside the image.

- **copy-from amd64**: `atdr.meo.ws/archiveteam/warrior-dockerfile:latest`
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
