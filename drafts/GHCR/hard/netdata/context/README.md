# Context: netdata

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/netdata/values.yaml + Chart.yaml | truecharts-netdata.md |
| https://raw.githubusercontent.com/netdata/netdata/v2.13.0/packaging/docker/Dockerfile | netdata-dockerfile-v2.13.0.md |
| https://github.com/netdata/netdata/releases/latest (alt for API 403) | netdata-release-latest.md |
| https://learn.netdata.cloud | netdata-learn-site.md |

Skipped: https://github.com/netdata/netdata (repo HTML, 450 KB, covered by raw Dockerfile); https://github.com/netdata (org page); https://github.com/netdata/netdata/blob/v2.13.0/packaging/docker/Dockerfile (duplicate of raw); https://www.netdata.cloud (marketing). No Docker Hub source (GHCR image).

Failures:
- https://api.github.com/repos/netdata/netdata/releases/latest: HTTP 403; alternative (github.com releases/latest) returned 200 but no readable tag.
- https://api.github.com/repos/netdata/netdata: HTTP 403 (not retried; repo metadata not needed).

## plan.md corrections
- None (no clear factual error proven from fetched sources).
