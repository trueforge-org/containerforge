# Docker Hub: davidspek/homelablabelmaker

Source URL(s) + fetch date: https://hub.docker.com/r/davidspek/homelablabelmaker · fetched 2026-11-26 (JS-heavy page; fields are what the fetch returned)

## What it is
DIY tool for making and printing drive caddy labels for Dell PowerEdge, HP ProLiant and SuperMicro servers.

## Install/build steps
- Pull: `docker pull davidspek/homelablabelmaker`.
- Run: map container port 80 to a host port (`-p <hostport>:80`). No exact run command on the page.

## Ports
- Container port 80 is the only documented requirement.

## Volumes/paths and persistent data
- None documented.

## Env vars (table)
- None documented.

## Version/release info
- Only tag `latest`. Size 41.8 MB. Pull count 100K+. Last updated over 6 years ago. Digest not shown.

## Arch support
- Not shown on the page.

## Gotchas
- Port 80 here and in the TrueCharts chart; plan.md uses 8080 (ContainerForge nginx base default). Plan.md is the intended behaviour for the new image.
