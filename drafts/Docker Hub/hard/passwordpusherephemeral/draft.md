# passwordpusherephemeral

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: hard
- **Chart**: passwordpusherephemeral
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/pglombardo/PasswordPusher

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: passwordpusherephemeral
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/pglombardo/pwpush-ephemeral:latest`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/pglombardo/PasswordPusher/blob/0590f8d12e5a59f210542fb7d86348c6e7f06a85/containers/docker/pwpush-ephemeral/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/pglombardo/PasswordPusher)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

`-` means there is none.

- **Application binary**: -

### Difficulty

`hard`: several services, musl-only, GPU, root/privileged, desktop/VNC, large stack, no public Dockerfile, or rework needed for rootless/read-only.

- **Difficulty**: hard

### Reason

- **Reason**: Ruby on Rails (Password Pusher) with gems that have native extensions, and there is no ruby sibling. The ephemeral variant runs a web app, workers and a public gateway from one universal pwpush base, so several services are needed.

### amd64 / arm64

How we get the application for that architecture.

- `compile`: there is no such executable, but the source is open and we can build it reliably ourselves.

- **amd64**: compile
- **arm64**: compile

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [pglombardo/pwpush-ephemeral:latest](https://hub.docker.com/r/pglombardo/pwpush-ephemeral)
- **copy-from arm64**: [pglombardo/pwpush-ephemeral:latest](https://hub.docker.com/r/pglombardo/pwpush-ephemeral)

### Dependency containers

- **Dependency containers**: none
