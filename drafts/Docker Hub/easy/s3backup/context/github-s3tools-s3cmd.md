# s3tools/s3cmd (GitHub)

Source URL(s) + fetch date (2026-11-26):
- https://github.com/s3tools/s3cmd (repo; README via https://raw.githubusercontent.com/s3tools/s3cmd/master/README.md)
- Not fetched (contains ${VERSION}, skipped): https://raw.githubusercontent.com/s3tools/s3cmd/v${VERSION}/LICENSE
- Install guide referenced by the README: https://github.com/s3tools/s3cmd/blob/master/INSTALL.md (not fetched)

## What it is
s3cmd is a command line tool and client for uploading, retrieving and managing data in Amazon S3 and S3-compatible services (Google Cloud Storage, DreamHost DreamObjects named). Python, GPLv2 (GPL-2.0-or-later per PyPI/plan.md). Suited to batch scripts and cron backups.

## Install
- README points to INSTALL.md; pip package name not stated in the README (PyPI `s3cmd`, per plan.md).
- Python: README says Python 2.6 or newer; Python 3 supported from s3cmd version 2.

## Commands used by the wrapper and common flows
- `s3cmd sync dir1 dir2 s3://BUCKET/somewhere/` (the wrapper README says it uses `s3cmd sync`).
- `s3cmd put FILE s3://BUCKET/FILE`, `--recursive` for trees. `get`, `get --recursive`.
- `s3cmd --configure` (creates `~/.s3cfg` interactively; Access Key and Secret Key asked).
- `ls` (`--recursive`/`-r`), `mb`, `rb --force`, `del --recursive`, `setacl`, `cp`, `mv`.
- Flags: `--acl-public`, `--acl-private`, `-v`, `-d`, `--stop-on-error` (config key `stop_on_error`).
- Failed transfers do not halt the run by default; exit status EX_PARTIAL (2).
- A trailing slash on the remote path changes how recursive `get` names local files.

## Config file
- `~/.s3cfg`, text file created by `--configure`, editable by hand.
- Only key named on the README: `stop_on_error`. Keys access_key, secret_key, host_base, host_bucket, use_https, bucket_location are not named on the README.

## Env vars
- None documented in the README.

## IAM permissions (README)
- Needs at least `s3:ListAllMyBuckets`, `s3:GetBucketLocation`, `s3:ListBucket`.
