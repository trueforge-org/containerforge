# rss-proxy

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: rss-proxy
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/rss-proxy
- **Source repository**: https://github.com/damoeb/rss-proxy

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/damoeb/rss-proxy

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [java17](https://github.com/trueforge-org/containerforge/tree/main/apps/java17) (`ghcr.io/trueforge-org/java17`)
- **Alternative runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: Guess: a JVM server with a Node side and no Java version named, so java17 is used.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: node runtime (inferred, from python-node alternative)
- other: feedless core JVM app (upstream image, damoeb/feedless), headless browser rendering (inferred), java17 base

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (web UI and API, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/rss-proxy
- non-root: no - runAsUser 0 and runAsGroup 0, no override
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set in values (default false)
- other-security: none
- extra-persistence: none in values
- confidence: low

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the wrapper only sets FROM the damoeb/feedless core image, so the real app is a JVM plus Node stack with headless browser rendering, which is large (spec).
- caveat: there are no release assets, so the app can only be built or copied from the upstream image; the upstream tag is `latest`, which is rolling (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: rss-proxy
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/damoeb/rss-proxy:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/damoeb/rss-proxy/blob/d91dbdef4051951fc7a6d209a23aea55b5f85a1d/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/damoeb/rss-proxy)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/damoeb/rss-proxy/releases)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Wrapper that only sets FROM damoeb/feedless core image, so the real app is feedless, a JVM and Node stack with browser rendering and no release assets. Rebuilding it from source means a large stack and likely several services.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [damoeb/rss-proxy:latest](https://hub.docker.com/r/damoeb/rss-proxy)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
