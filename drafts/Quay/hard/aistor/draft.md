# aistor

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Quay
- **Difficulty**: hard
- **Chart**: aistor
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/incubator/aistor
- **Website**: https://min.io/product/aistor
- **Documentation**: https://docs.min.io/aistor
- **Documentation**: https://docs.min.io/aistor/

## Potentially relevant resources

- No additional resources were listed in the TrueCharts chart sources.

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Closed-source vendor Linux binary run directly with no language base.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: MinIO AIStor vendor linux binary per arch from dl.min.io

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 9000/http (S3 API), 9001/http (web console, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/incubator/aistor
- non-root: yes - no securityContext override, common default 568
- read-only-rootfs: possible - common default readOnlyRootFilesystem true, but MinIO writes to /data (pvc) and reads a license file and optional certs
- privileged: no - not set, common default false
- other-security: none in container security; license key from a secret mounted at /minio.license
- extra-persistence: /data (chart-added, pvc); /etc/minio/certs (chart-added, only when tls enabled, type not set so default pvc); /minio.license (secret); draft says data goes under /config, which mismatches
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: a MinIO AIStor licence key is required and is mounted from a secret at /minio.license; the container will not run without it (manual setup)
- caveat: the vendor binary download on dl.min.io may need an account or licence, and redistribution in an image may be restricted (inferred)
- caveat: a production setup needs several drives or nodes for erasure coding; a single drive is only good for testing (inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: aistor
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `quay.io/minio/aistor/minio:RELEASE.2026-09-19T17-05-25Z`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

`-` means no public Dockerfile could be found.

- **Dockerfile**: -

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://min.io/product/aistor)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://dl.min.io/aistor/minio/release/linux-amd64/minio) · [arm64](https://dl.min.io/aistor/minio/release/linux-arm64/minio)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Closed-source MinIO AIStor with no public Dockerfile, but the vendor publishes linux binaries for download; running needs a license key. Fetch the vendor binary into /app with data under /config; licensing and redistribution terms are the blocker.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [quay.io/minio/aistor/minio:RELEASE.2026-09-19T17-05-25Z](https://quay.io/repository/minio/aistor/minio)
- **copy-from arm64**: [quay.io/minio/aistor/minio:RELEASE.2026-09-19T17-05-25Z](https://quay.io/repository/minio/aistor/minio)

### Dependency containers

- **Dependency containers**: none
