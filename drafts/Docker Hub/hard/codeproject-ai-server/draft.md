# codeproject-ai-server

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: codeproject-ai-server
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/codeproject-ai-server
- **Source repository**: https://github.com/codeproject/CodeProject.AI-Server
- **Documentation**: https://codeproject.github.io/codeproject.ai/
- **Website**: https://codeproject.github.io/codeproject.ai

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/codeproject/ai-server

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Alternative runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: .NET server installed from the vendor Ubuntu .deb, with Python modules as the alternative.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: dotnet-runtime-9.0 (inferred)
- python/pip: none
- node/npm: none
- other: CodeProject.AI vendor Ubuntu .deb per arch (.NET 9 server, Python modules download at runtime)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 32168/http (web UI and API)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/codeproject-ai-server
- non-root: no - runAsUser 0, runAsGroup 0, runAsNonRoot false
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: none beyond root override
- extra-persistence: /etc/codeproject/ai, /app/modules (chart persistence, type not shown)
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: codeproject-ai-server
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/codeproject/ai-server:cpu-2.6.5, cuda11_7, cuda12_2`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

`-` means no public Dockerfile could be found.

- **Dockerfile**: -

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/codeproject/CodeProject.AI-Server)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://codeproject.github.io/codeproject.ai/install/install_on_linux.html)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: CodeProject.AI server (.NET 9 plus Python modules) installed from the vendor Ubuntu .deb for each arch into /app on containerforge-ubuntu. Modules download at runtime, so /config and writable module dirs are needed; GPU variants and many processes remain a concern.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [codeproject/ai-server:cpu-2.6.5](https://hub.docker.com/r/codeproject/ai-server)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
