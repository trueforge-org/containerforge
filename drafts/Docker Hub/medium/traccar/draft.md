# traccar

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: traccar
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (postgresql)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/traccar
- **Source repository**: https://github.com/traccar/traccar
- **Documentation**: https://www.traccar.org/documentation/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/traccar/traccar

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [java17](https://github.com/trueforge-org/containerforge/tree/main/apps/java17) (`ghcr.io/trueforge-org/java17`)
- **Alternative runtime image**: [java21](https://github.com/trueforge-org/containerforge/tree/main/apps/java21) (`ghcr.io/trueforge-org/java21`)
- **Reason**: The input says Java 17 or later is needed, so java17 is the minimum that fits.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: traccar release zip (bundled runtime)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8082/http (web UI and API), 5055/tcp (inferred, example device port; server opens many device ports)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/traccar
- non-root: no - runAsUser 0, runAsGroup 0, runAsNonRoot false overrides
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default privileged false, not overridden
- other-security: none in values (device ports listed in draft, not in values)
- extra-persistence: /opt/traccar/data (pvc, chart-defined)
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: Server opens many device ports (TCP and UDP) that depend on the GPS devices in use; each protocol port must be published or the devices cannot connect.
- caveat: Java 17 or later is required; the bundled runtime in the zip may differ from the sibling java17, so check which JRE is used (inferred).
- caveat: Upstream release asset links were not confirmed, so the arm64 zip needs verifying before porting.

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: traccar
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/traccar/traccar:6.17`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/traccar/traccar/blob/45ae7321fe56688ca26f2f5b62e6dbb7a4737562/docker/Dockerfile.alpine)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/traccar/traccar)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/traccar/traccar/releases/download/v6.17.0/traccar-linux-64-6.17.0.zip) · [arm64](https://github.com/traccar/traccar/releases/download/v6.17.0/traccar-other-6.17.0.zip)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Java GPS tracking server distributed as a zip that includes the traccar JAR and a bundled runtime. It can run on a ContainerForge java sibling with data under /config. Java 17 or later is needed, and the server listens on many device ports. Upstream release assets were not confirmed (GitHub returned 429).

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

✅ means ContainerForge already has an app for it.

- **Dependency containers**: postgresql ✅
