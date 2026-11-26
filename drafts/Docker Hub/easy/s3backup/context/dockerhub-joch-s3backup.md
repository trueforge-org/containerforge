# joch/s3backup (Docker Hub)

Source URL(s) + fetch date (2026-11-26):
- https://hub.docker.com/r/joch/s3backup (fetched)
- https://registry.hub.docker.com/r/joch/s3backup (listed in draft; same image, not fetched separately)

## What it is
Container that backs up one or more folders to S3 using `s3cmd sync`. Updated about 7 years before fetch. 100K+ pulls, 2 stars.

## Tags and arch
- Only `latest`, 65.6 MB, digest sha256:f81c2bb5... Pull: `docker pull joch/s3backup`.
- No architectures listed.

## Env vars (page)
- ACCESS_KEY, SECRET_KEY, S3PATH (bucket and path), S3CMDPARAMS, CRON_SCHEDULE (default hourly `0 * * * *`).

## Ports
- None.

## Volumes
- Mount folders under `/data` (example `:ro`).

## Schedule
- Hourly by default. `0 3 * * *` = daily at 03:00.

## Compose
- None on the page. Run example is the same as github-joch-docker-s3backup.md.
