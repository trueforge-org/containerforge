# prpdf

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: prpdf
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/prpdf
- **Source repository**: https://github.com/maschhoff/pdfscanexplorer

## Potentially relevant resources

- **Source code repository**: https://github.com/maschhoff/prpdf
- **Container image**: https://hub.docker.com/r/knex666/prpdf

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: prpdf
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/knex666/prpdf:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/maschhoff/prpdf/blob/132fcad/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/maschhoff/pdfscanexplorer)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/maschhoff/pdfscanexplorer/releases/tag/1.0.2)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Python PDF tool whose Dockerfile compiles jbig2enc and Ghostscript 10.03.1 from source. On ubuntu both are apt packages, so the compile can be dropped in favour of the python sibling plus pip requirements. Only the Ghostscript version may differ from upstream, so output should be checked.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [knex666/prpdf:latest](https://hub.docker.com/r/knex666/prpdf)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
