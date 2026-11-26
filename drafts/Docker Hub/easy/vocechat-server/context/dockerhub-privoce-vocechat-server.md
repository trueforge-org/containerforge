# Docker Hub: privoce/vocechat-server

Source URL(s) + fetch date: https://hub.docker.com/r/privoce/vocechat-server · fetched 2026-11-26

## What it is
- "20MB Private Chat Server" built with Rust, TypeScript and Flutter. Maintainer `privoce`. 500K+ pulls.

## Run
- `docker run` detached, `--restart=always`, named `vocechat-server`, host port mapped to container port 3000 (3456 in the example), host data directory mounted at `/home/vocechat-server/data`. Browse to the host and chosen port.
- Pull: `docker pull privoce/vocechat-server`. Image `privoce/vocechat-server:latest`.

## Env vars
- None documented.

## Ports
- Container port 3000.

## Volumes
- `/home/vocechat-server/data`.

## Version/release info
- Only `latest` tag shown (digest `sha256:729a6a96...`, 24.3 MB, updated about 6 days before capture).

## Arch support
- Not documented on this page.

## Gotchas
- The `latest` digest prefix (`sha256:729a6a96...`) matches the TrueCharts chart's `v0.5.41` digest prefix, so the chart and `latest` appear to be the same build (prefix match only).
