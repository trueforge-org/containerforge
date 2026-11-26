# ghcr.io/ich777/steamcmd (image package page)

## Source URL(s) + fetch date
- https://ghcr.io/ich777/steamcmd (returns 303 redirect to the GitHub package page)
- https://github.com/-/ich777/packages/container/package/steamcmd (followed redirect target)
- Fetched 2026-11-26

## What it is
Container package page for `ghcr.io/ich777/steamcmd`, linked to source repo `ich777/docker-steamcmd-server`. Tags are per game (the fetched page lists them as published game tags).

## Install/build steps and build deps
- Not shown on the page. The build is defined by `ich777/docker-steamcmd-server` Dockerfile (see ich777-docker-steamcmd-server.md).

## Tags seen on the page (snapshot, relative ages as shown on the page)
- `valheim` (published about 2 months before fetch)
- `palworld` (about 4 months)
- `7dtd` (about 5 months)
- `conanexiles` (about 7 months)
- `stationeers` (about 10 months)
- Page also has a "View all tagged versions" link (not followed).
- Pull command shown: `docker pull ghcr.io/ich777/steamcmd:valheim`.

## Not in the fetched content
- Base image, package description, README, Dockerfile: not shown (page partly failed to load).
- Note the README example in the source repo uses `ich777/steamcmd:latest` (Docker Hub-style name); the ghcr page showed per-game tags, not `latest`. Verify tag names before pinning.

## Gotchas
- Tag names are game names, not versions. Pick the tag for the game you need.
- Page content is partial; re-check tags directly with `docker manifest inspect` or the "View all tagged versions" page before relying on them.
