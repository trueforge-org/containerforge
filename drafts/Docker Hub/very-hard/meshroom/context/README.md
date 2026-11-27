# Context index: meshroom

Built 2026-11-27.

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/meshroom/values.yaml | truecharts-meshroom.md |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/meshroom/Chart.yaml | truecharts-meshroom.md |
| https://hub.docker.com/v2/repositories/alicevision/meshroom/ | dockerhub-meshroom.md |
| https://hub.docker.com/v2/repositories/alicevision/meshroom/tags?page_size=10 | dockerhub-meshroom.md |
| https://raw.githubusercontent.com/alicevision/Meshroom/v2025.1.0/docker/Dockerfile_ubuntu | github-alicevision-meshroom-dockerfile-ubuntu.md |
| https://github.com/alicevision/meshroom/blob/v2025.1.0/docker/Dockerfile_ubuntu | github-alicevision-meshroom-dockerfile-ubuntu.md (same file) |
| https://meshroom.readthedocs.io/en/stable | meshroom-readthedocs.md |
| https://zenodo.org/records/16887472 | zenodo-meshroom.md |
| https://github.com/alicevision/Meshroom, https://github.com/alicevision/meshroom | not fetched (covered by Dockerfile and Zenodo) |

Skipped categories: none beyond the duplicate blob/raw pair and repo root above.

Failures:
- https://api.github.com/repos/alicevision/Meshroom/releases/tags/v2025.1.0 (HTTP 403, rate limit; not retried).
- https://api.github.com/repos/alicevision/Meshroom (not attempted after the 403 above).

## plan.md corrections
None applied. Chart image digest, port 22/10243, Dockerfile facts and Zenodo tarball name all agree with fetched sources.

Unverified conflicts (not edited):
- plan.md line 8: release published 2025-08-19 (from GitHub API, 403 in this run). Zenodo record shows "Published August 18, 2025", created August 19, 2025.
- plan.md line 10: MPL-2.0 is confirmed by Zenodo (zenodo-meshroom.md). Repo LICENSE file still unverified.
- plan.md line 12: Zenodo lists the Linux tarball at 14.3 GB (confirmed) and an MD5 of eb8124515bfdd5368faf6929b28c85ba; no sha256 on the record.
