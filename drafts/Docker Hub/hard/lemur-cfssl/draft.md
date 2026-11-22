# lemur-cfssl

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: lemur-cfssl
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/lemur-cfssl
- **Source repository**: https://github.com/Netflix/lemur
- **Documentation**: https://lemur.readthedocs.io/
- **Documentation**: https://lemur.readthedocs.io/en/latest/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/halianelf/lemur

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Alternative runtime image**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`)
- **Reason**: Python Flask app installed from pip, with the Go CFSSL service secondary.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: libpq-dev (inferred), supervisor (inferred)
- python/pip: lemur
- node/npm: none
- other: CFSSL Go binary from release

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8000/http (Lemur web UI and API), 8888/http (CFSSL API, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/lemur-cfssl
- non-root: no - chart sets runAsUser 0, runAsGroup 0
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - not set, common default false
- other-security: none in values
- extra-persistence: /data (pvc, chart default); /config is the chart's own mount
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: Needs an external PostgreSQL database; the chart expects one to be present before Lemur starts (inferred).
- caveat: The CFSSL CA keys and Lemur's data live under /data, so losing that path means losing the certificate authority.
- caveat: The first admin user is created by hand from the Lemur CLI, so setup is not done in the UI alone (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: lemur-cfssl
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/halianelf/lemur:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

`-` means no public Dockerfile could be found.

- **Dockerfile**: -

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Netflix/lemur)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `pip:lemur`

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Two services in one stack: Netflix Lemur (Python Flask) and CFSSL (Go), plus a postgres database. No Dockerfile for this image was found. Porting means running both processes under a supervisor and setting up the database on containerforge-ubuntu.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [halianelf/lemur:latest](https://hub.docker.com/r/halianelf/lemur)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
