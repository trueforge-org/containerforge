# whatname/docker-s3sync (Docker Hub)

Source URL(s) + fetch date:
- https://hub.docker.com/r/whatname/docker-s3sync (fetched 2026-11-26)

## What it is
Image page for the wrapper: backs up folders to S3 via `aws s3 sync`, configured by environment variables. Forked from joch's S3Backup container.

## Version/release info and asset naming
- Only tag listed: `latest`.
- Page says last updated over 5 years ago. Pull count 100K+. Image size shown 98.7 MB.
- Pull command: `docker pull whatname/docker-s3sync`.

## Arch support
Not shown on the page.

## Env vars
Same six variables as the wrapper repo: `ACCESS_KEY`, `SECRET_KEY`, `REGION`, `S3PATH`, `S3SYNCPARAMS`, `CRON_SCHEDULE` (default `0 * * * *`).

## Volumes/paths
Mount folders to back up under `/data`.

## Gotchas
- Stale (last updated 5+ years ago per the page), matching the plan's note of last push 2022-10-07 on the source repo.
