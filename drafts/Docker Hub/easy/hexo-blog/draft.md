# hexo-blog

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: hexo-blog
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/hexo-blog
- **Source repository**: https://github.com/hexojs/hexo
- **Documentation**: https://hexo.io/docs/
- **Website**: https://hexo.io

## Potentially relevant resources

- **Source code repository**: https://github.com/fletchto99/hexo-dev-docker
- **Container image**: https://hub.docker.com/r/fletchto99/hexo-dev-blog

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Hexo static site tooling installed with npm, so only Node.js is needed.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: hexo, plus site dependencies via npm ci (inferred)
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 4000/http (hexo dev server)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/hexo-blog
- non-root: possible - chart sets runAsUser 0 and runAsGroup 0; static site tooling likely needs no root
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default false, not overridden
- other-security: none
- extra-persistence: none beyond /config (chart's own)
- confidence: low

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: hexo-blog
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/fletchto99/hexo-dev-blog:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/fletchto99/hexo-dev-docker/blob/b92ba8c485a0b770f7f7110eb90bf3e920d21b4c/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/hexojs/hexo)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `npm:hexo`

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Hexo static site tooling installed with npm ci on the node base, running hexo server as one process. Generated output and the db file go to /tmp or /config. No services and no native compile for the usual hexo plugin set.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [fletchto99/hexo-dev-blog:latest](https://hub.docker.com/r/fletchto99/hexo-dev-blog)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
