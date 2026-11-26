# posterr context index

Fetched 2026-11-26.

## Source URL -> file

| Source URL | File | Notes |
| --- | --- | --- |
| https://github.com/petersem/posterr | github-petersem-posterr.md | repo; README via raw master |
| https://raw.githubusercontent.com/petersem/posterr/master/README.md | github-petersem-posterr.md | fetched |
| https://raw.githubusercontent.com/petersem/posterr/4609d7e2ef2ce37bac78349b3978e61a706d0180/Dockerfile | github-petersem-posterr.md | fetched (blob/4609d7e... form in draft) |
| https://raw.githubusercontent.com/petersem/posterr/4609d7e2ef2ce37bac78349b3978e61a706d0180/package.json | github-petersem-posterr.md | fetched |
| https://github.com/petersem/posterr/tags | github-petersem-posterr.md | fetched |
| https://github.com/petersem/posterr/releases/tag/v1.15.0 | github-petersem-posterr.md | fetched; asset names not rendered |
| https://hub.docker.com/r/petersem/posterr | dockerhub-petersem-posterr.md | fetched |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/posterr | truecharts-posterr.md | tree page; values fetched via raw |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/posterr/values.yaml | truecharts-posterr.md | fetched |

## Skipped URLs

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA link |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json | forgetool schema |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge apps base link |
| https://github.com/petersem/posterr/archive/refs/tags/v${VERSION}.tar.gz | contains ${; direct archive download; pattern recorded in github-petersem-posterr.md |
| https://github.com/petersem/posterr/releases/download/v1.15.0/poster-binaries.zip | direct binary download; release naming recorded |
| http://hostIP:3000 | placeholder host, not a web source |

## Fetch failures

- https://raw.githubusercontent.com/petersem/posterr/main/README.md: 404 (branch is master, retried successfully).
- https://raw.githubusercontent.com/petersem/posterr/main/Dockerfile: 404 (pinned commit used instead).

## plan.md corrections

No factual corrections made to plan.md. Context did not clearly contradict any claim.

Unverified items (not edited):
- plan.md section 1 gives the full SHA for tag v1.21.18 as `18d2d31025c5b86daebf2e18d1662671c42e1c57`; the tags page shows v1.21.18 at short SHA `4609d7e`. Could not reconcile.
- plan.md says tags carry a `v` prefix. The tags page lists `1.21.8` without `v` (v1.21.9 has it).
- plan.md says `PORT` env var defaults to 3000 in index.js. Not confirmed; README lists only TZ and BASEPATH.
- plan.md says Node major is 24 for the base image. Upstream Dockerfile pins node:24.1.0-alpine (consistent), base Node version still unverified.
