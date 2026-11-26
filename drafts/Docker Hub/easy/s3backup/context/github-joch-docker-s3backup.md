# joch/docker-s3backup (GitHub, wrapper image)

Source URL(s) + fetch date (2026-11-26):
- https://raw.githubusercontent.com/joch/docker-s3backup/87e6354/Dockerfile (draft cites blob/87e6354/Dockerfile)
- https://raw.githubusercontent.com/joch/docker-s3backup/master/README.md (repo README; master branch)
- https://github.com/joch/docker-s3backup (repo page, not fetched directly)

## What it is
Docker container that backs up one or more host folders to S3 with `s3cmd sync`, on a cron schedule. Last updated about 2019 (per plan.md and Docker Hub). License per plan.md: GPL-3.0 (not fetched here).

## Dockerfile (commit 87e6354)
```
FROM debian:jessie
MAINTAINER Johnny Chadda <johnny@chadda.se>
ENV DEBIAN_FRONTEND="noninteractive" HOME="/root" LC_ALL="C.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US.UTF-8"
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      cron python python-magic python-pip && \
    rm -rf /var/lib/apt/lists/*
RUN pip install s3cmd && \
  rm -rf /tmp/pip_build_root/
RUN mkdir -p /data
ADD s3cmd.cfg /root/.s3cfg
ADD run.sh /
ENTRYPOINT ["/run.sh"]
CMD ["start"]
```
- Single stage. Base debian:jessie (EOL, Python 2 era packages: python, python-pip, python-magic).
- No ARG, COPY, WORKDIR, EXPOSE, VOLUME, USER, HEALTHCHECK.
- Config: `/root/.s3cfg` added from the build context (`s3cmd.cfg`). `run.sh` not fetched; plan.md says the config is generated from env at start, unverified.

## Env vars (README, same names on Docker Hub)
| Name | Default | Purpose |
| --- | --- | --- |
| ACCESS_KEY | none | AWS access key |
| SECRET_KEY | none | AWS secret key |
| S3PATH | none | target bucket and path, e.g. `s3://yours3bucket/` |
| S3CMDPARAMS | empty | extra s3cmd parameters |
| CRON_SCHEDULE | `0 * * * *` | cron schedule (hourly by default); `0 3 * * *` = daily 03:00 |

No separate S3 endpoint variable; endpoint customization would go through S3CMDPARAMS (not stated upstream).

## Volumes/paths
- Back up folders are mounted beneath `/data` (example `/data/documents:ro`, `/data/photos`). `/data` created in the Dockerfile.

## Run example (README)
```
docker run -d -v /home/user/Documents:/data/documents:ro -v $/home/user/Photos:/data/photos -e "ACCESS_KEY=YOURACCESSKEY" -e "SECRET_KEY=YOURSECRET" -e "S3PATH=s3://yours3bucket/" -e "CRON_SCHEDULE=0 3 * * *" joch/s3backup
```
- The second mount has a stray `$` (`$/home/user/Photos`), a typo in the upstream example.

## Ports, user, healthcheck
- None. Runs as root (no USER). No healthcheck.

## Arch support
- Not stated.

## Gotchas
- Upstream is about 7 years old; debian:jessie and python 2 packages.
- Volumes mounted read-only in the example.
