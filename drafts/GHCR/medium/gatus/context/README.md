# Context: gatus

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/gatus/values.yaml | truecharts-gatus.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/gatus/Chart.yaml | truecharts-gatus.md |
| https://api.github.com/repos/TwiN/gatus/contents/Dockerfile?ref=d255d0cd4d69ce818574cfdb3a7e82407e6559d7 and https://github.com/TwiN/gatus/blob/d255d0cd4d69ce818574cfdb3a7e82407e6559d7/Dockerfile | github-twin-gatus-dockerfile.md (raw variant of the same file) |
| https://api.github.com/repos/TwiN/gatus/contents/go.mod | github-twin-gatus-dockerfile.md (raw go.mod) |
| https://github.com/TwiN/gatus | github-twin-gatus-dockerfile.md (raw README, master) |
| https://github.com/TwiN/gatus/releases/tag/v5.38.0 | github-twin-gatus-dockerfile.md (HTML title only) |

Skipped categories: templated/boilerplate (`home-operations/gatus-sidecar` repo, optional sidecar, not fetched), Docker Hub mirror `twinproduction/gatus` (no Docker Hub entry in urls.txt; image is GHCR), `gatus.io` (see failures).

Failures:
- https://api.github.com/repos/TwiN/gatus/releases/latest: 403. One alternative tried (HTML release tag page, 200). Asset list not read from it; plan already records zero assets.
- https://gatus.io/docs: 200 but JS-rendered shell (2.6 KB), no usable content. Not summarized.
- https://gatus.io and https://github.com/home-operations/gatus-sidecar: not fetched (budget).

## plan.md corrections
- None. Draft/plan values match the fetched sources (tag v5.38.0, commit d255d0cd Dockerfile, GATUS_CONFIG_PATH, GATUS_LOG_LEVEL, PORT=8080, ENTRYPOINT /gatus, scratch final stage).
