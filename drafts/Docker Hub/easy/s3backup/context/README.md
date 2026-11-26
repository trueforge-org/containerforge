# s3backup context index

Fetched 2026-11-26.

## Source URL -> file

| Source URL | File | Notes |
| --- | --- | --- |
| https://github.com/joch/docker-s3backup/blob/87e6354/Dockerfile | github-joch-docker-s3backup.md | fetched via raw at commit 87e6354 |
| https://github.com/joch/docker-s3backup | github-joch-docker-s3backup.md | README via raw master |
| https://github.com/s3tools/s3cmd | github-s3tools-s3cmd.md | README via raw master |
| https://pypi.org/project/s3cmd/2.4.0/#files | docs-pypi-s3cmd.md | fetched (anchor stripped; file list on the page) |
| https://hub.docker.com/r/joch/s3backup | dockerhub-joch-s3backup.md | fetched |
| https://registry.hub.docker.com/r/joch/s3backup | dockerhub-joch-s3backup.md | same image as hub.docker.com page; not fetched separately |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/s3backup | truecharts-s3backup.md | tree page; values via raw |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/s3backup/values.yaml | truecharts-s3backup.md | fetched |
| https://s3tools.org/s3cmd | (no file) | fetch failed, see below; README content taken from github s3tools/s3cmd |
| https://s3tools.org/usage | (no file) | fetch failed, see below |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema |
| https://github.com/trueforge-org/containerforge/tree/main/apps/python | containerforge apps base link |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps base link |
| https://raw.githubusercontent.com/s3tools/s3cmd/v${VERSION}/LICENSE | contains ${ |

## Fetch failures

- https://s3tools.org/s3cmd: DNS failure (getaddrinfo ENOTFOUND s3tools.org). Alternative tried: the GitHub repo README (fetched, see github-s3tools-s3cmd.md). Not retried.
- https://s3tools.org/usage: DNS failure (getaddrinfo ENOTFOUND s3tools.org). No alternative fetched. The command and flag facts in github-s3tools-s3cmd.md come from the GitHub README only.

## plan.md corrections

No edits made. Context supports plan.md on: s3cmd 2.4.0 uploaded 2023-12-12, GPLv2+ license, wrapper env names and default `0 * * * *`, wrapper Dockerfile base `debian:jessie`, entrypoint `/run.sh` with CMD `start`, `/root/.s3cfg`, `/data` folder, last updated about 2019.

Unverified items (not edited):
- plan.md section 1 says runtime deps are python-dateutil and python-magic. Not on the PyPI page fetched; not checked.
- plan.md section 1 says the wrapper repo is GPL-3.0. Not checked (LICENSE not fetched).
- plan.md section 1 says the wrapper config is generated from env at each start and that the exact s3cmd invocation is UNVERIFIED. `run.sh` not fetched.
- plan.md section 1 gives pip hashes as an option (UNVERIFIED). The sha256 values are on the PyPI page (docs-pypi-s3cmd.md) and match the plan's intent; the plan keeps the hashes unverified.
- plan.md Dockerfile section (step 3) says python-magic needs system libmagic and that s3cmd falls back to `mimetypes` without it. Not covered by any fetched source.
