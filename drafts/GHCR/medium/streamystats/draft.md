# streamystats

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: GHCR
- **Difficulty**: medium
- **Chart**: streamystats
- **Rows**: 2
- **Hard dependency containers**: no
- **Optional dependency containers**: no
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/streamystats
- **Source repository**: https://github.com/fredrikburmester/streamystats

## Potentially relevant resources

- **Container image**: https://ghcr.io/fredrikburmester/streamystats-job-server
- **Container image**: https://ghcr.io/fredrikburmester/streamystats-nextjs

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- Row 1: **Chart**: streamystats
- Row 1: **Role**: main
- Row 2: **Chart**: streamystats
- Row 2: **Role**: sidecar (jobServerImage)

### Container

The image and tag the chart uses today.

- Row 1: **Container**: `ghcr.io/fredrikburmester/streamystats-nextjs:v2.22.3`
- Row 2: **Container**: `ghcr.io/fredrikburmester/streamystats-job-server:v2.22.3`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- Row 1: **Dockerfile**: [Dockerfile](https://github.com/fredrikburmester/streamystats/blob/4049ac60351575c68639fcf8db76a4f477df8ab2/apps/nextjs-app/Dockerfile)
- Row 2: **Dockerfile**: [Dockerfile](https://github.com/fredrikburmester/streamystats/blob/4049ac60351575c68639fcf8db76a4f477df8ab2/apps/job-server/Dockerfile)

### Application source

The application's own source repository or project page.

- Row 1: **Application source**: [source](https://github.com/fredrikburmester/streamystats)
- Row 2: **Application source**: [source](https://github.com/fredrikburmester/streamystats)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- Row 1: **Application binary**: [binary](https://github.com/fredrikburmester/streamystats/releases/tag/v2.22.3)
- Row 2: **Application binary**: -

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- Row 1: **Difficulty**: medium
- Row 2: **Difficulty**: medium

### Reason

- Row 1: **Reason**: Next.js standalone app built with node in a builder stage; reuse the node sibling and copy the standalone output into /app. Needs Postgres, and the separate job-server image is a second process that adds work. Otherwise a moderate Node build with no unusual native deps.
- Row 2: **Reason**: Bun/TypeScript monorepo app compiled to a standalone binary with bun build --compile; build on containerforge-ubuntu with the node base plus bun. Needs Postgres externally but no extra services in the image.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.
- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- Row 1: **amd64**: yes
- Row 1: **arm64**: yes
- Row 2: **amd64**: compile
- Row 2: **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

The value is `no` when that image is not published for the architecture or is a musl (alpine) build, which does not run on glibc Ubuntu.

- Row 1: **copy-from amd64**: no
- Row 1: **copy-from arm64**: no
- Row 2: **copy-from amd64**: [ghcr.io/fredrikburmester/streamystats-job-server:v2.22.3](https://ghcr.io/fredrikburmester/streamystats-job-server)
- Row 2: **copy-from arm64**: [ghcr.io/fredrikburmester/streamystats-job-server:v2.22.3](https://ghcr.io/fredrikburmester/streamystats-job-server)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

❌ means it is missing too.

- Row 1: **Dependency containers**: postgresql ✅, streamystats-job-server (jobServerImage) ❌
- Row 2: **Dependency containers**: -
