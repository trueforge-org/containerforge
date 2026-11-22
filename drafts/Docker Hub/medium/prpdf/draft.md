# prpdf

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: prpdf
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/prpdf
- **Source repository**: https://github.com/maschhoff/pdfscanexplorer

## Potentially relevant resources

- **Source code repository**: https://github.com/maschhoff/prpdf
- **Container image**: https://hub.docker.com/r/knex666/prpdf

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Alternative runtime image**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`)
- **Reason**: Python tool with pip requirements on the python base, with jbig2enc and Ghostscript from apt.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: jbig2enc; ghostscript
- python/pip: project requirements.txt (inferred) ([requirements.txt](https://github.com/maschhoff/pdfscanexplorer/blob/HEAD/requirements.txt))
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 5000/http (web UI, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/prpdf
- non-root: no - runAsUser 0, runAsGroup 0 in values
- read-only-rootfs: no - chart sets readOnlyRootFilesystem false
- privileged: no - common default false, not overridden
- other-security: none shown; hostpath2 persistence may be a hostPath mount (type not in values)
- extra-persistence: /Archiv/ (files, pvc default); /source/static/pdf/ (hostpath2, type not shown, name suggests hostPath)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: The Ghostscript version from apt may differ from the upstream 10.03.1 build, so output should be compared against upstream (from the draft).
- caveat: The hostpath2 mount at /source/static/pdf may need a hostPath, which carries host-side ownership and permission constraints (inferred).
- caveat: The Docker Hub image knex666/prpdf is a third-party build of the upstream tool.

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: prpdf
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/knex666/prpdf:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/maschhoff/prpdf/blob/132fcad/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/maschhoff/pdfscanexplorer)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/maschhoff/pdfscanexplorer/releases/tag/1.0.2)

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Python PDF tool whose Dockerfile compiles jbig2enc and Ghostscript 10.03.1 from source. On ubuntu both are apt packages, so the compile can be dropped in favour of the python sibling plus pip requirements. Only the Ghostscript version may differ from upstream, so output should be checked.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: [knex666/prpdf:latest](https://hub.docker.com/r/knex666/prpdf)
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
