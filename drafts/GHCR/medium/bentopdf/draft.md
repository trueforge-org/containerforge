# bentopdf

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: bentopdf
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/bentopdf
- **Source repository**: https://github.com/alam00000/bentopdf

## Potentially relevant resources

- **Container image**: https://ghcr.io/alam00000/bentopdf-simple

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [nginx](https://github.com/trueforge-org/containerforge/tree/main/apps/nginx) (`ghcr.io/trueforge-org/nginx`)
- **Alternative runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Vite-built static site served by nginx; node is only needed for the build.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: Vite build deps (inferred)
- other: none (build-stage only; nginx runtime)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (static web UI via nginx-unprivileged) (inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/bentopdf
- non-root: yes - common default runAsUser 568, no root override
- read-only-rootfs: yes - common default true; nginx writes go to emptyDir mounts
- privileged: no - common default false, no override
- other-security: none
- extra-persistence: /var/cache/nginx and /etc/nginx/tmp (emptyDir, chart-level)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the PDF tools run in the browser, so large files use the client machine's RAM and CPU rather than the container (inferred).
- caveat: the draft uses the "simple" image variant, and the full variant with heavier features may need different build steps (inferred).
- caveat: the release is pinned to v2.8.12 and the project releases often, so the version needs regular bumping (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: bentopdf
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/alam00000/bentopdf-simple:2.8.12`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/alam00000/bentopdf/blob/v2.8.12/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/alam00000/bentopdf)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/alam00000/bentopdf/releases/download/v2.8.12/dist-simple-2.8.12.zip)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Vite-built static PDF tools site, served by nginx-unprivileged upstream, so the ContainerForge nginx sibling can serve the built files. The work is the node build step. The output is arch-neutral static assets, with no services or root needs.

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
