# batnoter

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: batnoter
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/batnoter
- **Source repository**: https://github.com/batnoter/batnoter

## Potentially relevant resources

- **Container image**: https://ghcr.io/batnoter/batnoter/batnoter-ui

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [nginx](https://github.com/trueforge-org/containerforge/tree/main/apps/nginx) (`ghcr.io/trueforge-org/nginx`)
- **Alternative runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Static UI build served by nginx; the node build runs only at build time.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: React UI build deps (inferred)
- other: none (build-stage only; nginx runtime)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (static UI via nginx) (inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/batnoter
- non-root: possible - chart sets runAsUser/runAsGroup 0; draft says unprivileged nginx setup still needs work
- read-only-rootfs: possible - chart sets readOnlyRootFilesystem false; nginx needs writable temp paths
- privileged: no - common default false, no chart override
- other-security: none
- extra-persistence: none
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the image is only the static UI, so a separate batnoter backend or service is probably needed for the app to work end to end (inferred).
- caveat: the draft traced the repository HEAD rather than the v1.0.0 tag, so the built code may not match the release (spec).
- caveat: the unprivileged nginx setup is not finished, so port and temp-path changes are still needed before a rootless run (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: batnoter
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/batnoter/batnoter/batnoter-ui:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/batnoter/batnoter/blob/8722c3af2b81233f158ca17e4818b9251c8cc1d3/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/batnoter/batnoter)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/batnoter/batnoter/releases/tag/v1.0.0)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Node build of a React UI, copied into nginx:stable-alpine, and the image is only the UI. The ContainerForge nginx sibling can serve the static files, but the node build and the unprivileged nginx setup need work. The trace used repo HEAD, not a tag.

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
