# Context: openttd

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/openttd/values.yaml | truecharts-openttd.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/openttd/Chart.yaml | truecharts-openttd.md |
| https://raw.githubusercontent.com/ich777/docker-openttd-server/master/Dockerfile | upstream-openttd-dockerfile.md |
| https://github.com/OpenTTD/OpenTTD/releases/latest (alternative for release API) | upstream-openttd-dockerfile.md |

Skipped (not fetched):
- https://cdn.openttd.org/openttd-releases/15.3/openttd-15.3-linux-generic-amd64.tar.xz (binary download).
- https://github.com/OpenTTD/OpenTTD (repo root, redundant with releases page).
- https://github.com/ich777/docker-openttd-server/blob/master/Dockerfile (blob variant; raw used).
- https://www.openttd.org and https://www.openttd.org/downloads/openttd-releases/latest (project site; release facts taken from GitHub releases).
- https://wiki.openttd.org/en (see failures; alternative used).
- No Docker Hub URL in urls.txt (image is GHCR: ghcr.io/ich777/openttdserver).
- Pre-filtered by urls.txt: CLA, forgetool schemas, containerforge app links, templated, binary downloads, image refs.

Failures:
- https://api.github.com/repos/OpenTTD/OpenTTD/releases/latest: 403. One alternative used (github.com releases/latest HTML). Not retried.
- https://wiki.openttd.org/en: 404. One alternative used (https://wiki.openttd.org root, no server/config facts). Not retried. Server flags/config paths for OpenTTD therefore unverified.

## plan.md corrections
- None (plan.md not edited).
