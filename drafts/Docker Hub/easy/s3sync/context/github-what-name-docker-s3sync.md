# what-name/docker-s3sync (wrapper repo)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/what-name/docker-s3sync/6c971229927957435bfd04239ba21085235fdd95/Dockerfile (fetched 2026-11-26)
- https://raw.githubusercontent.com/what-name/docker-s3sync/6c971229927957435bfd04239ba21085235fdd95/run.sh (fetched 2026-11-26)
- https://raw.githubusercontent.com/what-name/docker-s3sync/master/README.md (fetched 2026-11-26)

## What it is
Docker wrapper that backs up mounted folders under `/data` to S3 by running `aws s3 sync`. Fork of joch's S3Backup container; replaces s3cmd with the AWS CLI and is ported to Python 3. README states no license.

## Install/build steps
Dockerfile at commit 6c97122 (verbatim essentials):
- `FROM debian:latest`
- `ENV DEBIAN_FRONTEND="noninteractive" HOME="/root" LC_ALL="C.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"`
- `apt-get install -y --no-install-recommends cron python3 python3-magic python3-pip`, then `rm -rf /var/lib/apt/lists/*`
- `pip3 install setuptools wheel`, then `pip3 install awscli` (unpinned)
- `mkdir -p /data && mkdir -p /root/.aws`
- `ADD run.sh /`, `chmod +x /run.sh`
- `ENTRYPOINT ["/run.sh"]`, `CMD ["start"]`
- No `VOLUME`, `USER`, `EXPOSE` or `COPY` instructions.

## Runtime deps
cron, python3, python3-magic, python3-pip (apt); awscli (pip, unpinned in this Dockerfile). Binary used by the script: `/usr/local/bin/aws`.

## Binaries/entrypoint/CLI flags
- Entrypoint `/run.sh`, argument selects the mode: `start` (default) or `backup`; anything else exits 1 with "Unsupported option".
- `start`: appends a line to `/etc/cron.d/s3sync` (`$CRON_SCHEDULE root <inline env> bash /run.sh backup`), prints `ls -F /data`, starts `cron`, then `exec tail -f /var/log/cron.log`.
- `backup`: if `/tmp/aws-s3.lock` exists, logs and exits 1; else creates it, runs `/usr/local/bin/aws s3 sync /data/ $S3PATH $S3SYNCPARAMS` (output tee'd to log), removes the lock, logs finish.
- Script uses `set -o errexit` and `set -o pipefail`. Per the script, a failing sync can exit before the lock is removed, leaving a stale lock that blocks later runs (summary's reading of the code).

## Env vars (table)
| Variable | Use in script | Default |
| --- | --- | --- |
| `ACCESS_KEY` | written into cron line as `AWS_ACCESS_KEY_ID` | none |
| `SECRET_KEY` | written into cron line as `AWS_SECRET_ACCESS_KEY` | none |
| `REGION` | written into cron line as `AWS_DEFAULT_REGION` | none |
| `S3PATH` | sync destination, e.g. `s3://bucket[/prefix]` | none |
| `CRON_SCHEDULE` | cron expression | `0 * * * *` |
| `S3SYNCPARAMS` | extra args to `aws s3 sync` (README example: `--delete`) | empty |

## Ports
None (no server process).

## Volumes/paths and persistent data
- `/data`: folders to back up; README mounts them read-only (`/home/user:/data/user:ro`).
- `/root/.aws`: created in the image, not used by the script (credentials come from env).
- `/etc/cron.d/s3sync`: cron file written at start, contains credentials in plain text.
- `/var/log/cron.log`: log, created if missing; overwritten at start of each backup (`tee`), appended after.
- `/tmp/aws-s3.lock`: lock file.

## User/UID & permissions
Runs as root (no `USER` instruction; cron jobs run as root).

## Config files and formats
Cron file format `/etc/cron.d/s3sync` (schedule, user, command). No AWS config file is used.

## Healthcheck/readiness endpoints
None.

## Version/release info and asset naming
No tags or releases referenced by the Dockerfile; awscli installed unpinned from PyPI. README/Docker Hub: image `whatname/docker-s3sync`, only tag `latest`.

## Arch support
Not stated in the repo.

## Gotchas
- Credentials are written in plain text to `/etc/cron.d/s3sync` (per script).
- No license in repo (README and script carry none); script header says it is a fork of joch's S3Backup.
- README lists "Automatic IAM role assumption" as a to-do; only access/secret key pair is supported.
- README advises against schedules more frequent than hourly.
- Advanced README example: `S3SYNCPARAMS=--delete` removes everything else under the prefix.

## Contradictions with plan.md
- None on the wrapper's env/paths/entrypoint; plan's description matches the script.
