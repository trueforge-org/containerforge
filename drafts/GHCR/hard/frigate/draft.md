# frigate

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: frigate
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/frigate
- **Source repository**: https://github.com/blakeblackshear/frigate
- **Documentation**: https://docs.frigate.video
- **Website**: https://frigate.video

## Potentially relevant resources

- **Container image**: https://ghcr.io/blakeblackshear/frigate

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Alternative runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Python backend; node is needed only for the web UI build.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: ffmpeg, libgl1 (inferred), libusb-1.0-0 (inferred)
- python/pip: frigate backend requirements (inferred) ([docker/main/requirements.txt](https://github.com/blakeblackshear/frigate/blob/HEAD/docker/main/requirements.txt))
- node/npm: web UI build (inferred)
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8971/https (authenticated web UI via nginx), 5000/http (internal unauthenticated web API), 8554/tcp (RTSP restream), 8555/tcp (WebRTC), 8555/udp (WebRTC)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/frigate
- non-root: no - chart forces runAsUser 0 and runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, default false
- other-security: none in values; camera device passthrough from the Reason is not shown
- extra-persistence: /media (type not set, likely pvc)
- confidence: low

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: frigate
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/blakeblackshear/frigate:0.18.3, 0.18.3-tensorrt`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/blakeblackshear/frigate/blob/a19e23ae2dd3dd1082bf82a0ad5d2b62a5813676/docker/main/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/blakeblackshear/frigate)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/blakeblackshear/frigate/releases/tag/v0.18.3)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Python backend plus a node web UI, with ffmpeg and detection models, and it needs camera device passthrough. The tensorrt tag needs CUDA, a GPU variant that needs rework. Upstream publishes amd64 and arm64 images, with arm64 wheels for the main Python deps.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [ghcr.io/blakeblackshear/frigate:0.18.3](https://ghcr.io/blakeblackshear/frigate)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
