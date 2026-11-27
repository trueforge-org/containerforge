# Context: homer

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/homer/Chart.yaml + values.yaml | truecharts-homer.md |
| https://raw.githubusercontent.com/bastienwirtz/homer/b3f7fd87813ce4ea9c4ab91f9ffdca81c7e19db2/Dockerfile (also blob URL) | github-bastienwirtz-homer-dockerfile.md |
| https://raw.githubusercontent.com/bastienwirtz/homer/b3f7fd87813ce4ea9c4ab91f9ffdca81c7e19db2/README.md (also github.com/bastienwirtz/homer) | github-bastienwirtz-homer-readme.md |
| https://api.github.com/... homer-dashboard/homer/releases/latest, releases/tag/v26.11.4 | FAILED (see below) |

Skipped categories: none (no CLA, templated, binary or image-ref URLs in list; no Docker Hub REQUIRED line).

Failures:
- https://github.com/homer-dashboard/homer/releases/tag/v26.11.4: API 403 rate limit on releases/latest; HTML release page fetched as the one alternative, but it returned JS/embedded markup with no usable asset list. Release date and asset list (homer.zip, from README) unverified beyond the README.
- https://github.com/homer-dashboard/homer (repo root): not fetched separately; same project as bastienwirtz/homer README.

## plan.md corrections
None. Plan's Dockerfile facts (node:24-alpine3.23, alpine:3.23, UID/GID 1000, EXPOSE 8080, ENTRYPOINT entrypoint.sh) match fetched upstream Dockerfile.
