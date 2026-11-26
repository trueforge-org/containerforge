# hub.docker.com/r/raesene/bwapp (community image, draft "Container image")

Source URL(s) + fetch date:
- https://hub.docker.com/r/raesene/bwapp · fetched 2026-11-26

## What it is
Containerized deployment of the OWASP bWAPP project, maintained by `raesene`. 100K+ pulls, rating 60.

## Tags/arch/digest
- Only tag: `latest` (digest starts `sha256:2f41183ea…`). Size about 152.4 MB. Architectures not stated. Last updated over 4 years before the fetch.

## Base image
`tutum/lamp` (https://hub.docker.com/r/tutum/lamp/), per the Docker Hub page. Note: base is an old LAMP image, not ubuntu.

## Run
- `docker run -d -p 80:80 raesene/bwapp`; container port 80.
- After start, visit `/install.php` to set up the instance.
- No env vars or volumes listed.

## Status
- Repo archived; author no longer works on it and invites forks.

## Gotchas
- The published image is root-based; TrueCharts values show `runAsUser 0` and `readOnlyRootFilesystem false` (see truecharts-bwapp.md).
- The Docker Hub page has no Dockerfile link; the plan's `Dockerfile: -` matches.
