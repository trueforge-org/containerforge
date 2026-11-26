# s3sync context

Fetched 2026-11-26.

## Sources

| Source URL | File |
| --- | --- |
| https://github.com/what-name/docker-s3sync (README, Dockerfile @6c97122, run.sh @6c97122) | github-what-name-docker-s3sync.md |
| https://hub.docker.com/r/whatname/docker-s3sync | dockerhub-whatname-docker-s3sync.md |
| https://pypi.org/project/awscli/ | pypi-awscli.md |
| https://raw.githubusercontent.com/aws/aws-cli/1.46.3/setup.py (repo https://github.com/aws/aws-cli) | github-aws-aws-cli.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/s3sync | truecharts-s3sync.md |

## Skipped

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA page (skip rule) |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema URL (skip rule) |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema URL (skip rule) |
| https://github.com/trueforge-org/containerforge/tree/main/apps/python | containerforge apps/<base> link (skip rule) |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps/<base> link (skip rule) |
| ghcr.io/trueforge-org/python, ghcr.io/trueforge-org/python:3.15.2@sha256:..., ghcr.io/trueforge-org/ubuntu | ghcr image refs, not web pages |
| docker.io/whatname/docker-s3sync:latest | image ref, not a web page (covered by the Docker Hub page above) |
| http://minio:9000 | example endpoint in the plan's test commands, not a source |

## Fetch failures

None.

## plan.md corrections

None. The sources agree with the plan on the wrapper env names and defaults, cron/lock/log paths, `FROM debian:latest` wrapper, awscli 1.46.3 release date, Python >=3.10 and the Apache-2.0 license. Unverified notes kept in the plan: botocore/urllib3 pins on Python 3.15 (see pypi-awscli.md; the extracted dependency list did not show botocore, so verify against the wheel metadata).
