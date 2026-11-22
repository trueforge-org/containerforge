# smtp-relay

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: smtp-relay
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/smtp-relay
- **Source repository**: https://github.com/Exim/exim
- **Documentation**: https://www.exim.org/docs.html
- **Website**: https://www.exim.org/

## Potentially relevant resources

- **Container image**: https://ghcr.io/ix-ai/smtp
- **Source code repository**: https://github.com/ix-ai/smtp

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Exim relay installed from one apt package.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: exim4-daemon-light
- python/pip: none
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 25/tcp (SMTP)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/smtp-relay
- non-root: no - container override runAsNonRoot false, runAsUser 0, runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: none (port 25 and config templating are not security settings in values)
- extra-persistence: none
- confidence: high

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: smtp-relay
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/ix-ai/smtp:v0.7.7`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://gitlab.com/ix.ai/smtp/-/blob/v0.7.7/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Exim/exim)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `apt:exim4-daemon-light`

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Exim relay installed by one apt package (exim4-daemon-light) on debian stable-slim, with entrypoint scripts that template the config. On ubuntu the package is simple, but port 25 must become a high port and spool and log dirs must move to /tmp or /config. Medium for read-only rework.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/ix-ai/smtp:v0.7.7](https://ghcr.io/ix-ai/smtp)
- **copy-from arm64**: [ghcr.io/ix-ai/smtp:v0.7.7](https://ghcr.io/ix-ai/smtp)

### Dependency containers

- **Dependency containers**: none
