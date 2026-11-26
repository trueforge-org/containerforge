# whatname/docker-s3sync (Docker Hub)

Source URL(s) + fetch date:
- https://hub.docker.com/r/whatname/docker-s3sync (fetched 2026-11-26)

## What it is
Docker Hub image page for the s3sync wrapper: backs up folders to S3 via `aws s3 sync`, configured by environment variables. Fork of joch's S3Backup container, moved from s3cmd to the AWS CLI and Python 3.

## Env vars (table)
| Variable | Purpose |
| --- | --- |
| `ACCESS_KEY` | AWS access key |
| `SECRET_KEY` | AWS secret key |
| `REGION` | bucket region (e.g. `eu-central-1`) |
| `S3PATH` | bucket and optional path (e.g. `s3://my-nice-bucket`) |
| `S3SYNCPARAMS` | extra parameters for `aws s3 sync`, e.g. `--delete` |
| `CRON_SCHEDULE` | cron notation, default `0 * * * *` (hourly); author advises against more frequent |

## Volumes/paths and persistent data
Mount folders to back up under `/data` (examples use `:ro`).

## Version/release info and asset naming
- Only tag listed: `latest`. Image about 98.7 MB. Page shows 100K+ pulls.
- Page says last updated over 5 years ago.

## Arch support
Page lists no architectures.

## Gotchas
- Unraid Community Applications listing exists.
- IAM role assumption is listed as future work.
- Page gives no license.

## Contradictions with plan.md
- None.
