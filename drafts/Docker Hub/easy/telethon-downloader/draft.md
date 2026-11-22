# telethon-downloader

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: telethon-downloader
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/telethon-downloader
- **Source repository**: https://github.com/jsavargas/telethon_downloader

## Potentially relevant resources

- **Website**: https://docs.telethon.dev
- **Container image**: https://hub.docker.com/r/jsavargas/telethon_downloader

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Python downloader installed with pip from requirements.txt.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: unzip (inferred)
- python/pip: telethon, requirements.txt from upstream repo ([requirements.txt](https://github.com/jsavargas/telethon_downloader/blob/HEAD/requirements.txt))
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 5000/http (web UI, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/telethon-downloader
- non-root: possible - chart sets runAsUser 0 and runAsGroup 0; draft is pip-installed Python
- read-only-rootfs: possible - chart sets readOnlyRootFilesystem false; session and downloads go to /config
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: /download and /watch (pvc, chart's own)
- confidence: medium

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: telethon-downloader
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/jsavargas/telethon_downloader:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/jsavargas/telethon_downloader/blob/ed9710a/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/jsavargas/telethon_downloader)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/jsavargas/telethon_downloader/archive/refs/heads/master.zip)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Python Telegram downloader whose Dockerfile copies src and pip installs requirements.txt on a floating python base. Telethon is pure Python, so one pip install into /app with the session and downloads kept under /config is enough. No services and no native build.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [jsavargas/telethon_downloader:latest](https://hub.docker.com/r/jsavargas/telethon_downloader)
- **copy-from arm64**: [jsavargas/telethon_downloader:latest](https://hub.docker.com/r/jsavargas/telethon_downloader)

### Dependency containers

- **Dependency containers**: none
