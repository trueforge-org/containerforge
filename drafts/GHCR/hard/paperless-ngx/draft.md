# paperless-ngx

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: paperless-ngx
- **Rows**: 1
- **Hard dependency containers**: yes (valkey)
- **Optional dependency containers**: yes (postgresql, gotenberg, tika)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/paperless-ngx
- **Source repository**: https://github.com/paperless-ngx/paperless-ngx
- **Documentation**: https://github.com/paperless-ngx/paperless-ngx/tree/dev/docs

## Potentially relevant resources

- **Container image**: https://ghcr.io/paperless-ngx/paperless-ngx
- **Container image**: https://hub.docker.com/r/apache/tika
- **Container image**: https://hub.docker.com/r/gotenberg/gotenberg
- **Website**: https://paperless-ngx.readthedocs.io/en/latest

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Django app on Python, with the frontend built at build time.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: tesseract-ocr, ghostscript, imagemagick, libmagic1 (inferred), poppler-utils (inferred)
- python/pip: uv, project deps from release tarball (inferred)
- node/npm: pnpm (frontend built at build time)
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8000/http (web UI)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/paperless-ngx
- non-root: no - chart sets runAsNonRoot false and runAsUser 0; relies on USERMAP_UID and USERMAP_GID remapping
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set in values
- other-security: none in values; gotenberg and tika are separate sidecar deployments, not part of this draft
- extra-persistence: /data (data, pvc chart default); /consume (consume, pvc chart default); /media (media, pvc chart default)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: Gotenberg and Tika are missing from ContainerForge, so Office document conversion will not work without them
- caveat: OCR (tesseract, ghostscript, imagemagick) and first-run indexing are CPU and RAM heavy (resource needs, inferred)
- caveat: the non-root path relies on USERMAP_UID and USERMAP_GID remapping, which must be set by the user (inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: paperless-ngx
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/paperless-ngx/paperless-ngx:3.5.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/paperless-ngx/paperless-ngx/blob/v3.5.1/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/paperless-ngx/paperless-ngx)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/paperless-ngx/paperless-ngx/releases/download/v3.5.1/paperless-ngx-v3.5.1.tar.xz)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Paperless-ngx is Python (uv pip, Django) with a pnpm-built frontend, but it runs a web server, a Celery worker and a consumer together. It also needs OCR tools (tesseract, ghostscript, imagemagick), Valkey and Postgres from the chart, and Gotenberg and Tika sidecars. This is a large stack with several processes.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/paperless-ngx/paperless-ngx:3.5.1](https://ghcr.io/paperless-ngx/paperless-ngx)
- **copy-from arm64**: [ghcr.io/paperless-ngx/paperless-ngx:3.5.1](https://ghcr.io/paperless-ngx/paperless-ngx)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

❌ means it is missing too.

- **Dependency containers**: valkey ✅, postgresql ✅, gotenberg (gotenbergImage) ❌, tika (tikaImage) ❌
