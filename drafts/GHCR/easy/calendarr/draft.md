# calendarr

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: calendarr
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/calendarr
- **Source repository**: https://github.com/jordanlambrecht/calendarr

## Potentially relevant resources

- **Container image**: https://ghcr.io/jordanlambrecht/calendarr

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Python web app installed from requirements with pip.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: packages from upstream requirements.txt (inferred, names not in draft) ([requirements.txt](https://github.com/jordanlambrecht/calendarr/blob/HEAD/requirements.txt))
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (web app, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/calendarr
- non-root: possible - chart sets runAsNonRoot false and runAsUser 0; the draft's pip-installed Python app needs no root
- read-only-rootfs: possible - chart sets false; draft keeps the DB in /config, but logs and footers need writable paths
- privileged: no - default false, not overridden
- other-security: none
- extra-persistence: /app/logs pvc and /app/custom_footers pvc (chart; draft does not name them)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: Sonarr and Radarr URLs and API keys must be entered in the web UI or env before the calendar syncs anything (inferred).
- caveat: The chart tag is rolling latest while the draft references release v1.5.2, so the build and the deployed version can drift (inferred).
- caveat: The app depends on Python packages pulled from upstream requirements.txt, so new upstream releases can change the dependency set (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: calendarr
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/jordanlambrecht/calendarr:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/jordanlambrecht/calendarr/blob/4da458fb9d59a787c6ae1819eb063ba91cfe83d1/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/jordanlambrecht/calendarr)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/jordanlambrecht/calendarr/releases/tag/v1.5.2)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Python web app installed from requirements.txt on python:3.15 slim, with source copied in. Reuse the python sibling with pip into /app or a venv in /tmp, keep the database in /config, and run without extra services. Easy.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/jordanlambrecht/calendarr:latest](https://ghcr.io/jordanlambrecht/calendarr)
- **copy-from arm64**: [ghcr.io/jordanlambrecht/calendarr:latest](https://ghcr.io/jordanlambrecht/calendarr)

### Dependency containers

- **Dependency containers**: none
