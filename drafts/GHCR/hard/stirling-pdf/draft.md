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

## Potentially relevant resources

- **Container image**: https://ghcr.io/stirling-tools/s-pdf

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [java17](https://github.com/trueforge-org/containerforge/tree/main/apps/java17) (`ghcr.io/trueforge-org/java17`)
- **Reason**: Spring Boot Java app with no version named, so java17 is used by default.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: libreoffice, tesseract-ocr, ocrmypdf, ghostscript, qpdf, unpaper, pngquant, poppler-utils (inferred for the last four)
- python/pip: none
- node/npm: none
- other: Java 17 runtime from java17 base; Stirling-PDF JAR from release (AppImage not usable in a container)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (web UI and API, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/stirling-pdf
- non-root: no - runAsUser 0, runAsGroup 0, runAsNonRoot false
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: /configs, /usr/share/tessdata, /customFiles, /logs (chart paths, type not set)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: LibreOffice, tesseract and ocrmypdf make the image large, and OCR jobs need several GB of RAM (inferred).
- caveat: the fat and ultra-lite tags include different tool sets, so features such as office conversion depend on which tag is used (inferred).
- caveat: upstream ships an AppImage for amd64 that cannot run in a container, so the JAR path must be used instead (inferred).

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
