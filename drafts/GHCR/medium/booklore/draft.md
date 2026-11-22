# booklore

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: booklore
- **Rows**: 1
- **Hard dependency containers**: yes (mariadb)
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/booklore
- **Source repository**: https://github.com/booklore-app/booklore

## Potentially relevant resources

- **Container image**: https://ghcr.io/booklore-app/booklore

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: [java25](https://github.com/trueforge-org/containerforge/tree/main/apps/java25) (`ghcr.io/trueforge-org/java25`)
- **Reason**: Spring Boot jar that the reason says runs on the java25 base.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: Angular frontend build deps (inferred)
- other: JDK and Gradle for the Spring Boot jar (inferred)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 6060/http (web UI and API) (inferred)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/booklore
- non-root: possible - chart sets runAsUser/runAsGroup 0 and readOnlyRootFilesystem false; Spring Boot jar should run as non-root
- read-only-rootfs: possible - chart sets readOnlyRootFilesystem false; data is a pvc mount, temp in /tmp
- privileged: no - common default false, no chart override
- other-security: none
- extra-persistence: /bookdrop (pvc, chart-level); /app/data (pvc, chart-level, draft may move data to /config)
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: MariaDB is a hard dependency and must be created and reachable before the first start (spec).
- caveat: there is no release binary, so the Gradle and Angular build must run at image build time on both architectures, which is slow (spec).
- caveat: the Spring Boot service needs a sizeable heap, so small hosts may run out of memory (inferred).

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: booklore
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `ghcr.io/booklore-app/booklore:v2.4.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/booklore-app/booklore/blob/f397e98c5ab021b02e8930ce278583af11637238/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/booklore-app/booklore)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Spring Boot jar built with Gradle from Java source, with an Angular frontend built in a separate stage, then copied into a temurin JRE. The java25 sibling covers the runtime, and MariaDB is external. The Gradle and Angular build is the main effort.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- **copy-from amd64**: no
- **copy-from arm64**: no

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: mariadb ✅
