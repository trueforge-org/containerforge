# ollama

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: ollama
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/ollama
- **Source repository**: https://github.com/open-webui/open-webui
- **Documentation**: https://docs.openwebui.com/
- **Website**: https://openwebui.com

## Potentially relevant resources

- **Container image**: https://ghcr.io/open-webui/open-webui
- **Source code repository**: https://github.com/ollama/ollama
- **Container image**: https://hub.docker.com/r/ollama/ollama

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Python 3.12 FastAPI app installed from PyPI with a prebuilt frontend.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: open-webui
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (open-webui web UI)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/ollama
- non-root: no - runAsUser 0, runAsGroup 0, runAsNonRoot false
- read-only-rootfs: no - readOnlyRootFilesystem false
- privileged: no - default false, not overridden; no GPU or NVIDIA settings in values
- other-security: none
- extra-persistence: /root/.ollama (pvc); /app/backend/data (pvc). Draft says model and cache dirs go to /config and /tmp, the chart mounts /root/.ollama.
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the chart role is a sidecar running Open WebUI, so an Ollama server must be running and reachable as a separate service (external service).
- caveat: model downloads are large and the RAM needed grows with the model, and GPU use depends on host hardware (resource, inferred).
- caveat: the image is `latest`, so the Open WebUI version changes without notice (upstream status).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: ollama
- **Role**: sidecar (uiImage)

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/open-webui/open-webui:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/open-webui/open-webui/blob/0666e59/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/open-webui/open-webui)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `pip:open-webui`

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Python 3.12 FastAPI app with a prebuilt Svelte frontend, installable from PyPI; use ContainerForge python base. Large dependency set and model/cache dirs need redirecting to /config and /tmp for read-only rootfs, but no extra services.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [ghcr.io/open-webui/open-webui:latest](https://ghcr.io/open-webui/open-webui)
- **copy-from arm64**: [ghcr.io/open-webui/open-webui:latest](https://ghcr.io/open-webui/open-webui)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

- **Dependency containers**: -
