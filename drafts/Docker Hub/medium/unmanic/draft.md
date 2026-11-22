# unmanic

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: unmanic
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/unmanic
- **Source repository**: https://github.com/Unmanic/unmanic

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/josh5/unmanic

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Alternative runtime image**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`)
- **Reason**: Python app installed into /app on the python base, with ffmpeg from apt.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: ffmpeg
- python/pip: unmanic (repo wheel and requirements, inferred) ([requirements.txt](https://github.com/Unmanic/unmanic/blob/HEAD/requirements.txt))
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8888/http (web UI and API)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/unmanic
- non-root: yes - runAsUser 568 default, no root override
- read-only-rootfs: yes - default readOnlyRootFilesystem true, not overridden; temp writes under /tmp
- privileged: no - common default privileged false, not overridden
- other-security: none
- extra-persistence: /library (pvc); /tmp/unmanic/remote_library (pvc); /tmp/unmanic (emptyDir)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: Media transcoding is CPU and disk heavy; a large library needs substantial scratch space in /tmp/unmanic.
- caveat: Hardware acceleration needs a GPU or device passthrough that is not part of the default setup (inferred).
- caveat: Library cache and temporary files are split across /config and /tmp, so both must be writable and sized correctly.

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: unmanic
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/josh5/unmanic:0.4.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Unmanic/unmanic/blob/1c324b8/docker/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Unmanic/unmanic)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `pip:unmanic`

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Python web app built as a venv from the repo wheel plus requirements, on ubuntu 24.04 with ffmpeg from apt. Reuse the ubuntu base and python sibling, install into /app, keep the library cache in /config and temp in /tmp. It runs several worker threads but no extra services.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [josh5/unmanic:0.4.1](https://hub.docker.com/r/josh5/unmanic)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
