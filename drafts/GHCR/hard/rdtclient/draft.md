# rdtclient

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: hard
- **Chart**: rdtclient
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (aria2)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/rdtclient
- **Source repository**: https://github.com/rogerfar/rdt-client

## Potentially relevant resources

- **Container image**: https://ghcr.io/p3terx/aria2-pro
- **Container image**: https://ghcr.io/rogerfar/rdtclient

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: .NET server with a build-time Node client; the .NET runtime is installed on ubuntu.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: unzip (inferred), aspnetcore runtime (Microsoft repo, inferred)
- python/pip: none
- node/npm: npm packages for the build-time web client (inferred)
- other: RealDebridClient.zip v2.0.143 release; aria2-pro sidecar (image, not a package)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 6500/http (web UI, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/rdtclient
- non-root: no - chart sets runAsNonRoot false and runAsUser 0, including the aria2 sidecar
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false, including the aria2 sidecar
- privileged: no - not set in values
- other-security: none in values; aria2 sidecar runs as root
- extra-persistence: /data/db (db, pvc chart default)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: a Real-Debrid account and API token must be entered in the UI before it does anything (account needed, inferred)
- caveat: the aria2-pro sidecar it depends on is missing from ContainerForge, and it runs as root with a writable rootfs
- caveat: download and data paths under /data must be mounted with enough space (resource needs, inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: rdtclient
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/rogerfar/rdtclient:2.0.143`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/rogerfar/rdt-client/blob/a669bd3/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/rogerfar/rdt-client)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/rogerfar/rdt-client/releases/download/v2.0.143/RealDebridClient.zip)

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: RDT Client is a .NET server with a node-built web client; the release ships RealDebridClient.zip, but ContainerForge has no .NET runtime base, so the runtime must be added. The chart also pairs it with an aria2 sidecar (reuse aria2) and the upstream linuxserver s6 base needs rework for rootless read-only use.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- A trailing `*` means the claim could not be confirmed against the upstream source, so it is a best judgement and should be rechecked before porting.

- **amd64**: yes*
- **arm64**: yes*

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

❌ means it is missing too.

- **Dependency containers**: aria2-pro (aria2Image) ❌
