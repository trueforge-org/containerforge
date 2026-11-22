# vikunja

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: easy
- **Chart**: vikunja
- **Rows**: 1
- **Hard dependency containers**: no
- **Optional dependency containers**: yes (postgresql, valkey)
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **TrueCharts chart**: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/vikunja
- **Source repository**: https://github.com/go-vikunja/vikunja
- **Documentation**: https://vikunja.io/docs/

## Potentially relevant resources

- **Container image**: https://hub.docker.com/r/vikunja/vikunja

## Base container

- **Foundation**: [ubuntu](https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu) (`ghcr.io/trueforge-org/ubuntu`), which every ContainerForge runtime image is built on
- **Runtime image**: none (ubuntu alone is enough)
- **Reason**: Go binary from release archives, run from /app.

## Package requirements

Packages the Dockerfile will most likely need, inferred from this spec. `(inferred)` marks a guess.

- apt: none
- python/pip: none
- node/npm: none
- other: release archive veans-v2.8.0 (amd64 zip; arm64 link is .apk, recheck)

## Ports

Ports the software is likely to listen on inside the container (container side, not host-forwarded). `(inferred)` marks a guess.

- ports: 3456/http (web UI and API)

## Security expectations

What the TrueCharts values.yaml (expanded from the common library defaults) suggests for this container. These are expectations to verify, not guarantees.

- chart: charts/stable/vikunja
- non-root: possible - chart sets runAsNonRoot false and runAsUser 0, but a Go binary needs no root
- read-only-rootfs: possible - chart sets false; draft keeps state in /config
- privileged: no - not set, common default false
- other-security: capabilities add NET_BIND_SERVICE (chart)
- extra-persistence: /app/vikunja/files (pvc, uploads) unless moved under /config
- confidence: medium

## Other potential caveats

Things to watch for beyond the security settings. `(inferred)` marks a guess; treat these as things to verify.

- caveat: Needs an external PostgreSQL or SQLite-on-/config setup; the valkey sibling is optional and only helps caching (inferred).
- caveat: Uploads default to /app/vikunja/files, so the draft must move them under /config or they will not persist (inferred).
- caveat: The arm64 release link in the draft is an .apk and the amd64 one is a zip; the arm64 artifact must be rechecked before porting.

## Fields
### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: vikunja
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/vikunja/vikunja:2.8.0`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/go-vikunja/vikunja/blob/v2.8.0/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/go-vikunja/vikunja)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: [amd64](https://github.com/go-vikunja/vikunja/releases/download/v2.8.0/veans-v2.8.0-linux-amd64-full.zip) · [arm64](https://github.com/go-vikunja/vikunja/releases/download/v2.8.0/veans-v2.8.0-aarch64.apk)

### Difficulty

`easy`: prebuilt binary, close sibling or steamcmd game server.

- **Difficulty**: easy

### Reason

- **Reason**: Go API with the frontend embedded, shipped as release archives for linux amd64 and arm64. ContainerForge can run the binary from /app with data under /config. A valkey sibling is optional, and it runs as a single process.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [vikunja/vikunja:2.8.0](https://hub.docker.com/r/vikunja/vikunja)
- **copy-from arm64**: [vikunja/vikunja:2.8.0](https://hub.docker.com/r/vikunja/vikunja)

### Dependency containers

Other containers the chart needs (Chart.yaml dependencies, PostgreSQL, sidecars).

✅ means ContainerForge already has an app for it.

- **Dependency containers**: valkey ✅, postgresql ✅
