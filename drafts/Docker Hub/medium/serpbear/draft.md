# serpbear

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: serpbear
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/serpbear
- **Source repository**: https://github.com/towfiqi/serpbear

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/towfiqi/serpbear

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Next.js Node 22 app built at image build time, so python-node provides node.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: build-essential, python3 (inferred, only if the sqlite native module compiles)
- python/pip: none
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 3000/http (web UI and API)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/serpbear
- non-root: yes - runAsUser 568 default, no root override
- read-only-rootfs: yes - default readOnlyRootFilesystem true, not overridden; Next.js cache writes must go to /tmp
- privileged: no - common default privileged false, not overridden
- other-security: none
- extra-persistence: /app/data (pvc, chart-defined; SQLite)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: Requires a Search Console or scraping API key (for example Scraping Robot or similar) for rank tracking; without it, keyword checks do not return results (inferred).
- caveat: Read-only rootfs works only if all Next.js cache writes are redirected to /tmp; a missing redirect causes startup or runtime crashes.

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: serpbear
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/towfiqi/serpbear:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/towfiqi/serpbear/blob/v3.1.2/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/towfiqi/serpbear)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/towfiqi/serpbear/releases/tag/v3.1.2)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Next.js app built with node 22, which needs a build step at image build time and writable cache paths under /tmp. SQLite is used for storage. The Node runtime is available as a ContainerForge sibling, and the output is interpreted JavaScript.

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
