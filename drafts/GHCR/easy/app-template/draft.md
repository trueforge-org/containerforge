# app-template

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: easy
- **Chart**: app-template
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (mariadb, valkey, mongodb)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/app-template
- **Source repository**: https://github.com/MiguelNdeCarvalho/speedtest-exporter
- **Documentation**: https://docs.miguelndecarvalho.pt/projects/speedtest-exporter/

## Potentially relevant resources

- **Container image**: https://ghcr.io/miguelndecarvalho/speedtest-exporter

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [python](https://github.com/trueforge-org/containerforge/tree/main/apps/python) (`ghcr.io/trueforge-org/python`)
- **Reason**: Python Prometheus exporter installed with pip into /app.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none (ca-certificates, curl inferred)
- python/pip: packages from upstream requirements.txt (inferred, names not in draft) ([src/requirements.txt](https://github.com/MiguelNdeCarvalho/speedtest-exporter/blob/HEAD/src/requirements.txt))
- node/npm: none
- other: Ookla speedtest CLI tarball per arch

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 9798/http (Prometheus metrics, inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/app-template
- non-root: yes - no securityContext override, so runAsUser 568 default
- read-only-rootfs: yes - default readOnlyRootFilesystem true; draft writes nothing at runtime beyond /tmp
- privileged: no - default false
- other-security: none; redis, mariadb and mongodb disabled
- extra-persistence: none
- confidence: high

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: The Ookla speedtest CLI is fetched per architecture, so the build or start needs internet access to Ookla's download host (inferred).
- caveat: The exporter has no UI and needs a Prometheus scraper to be useful, and each run consumes real bandwidth on the host (inferred).
- caveat: The chart uses a pinned v3.5.4 image, so the draft's build must track that tag rather than latest.

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: app-template
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/miguelndecarvalho/speedtest-exporter:v3.5.4`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/MiguelNdeCarvalho/speedtest-exporter/blob/v3.5.4/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/MiguelNdeCarvalho/speedtest-exporter)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [binary](https://github.com/MiguelNdeCarvalho/speedtest-exporter/releases/tag/v3.5.4)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Python Prometheus speedtest exporter installed with pip from requirements into /app on the python base. It also downloads the Ookla speedtest CLI tarball for the target arch. Single process with no extra services; same image as the speedtest-exporter row.

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

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: mariadb ✅, valkey ✅, mongodb ✅
