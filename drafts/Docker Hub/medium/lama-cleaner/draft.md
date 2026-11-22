# lama-cleaner

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: lama-cleaner
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/Sanster/lama-cleaner
- **Documentation**: https://lama-cleaner-docs.vercel.app
- **Documentation**: https://www.iopaint.com/install/download_model
- **Website**: https://www.iopaint.com/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: lama-cleaner
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/cwq1913/lama-cleaner:cpu-0.33.0, gpu-0.33.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Sanster/lama-cleaner/blob/5114a46f5e6ad87f489e5dbbd98ac780bcee34fd/docker/CPUDockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Sanster/lama-cleaner)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `pip:lama-cleaner`

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Python image inpainting web app installed with pip on python 3.7, pulling the PyTorch CPU stack and large model downloads at runtime. Needs the python sibling with a newer Python and large torch dependencies; the GPU variant is out of scope for a CPU image.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [cwq1913/lama-cleaner:cpu-0.33.0](https://hub.docker.com/r/cwq1913/lama-cleaner)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
