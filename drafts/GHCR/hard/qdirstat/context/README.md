# Context: qdirstat

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/qdirstat/values.yaml + Chart.yaml | truecharts-qdirstat.md |
| https://raw.githubusercontent.com/jlesage/docker-qdirstat/v26.09.1/Dockerfile (+ blob URL duplicate) | docker-qdirstat-dockerfile.md |
| https://github.com/jlesage/docker-qdirstat/blob/v26.09.1/Dockerfile (blob duplicate of the raw URL above) | docker-qdirstat-dockerfile.md |
| https://github.com/jlesage/docker-qdirstat (fetched as raw README at tag v26.09.1) | docker-qdirstat-readme.md |
| https://github.com/shundhammer/qdirstat (fetched as raw README on master) | qdirstat-upstream-readme.md |

Skipped: the github.com HTML pages (replaced by the raw files above); upstream source archive `https://github.com/shundhammer/qdirstat/archive/2.0.tar.gz` (not downloaded).
No Docker Hub URL in list (image is GHCR).

Failures: none.

## plan.md corrections
1. Line 8 (Chart image): `ghcr.io/jlesage/qdirstat:v26.09.1` -> `ghcr.io/jlesage/qdirstat:v26.11.3` (source: TrueCharts values.yaml tag `v26.11.3@sha256:117a58b7...`; chart appVersion 26.11.3).

Unverified conflicts (not edited):
- Plan line 10 says latest upstream software release is `2.0.1` (2026-11-22). Not re-checked (no GitHub release API call made).
- Plan line 16 says ports 5800/5900 are an unverified convention. The upstream README now confirms both ports (web 5800, VNC 5900). Left as is because it is not an error.
