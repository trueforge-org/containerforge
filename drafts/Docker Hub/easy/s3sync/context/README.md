# s3sync context

Fetched 2026-11-26.

## Sources

| Source URL | File |
| --- | --- |
| https://github.com/what-name/docker-s3sync (README, Dockerfile and run.sh at 6c97122; README on master) | github-what-name-docker-s3sync.md |
| https://hub.docker.com/r/whatname/docker-s3sync | dockerhub-whatname-docker-s3sync.md |
| https://pypi.org/project/awscli/ | pypi-awscli.md |
| https://github.com/aws/aws-cli (setup.py at tag 1.46.3) | github-aws-aws-cli.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/s3sync (values.yaml) | truecharts-s3sync.md |

## Skipped

- https://cla-assistant.io/trueforge-org/containerforge: CLA page (skip rule).
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json: forgetool schema URL (skip rule).
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json: forgetool schema URL (skip rule).
- https://github.com/trueforge-org/containerforge/tree/main/apps/python: containerforge base app link (skip rule).
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: containerforge base app link (skip rule).
- http://minio:9000 (in plan.md build example): example endpoint, not a source.
- http:// (bare, in plan.md text): malformed fragment, not a source.

## Fetch failures

None.

## plan.md corrections

None. The context matches plan.md on: wrapper env vars and paths, awscli 1.46.3 and Python 3.10+ requirement, Apache-2.0 license, `/data/example` read-only mount, and chart securityContext (runAsUser/runAsGroup 0, readOnlyRootFilesystem false).

Unverified (not changed in plan.md):
- Plan says the aws-cli default branch is `v2` and that the wrapper repo was last pushed 2022-10-07; not checked against the repository itself.
- Plan says `awscli` has no AWS CLI v2 PyPI package; not checked on PyPI.
