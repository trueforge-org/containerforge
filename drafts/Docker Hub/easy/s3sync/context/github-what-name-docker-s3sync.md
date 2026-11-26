# what-name/docker-s3sync (wrapper repo)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/what-name/docker-s3sync/master/README.md (fetched 2026-11-26)
- https://raw.githubusercontent.com/what-name/docker-s3sync/6c971229927957435bfd04239ba21085235fdd95/Dockerfile (fetched 2026-11-26)
- https://raw.githubusercontent.com/what-name/docker-s3sync/6c971229927957435bfd04239ba21085235fdd95/run.sh (fetched 2026-11-26)

## What it is
Container that backs up folders to S3 with the AWS CLI (`aws s3 sync`). Fork of joch's S3Backup container; swaps s3cmd for aws cli and moves to Python 3. Listed in Unraid Community Applications.

## Install/build steps and build deps
Dockerfile at commit 6c97122:
- `FROM debian:latest`
- `ENV DEBIAN_FRONTEND=noninteractive HOME=/root LC_ALL=C.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8`
- apt (`--no-install-recommends`): `cron python3 python3-magic python3-pip`; lists removed.
- `pip3 install setuptools wheel`, then `pip3 install awscli`, then `/tmp/pip_build_root/` removed.
- `mkdir -p /data /root/.aws`
- `ADD run.sh /` then `chmod +x /run.sh`
- `ENTRYPOINT ["/run.sh"]`, `CMD ["start"]`
- No VOLUME, WORKDIR, USER or EXPOSE.

## Runtime deps
cron daemon, python3, aws cli (pip `awscli`). Cron is used to schedule syncs.

## Binaries/entrypoint/CLI flags
`/run.sh <option>`; options:
- `start` (default CMD): lists `/data` (`ls -F`), appends a cron line to `/etc/cron.d/s3sync`, starts `cron`, then `exec tail -f /var/log/cron.log`.
- `backup`: called by cron as `bash /run.sh backup`. Runs `/usr/local/bin/aws s3 sync /data/ $S3PATH $S3SYNCPARAMS`.
- anything else: "Unsupported option" and exit 1.

## Env vars
| Name | Meaning | Default |
| --- | --- | --- |
| ACCESS_KEY | becomes AWS_ACCESS_KEY_ID in cron env | none |
| SECRET_KEY | becomes AWS_SECRET_ACCESS_KEY | none |
| REGION | becomes AWS_DEFAULT_REGION | none |
| S3PATH | destination, e.g. `s3://bucket[/prefix]` | none |
| S3SYNCPARAMS | extra args to `aws s3 sync` (README example `--delete`) | none |
| CRON_SCHEDULE | cron expression | `0 * * * *` |

Note: README says the author advises against schedules more frequent than hourly.

## Ports
None.

## Volumes/paths and persistent data
- Source folders are mounted under `/data` (README examples mount read-only, e.g. `-v /home/user:/data/user:ro`).
- Writes: `/var/log/cron.log` (truncated by `tee` on each backup, then appended), `/etc/cron.d/s3sync` (appended on every `start`, so repeated starts duplicate lines), `/tmp/aws-s3.lock` (created and removed per run).
- No persistent state volume.

## User/UID & permissions
Runs as root (no USER). Cron runs as root.

## Config files and formats
Cron file `/etc/cron.d/s3sync` is generated at start. Credentials are written into it in plaintext.

## Healthcheck/readiness endpoints
None.

## Version/release info
No tags or releases on the README; image tag `latest` only (see Docker Hub summary).

## Arch support
Not stated in the README.

## Gotchas
- Lock file: `set -o errexit` + `pipefail` means a failed sync exits before `rm -f` of the lock, leaving `/tmp/aws-s3.lock` that blocks later runs.
- `start` appends to cron file each time, so restarts duplicate cron jobs.
- `S3SYNCPARAMS` and `S3PATH` are unquoted (word splitting).
- `--delete` in S3SYNCPARAMS removes everything else under the target prefix.
- Credentials in plaintext in `/etc/cron.d/s3sync`.
- README lists an IAM role assumption as a future to-do; key pair is used otherwise.
- Draft/plan note: the Dockerfile's `FROM debian:latest` is not a pinned base.
