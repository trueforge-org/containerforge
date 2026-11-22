# namecheap-ddns

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: namecheap-ddns
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/namecheap-ddns
- **Source repository**: https://github.com/EdwardChamberlain/namecheap_ddns

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/edchamberlain/namecheap_ddns

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Python script that needs only requests, installed with pip.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: requests
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: none

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/namecheap-ddns
- non-root: possible - chart sets runAsUser 0 and runAsGroup 0; Python script likely needs no root
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default false, not overridden
- other-security: none
- extra-persistence: none (persistence {} in chart)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: Dynamic DNS must be enabled per domain in the Namecheap account, and each host needs its own DDNS password (inferred)
- caveat: the upstream repo has no release binary, so the image relies on the source repo and the requirements install (inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: namecheap-ddns
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/edchamberlain/namecheap_ddns:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/EdwardChamberlain/namecheap_ddns/blob/421a554e5267e6405850f0fe302ff95600dc8539/src/dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/EdwardChamberlain/namecheap_ddns)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/EdwardChamberlain/namecheap_ddns)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Small Python script that needs only requests, installed with pip into /app on the ContainerForge python base. Single process, no services, and state can live in /config. Runs rootless without changes beyond the usual layout.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [edchamberlain/namecheap_ddns:latest](https://hub.docker.com/r/edchamberlain/namecheap_ddns)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
