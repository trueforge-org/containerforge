# volsync

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Quay
- **Difficulty**: medium
- **Chart**: volsync
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/volsync
- **Source repository**: https://github.com/backube/volsync
- **Documentation**: https://volsync.readthedocs.io/

## Potentially relevant resources

- **Source code repository**: https://github.com/backube/helm-charts
- **Container image**: https://quay.io/backube/volsync

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go operator compiled from source with helper binaries built in stages.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: Go modules compiled from source; rclone, restic, syncthing helper binaries built or fetched

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 8080/http (metrics, inferred), 8081/http (health probe, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/volsync
- non-root: yes - no securityContext override, common default 568 (operator)
- read-only-rootfs: yes - common default readOnlyRootFilesystem true for the operator; no runtime state
- privileged: unknown - --scc-name=volsync-privileged-mover makes data movers use a privileged SCC; operator's own privilege not set in values
- other-security: none in operator container; cluster-wide RBAC incl. use of the privileged-mover SCC and PV updates
- extra-persistence: none (cluster-only)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: the operator needs its CRDs installed in the cluster; it does nothing standalone (inferred)
- caveat: the privileged mover uses an OpenShift SCC by default, so non-OpenShift clusters need a different privileged configuration (inferred)
- caveat: the operator release only carries kubectl plugin tarballs, so the helper binaries (rclone, restic, syncthing) must be built or fetched at image build time (inferred)

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: volsync
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `quay.io/backube/volsync:0.16.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/backube/volsync/blob/22b97b0717c74f328853d92877151392ff5ecb42/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/backube/volsync)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Go Kubernetes operator whose manager must be compiled, plus rclone, restic and syncthing helper binaries built or fetched in separate stages. Cluster-only; the release carries just the kubectl plugin tarballs.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [quay.io/backube/volsync:0.16.0](https://quay.io/repository/backube/volsync)
- **copy-from arm64**: [quay.io/backube/volsync:0.16.0](https://quay.io/repository/backube/volsync)

### Dependency containers

- **Dependency containers**: none
