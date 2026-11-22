# archivebox

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: archivebox
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/archivebox
- **Source repository**: https://github.com/ArchiveBox/ArchiveBox
- **Documentation**: https://github.com/ArchiveBox/ArchiveBox/wiki
- **Documentation**: https://docs.archivebox.io/
- **Website**: https://archivebox.io/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: archivebox
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/archivebox/archivebox:0.9.77`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/ArchiveBox/ArchiveBox/blob/289d6a5904642b02c618e77f225aa28bd201a145/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/ArchiveBox/ArchiveBox)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `pip:archivebox`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Python package installed with pip, but the full image also pulls in chromium, node, sonic and many extractor tools. That is a large stack with helper binaries and writes outside /config. The sonic search helper is a source build the trace did not confirm.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/archivebox/archivebox:0.9.77](https://ghcr.io/archivebox/archivebox)
- **copy-from arm64**: [ghcr.io/archivebox/archivebox:0.9.77](https://ghcr.io/archivebox/archivebox)

### Dependency containers

- **Dependency containers**: none
