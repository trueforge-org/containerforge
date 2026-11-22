# wyoming-whisper

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: wyoming-whisper
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/wyoming-whisper
- **Source repository**: https://github.com/rhasspy/wyoming-faster-whisper
- **Documentation**: https://www.home-assistant.io/integrations/whisper/

## Potentially relevant resources

- **Source code repository**: https://github.com/home-assistant/addons/tree/master/whisper
- **Container image**: https://hub.docker.com/r/rhasspy/wyoming-whisper

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Python Wyoming server with faster-whisper installed from pip.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: wyoming-faster-whisper
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 10300/tcp (Wyoming protocol, STT)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/wyoming-whisper
- non-root: yes - no securityContext override, runAsUser 568 default
- read-only-rootfs: possible - default true, but the model cache needs a writable path (chart mounts /.cache/huggingface)
- privileged: no - not set, common default false
- other-security: none
- extra-persistence: /.cache/huggingface (pvc) unless HF_HOME is pointed at /config or /tmp
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: Faster-whisper model is fetched on first use into the Hugging Face cache, which the chart mounts at /.cache/huggingface; the draft redirects it to /tmp, so models re-download after restart (inferred).
- caveat: Large-model transcription is CPU heavy and slow without a GPU; expect high RAM use for medium and larger models (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: wyoming-whisper
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/rhasspy/wyoming-whisper:3.9.1`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/rhasspy/wyoming-faster-whisper/blob/1c407106530e09fc8f2477e4ae4cf86480fd6256/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/rhasspy/wyoming-faster-whisper)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `pip:wyoming-faster-whisper`

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Python Wyoming server using faster-whisper installed from pip into a venv on a debian-slim base, with no extra services. Models go to /config and cache to /tmp. Runs as one process.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [rhasspy/wyoming-whisper:3.9.1](https://hub.docker.com/r/rhasspy/wyoming-whisper)
- **copy-from arm64**: [rhasspy/wyoming-whisper:3.9.1](https://hub.docker.com/r/rhasspy/wyoming-whisper)

### Dependency containers

- **Dependency containers**: none
