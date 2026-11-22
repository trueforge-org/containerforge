# stirling-pdf

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: stirling-pdf
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/stirling-pdf
- **Source repository**: https://github.com/Stirling-Tools/Stirling-PDF
- **Documentation**: https://docs.stirlingpdf.com/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: stirling-pdf
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/stirling-tools/s-pdf:3.4.0, 3.4.0-fat, 3.4.0-ultra-lite`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Stirling-Tools/Stirling-PDF/blob/c544e2c3457f52d05675b36dffacc44a4479149e/docker/embedded/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Stirling-Tools/Stirling-PDF)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/Stirling-Tools/Stirling-PDF/releases/download/v3.4.0/Stirling-PDF-linux-x86_64.AppImage) · [arm64](https://github.com/Stirling-Tools/Stirling-PDF/releases/download/v3.4.0/Stirling-PDF.jar)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Stirling-PDF is a Spring Boot Java app shipped as an arch-neutral JAR, but it depends on a large toolset (LibreOffice, tesseract, ocrmypdf, ghostscript and more) installed through apt. That is a large stack with several tools and optional fat and ultra-lite variants. The java sibling helps, but the tools dominate the effort.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/stirling-tools/s-pdf:3.4.0](https://ghcr.io/stirling-tools/s-pdf)
- **copy-from arm64**: [ghcr.io/stirling-tools/s-pdf:3.4.0](https://ghcr.io/stirling-tools/s-pdf)

### Dependency containers

- **Dependency containers**: none
