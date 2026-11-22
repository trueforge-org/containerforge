# kms

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: kms
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/kms
- **Source repository**: https://github.com/Py-KMS-Organization/py-kms
- **Documentation**: https://py-kms.readthedocs.io/en/latest/

## Potentially relevant resources

- **Container image**: https://ghcr.io/py-kms-organization/py-kms

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Pure Python server installed from requirements.txt.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: py-kms (inferred, from repo requirements.txt) ([requirements.txt](https://github.com/Py-KMS-Organization/py-kms/blob/HEAD/requirements.txt))
- node/npm: none
- other: none

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 1688/tcp (KMS activation)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/kms
- non-root: possible - chart sets runAsUser 0 and runAsNonRoot false; the draft is one Python process on an unprivileged port, so it needs no root
- read-only-rootfs: possible - chart sets readOnlyRootFilesystem false; the server writes no files
- privileged: no - no privileged key in values; common default false
- other-security: none
- extra-persistence: none
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: py-kms is a KMS activation emulator; using it is only for licensed products and must follow local licensing rules (inferred).
- caveat: KMS clients look for port 1688 (often via DNS SRV records); if the container is mapped to another port, clients need explicit configuration (inferred).
- caveat: copy-from is no for both architectures, so the image must install py-kms with pip on the python base; the pinned release (v1.0.1) must be re-checked against the pip package.

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: kms
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/py-kms-organization/py-kms:minimal`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/Py-KMS-Organization/py-kms/blob/b0e1615/docker/docker-py3-kms-minimal/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Py-KMS-Organization/py-kms)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/Py-KMS-Organization/py-kms/releases/tag/v1.0.1)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Py-KMS is a pure Python server installed from requirements.txt, so one pip install into /app on the python base covers it. It is a single process that listens on port 1688, which can be mapped to an unprivileged port. Nothing else runs in the image.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

- **Dependency containers**: none
