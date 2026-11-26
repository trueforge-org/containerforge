# knex666/shortipy (Docker Hub)

Source URL(s) + fetch date:
- https://hub.docker.com/r/knex666/shortipy (fetched 2026-11-26)

## What it is
URL shortener in Python based on Flask (per the page). 10K+ pulls. Published by knex666; no source link on the page (only a donation link and a screenshot).

## Install/build steps
- `docker pull knex666/shortipy`
- Example run: `docker run -d --name='shortipy' -v '/home/user/shortipy':'/shortipy/data':'rw' 'knex666/shortipy' /start.sh`

## Entrypoint
`/start.sh` (page). The upstream Dockerfile at 52afd09 does not define `/start.sh`.

## Env vars
None documented.

## Ports
App listens on 4321 inside the container (map to any host port).

## Volumes/paths and persistent data
Mount a host directory at `/shortipy/data` for the database.

## Version/release info and asset naming
- Tag shown: `latest` only (digest begins sha256:7cd696ae…, ~198.7 MB). Tag updated about 4 years ago; repository described as updated over 1 year ago. No exact dates.

## Arch support
Not listed.

## Gotchas
- Image path and entrypoint do not match the upstream Dockerfile at 52afd09 (see github-maschhoff-shortipy.md).
- Published tag is `latest` only, so there is no version to pin from this page.

## Contradictions with plan.md
- plan.md's claim that the knex666 image is built from `maschhoff/shortipy` at 52afd09 is only partly supported (Dockerfile comment yes; entrypoint and data path no).
