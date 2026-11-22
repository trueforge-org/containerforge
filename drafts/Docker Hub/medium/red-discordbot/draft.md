# red-discordbot

## Instructions

- The container folder structure should be the same as the ones under `/app/containername`.
- All agentic rules for these files and folders also apply to their output.

## Overview

- **Source**: Docker Hub
- **Difficulty**: medium
- **Chart**: red-discordbot
- **Rows**: 1
- **About**: one chart from `docs/project-fireball.md`, the list of container images that TrueCharts uses and ContainerForge does not have yet.

## Links

- **Source repository**: https://github.com/Cog-Creators/Red-DiscordBot
- **Documentation**: https://docs.discord.red/

## Fields

### Chart / Role

The TrueCharts chart, and whether the container is the chart's `main` image or a `sidecar` (the chart's values key is shown).

- **Chart**: red-discordbot
- **Role**: main

### Container

The image and tag the chart uses today.

- **Container**: `docker.io/phasecorex/red-discordbot:full`

### Dockerfile

The file that builds that image, traced from image labels and upstream repos.

- **Dockerfile**: [Dockerfile](https://github.com/PhasecoreX/docker-red-discordbot/blob/79e918d9c2cd87e249a1ed1a708a8b5f54f1d070/Dockerfile)

### Application source

The application's own source repository or project page.

- **Application source**: [source](https://github.com/Cog-Creators/Red-DiscordBot)

### Application binary

Where we can fetch the ready-made executable for each architecture ourselves: a release asset link, or `apt:`/`pip:`/`npm:` (package).

- **Application binary**: binary: `pip:Red-DiscordBot`

### Difficulty

`medium`: a Node/Python/Java/PHP/.NET stack ContainerForge already has, or a modest build.

- **Difficulty**: medium

### Reason

- **Reason**: Red-DiscordBot is installed by pip on the python sibling, with a multi-stage build. The full variant adds Java for Lavalink audio, which needs the java sibling. Data goes in /config, and the bot is a single long-running process.

### amd64 / arm64

How we get the application for that architecture.

- `yes`: we can fetch a ready-made executable ourselves, outside any `COPY --from`: a release asset, an official package, a pip/npm package, a JAR or a vendor download. Interpreted apps count as `yes`.

- **amd64**: yes
- **arm64**: yes

### copy-from amd64 / copy-from arm64

A separate option, always filled in, whatever the `amd64`/`arm64` columns say. It is a link to the container image the binary can be copied out of with `COPY --from=<image>` (the upstream Dockerfile compiled it, not us).

- **copy-from amd64**: [phasecorex/red-discordbot:full](https://hub.docker.com/r/phasecorex/red-discordbot)
- **copy-from arm64**: [phasecorex/red-discordbot:full](https://hub.docker.com/r/phasecorex/red-discordbot)

### Dependency containers

- **Dependency containers**: none
