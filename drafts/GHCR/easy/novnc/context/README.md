# Context: novnc

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/novnc/values.yaml | truecharts-novnc.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/novnc/Chart.yaml | truecharts-novnc.md |
| https://raw.githubusercontent.com/nicholaswilde/docker-novnc/caa724f/Dockerfile | upstream-novnc-dockerfile.md |
| https://github.com/novnc/noVNC/releases/latest (alternative for release API) | upstream-novnc-dockerfile.md |
| https://pypi.org/pypi/websockify/json | upstream-novnc-dockerfile.md |
| https://raw.githubusercontent.com/novnc/noVNC/v1.7.0/LICENSE.txt | upstream-novnc-dockerfile.md (MPL 2.0) |

Skipped (not fetched):
- https://api.github.com/repos/novnc/noVNC/git/ref/tags/v1.7.0 and .../tarball/v1.7.0 (tag ref and source tarball; tarball is a binary download).
- https://github.com/nicholaswilde/docker-novnc/blob/caa724f/Dockerfile (blob variant of the raw Dockerfile).
- https://github.com/novnc/noVNC, https://github.com/novnc/noVNC/releases/tag/v1.7.0, https://github.com/novnc/noVNC/wiki, https://novnc.com (redundant or not needed for build facts).
- No Docker Hub URL in urls.txt (image is GHCR: ghcr.io/nicholaswilde/novnc).
- Pre-filtered by urls.txt: CLA, forgetool schemas, containerforge app links, templated, binary downloads, image refs.

Failures:
- https://api.github.com/repos/novnc/noVNC/releases/latest: 403. One alternative tried (github.com releases/latest HTML: tag v1.7.0 ok, asset names not loaded). Not retried.

## plan.md corrections
- None (plan.md not edited).
