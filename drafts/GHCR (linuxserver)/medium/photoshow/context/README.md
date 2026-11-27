# Context sources: photoshow

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/photoshow/values.yaml | truecharts-photoshow.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/photoshow/Chart.yaml | truecharts-photoshow.md |
| https://hub.docker.com/v2/repositories/linuxserver/photoshow/ | dockerhub-photoshow.md |
| https://raw.githubusercontent.com/linuxserver/docker-photoshow/0cacdcb6c785/Dockerfile | linuxserver-dockerfile.md |
| https://api.github.com/repos/linuxserver/docker-photoshow/contents/root/etc/cont-init.d/40-install | linuxserver-install-script.md |
| https://api.github.com/repos/linuxserver/docker-photoshow | linuxserver-repo-meta.md |
| https://api.github.com/repos/thibaud-rohmer/PhotoShow/commits/master | upstream-master-commit.md |
| https://api.github.com/repos/thibaud-rohmer/PhotoShow/contents/docker/Dockerfile | upstream-docker-dockerfile.md |
| https://api.github.com/repos/thibaud-rohmer/PhotoShow/releases/latest | upstream-release.md |

Skipped categories:
- Duplicates: github.com blob/repo-root URLs (linuxserver/docker-photoshow, thibaud-rohmer/PhotoShow, blob Dockerfile), releases/tag/v2 (covered by API).
- Binary: source archive (`archive/${VERSION}.tar.gz`, not fetched).
- Templated/other: none in list.

Failures (2):
- https://api.github.com/repos/thibaud-rohmer/PhotoShow/contents/LICENSE: HTTP 404.
- https://raw.githubusercontent.com/thibaud-rohmer/PhotoShow/master/LICENSE (alternative): HTTP 404. Upstream license remains unconfirmed.

## plan.md corrections
- None. Verified against fetched sources: base `baseimage-alpine-nginx:3.13`, TrueCharts tag `version-48aabb98`, port 80/10025, volumes `/config /Thumbs /Pictures`, archived linuxserver repo, stale v2 release. License status is still open (both LICENSE fetches 404), which matches the plan.
