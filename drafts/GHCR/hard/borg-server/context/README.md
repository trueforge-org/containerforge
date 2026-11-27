# Context index: borg-server

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/borg-server/values.yaml + Chart.yaml | truecharts-borg-server.md |
| https://raw.githubusercontent.com/AnotherStranger/docker-borg-backup/2737b502.../Dockerfile (+ entrypoint.sh) | github-borg-server-dockerfile.md |
| https://api.github.com/repos/borgbackup/borg/releases/latest (403) + releases/latest redirect; borgbackup.readthedocs.io | github-borg-release.md |

Skipped categories: api.github.com contents call for entrypoint.sh (replaced by raw file at the same commit), api.github.com releases list for AnotherStranger/docker-borg-backup (not needed, commit pinned), GitHub blob Dockerfile (same as raw), github repo root pages and releases list (`/releases` API), borgbackup.org homepage, borgbackup repo page, Docker Hub (image is GHCR, no Docker Hub URL listed).

Failures:
- https://api.github.com/repos/borgbackup/borg/releases/latest: 403 (rate limit). Alternative used: releases/latest redirect (ok).

## plan.md corrections
- None edited. Plan's version 1.4.5 and the Dockerfile details agree with what was fetched.
