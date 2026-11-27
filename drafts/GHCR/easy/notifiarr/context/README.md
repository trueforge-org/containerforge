# Context: notifiarr

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/notifiarr/values.yaml | truecharts-notifiarr.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/notifiarr/Chart.yaml | truecharts-notifiarr.md |
| https://raw.githubusercontent.com/Notifiarr/notifiarr/85a85e8/init/docker/Dockerfile.alpine | upstream-notifiarr-dockerfile.md |
| https://raw.githubusercontent.com/Notifiarr/notifiarr/85a85e8/init/docker/Dockerfile.alpine (blob variant https://github.com/Notifiarr/notifiarr/blob/85a85e8/init/docker/Dockerfile.alpine) | upstream-notifiarr-dockerfile.md |
| https://github.com/Notifiarr/notifiarr/releases/latest (alternative for API call) | upstream-notifiarr-dockerfile.md |
| https://raw.githubusercontent.com/Notifiarr/notifiarr/main/README.md (alternative for wiki) | upstream-notifiarr-client.md |

Skipped (not fetched):
- https://github.com/Notifiarr/notifiarr (repo root; raw README used instead).
- https://notifiarr.com (marketing site; not needed for build facts).
- https://github.com/Notifiarr/notifiarr/blob/85a85e8/init/docker/Dockerfile.alpine (blob variant of the raw URL above).
- No Docker Hub URL in urls.txt (image is GHCR: ghcr.io/notifiarr/notifiarr).
- Pre-filtered by urls.txt: CLA, forgetool schemas, containerforge app links, templated, binary downloads, image refs.

Failures:
- https://api.github.com/repos/Notifiarr/notifiarr/releases/latest: 403. One alternative tried (github.com releases/latest HTML: tag/date ok, asset names not loaded). Not retried.
- https://api.github.com/repos/Notifiarr/notifiarr (repo API, listed in urls.txt): not fetched (no need once repo facts came from raw files).
- https://notifiarr.wiki: 403. One alternative tried (client README raw, no install/Docker facts). Not retried.

## plan.md corrections
- None (plan.md not edited). Unverified: client Docker port/config/env facts could not be confirmed from fetched sources.
