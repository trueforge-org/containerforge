# airdcpp-webclient

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: airdcpp-webclient
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/airdcpp-webclient
- **Source repository**: https://github.com/airdcpp-web/airdcpp-webclient
- **Documentation**: http://airdcpp.net/docs/installation/installation.html
- **Website**: http://airdcpp.net/

## Potentially relevant resources

- **Website**: https://airdcpp-web.github.io
- **Container image**: https://hub.docker.com/r/gangefors/airdcpp-webclient

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Alternative runtime image**: `ghcr.io/trueforge-org/python-node`
- **Reason**: C++ daemon with a web UI on ubuntu; the Node runtime for extensions is the alternative.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: cmake, build-essential, libboost-all-dev, libssl-dev, libcurl4-openssl-dev, libsqlite3-dev, libbz2-dev, zlib1g-dev, libicu-dev, libminiupnpc-dev, libnatpmp-dev (inferred, arm64 build only), nodejs (inferred, for extensions)
- python/pip: none
- node/npm: none
- other: airdcpp portable tarball (amd64), CMake source build (arm64)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 5600/http (web UI), 21248/tcp (ADC transfers, inferred), 21248/udp (inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/airdcpp-webclient
- non-root: yes - no securityContext override, so common default 568 applies
- read-only-rootfs: yes - no override, so common default true
- privileged: no - default false, no override
- other-security: none
- extra-persistence: /.airdcpp (pvc, config dir; the Reason says it must move to /config)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the arm64 build is compiled from source with Boost and other dev packages, which makes that architecture slow to build (inferred)
- caveat: the amd64 build comes from a vendor portable tarball that is not version-pinned in the spec (inferred)
- caveat: the ADC transfer port 21248 must be forwarded from the router for active transfers to work (inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: airdcpp-webclient
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/gangefors/airdcpp-webclient:2.14.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/gangefors/docker-airdcpp-webclient/blob/master/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/airdcpp-web/airdcpp-webclient)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://web-builds.airdcpp.net/stable/airdcpp_latest_master_64-bit_portable.tar.gz)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: airdcpp C++ daemon plus web UI on containerforge-ubuntu with Node for extensions; amd64 unpacks the vendor portable tarball into /app, arm64 needs a CMake build (Boost and other dev packages) because no arm64 tarball exists. Config dir must move to /config.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: yes
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [gangefors/airdcpp-webclient:2.14.0](https://hub.docker.com/r/gangefors/airdcpp-webclient)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
