# Context index: avidemux

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/avidemux/values.yaml + Chart.yaml | truecharts-avidemux.md |
| https://raw.githubusercontent.com/jlesage/docker-avidemux/v26.09.1/Dockerfile (+ blob variant) | github-avidemux-dockerfile.md |
| https://api.github.com/repos/jlesage/docker-avidemux/releases/latest (403) + releases/latest redirect | github-avidemux-release.md |

Skipped categories: GitHub blob Dockerfile (same as raw), github repo root and docker-baseimage-gui repo page (base image is Alpine; not needed for Ubuntu build), Docker Hub (image is GHCR, no Docker Hub URL listed).

Failures:
- https://api.github.com/repos/jlesage/docker-avidemux/releases/latest: 403 (rate limit). Alternative used: releases/latest redirect (ok).
- https://avidemux.org: fetched, page had no readable content (86 bytes of text). Not summarised.

## plan.md corrections
- No edit made. Unverified conflict: plan pins upstream tag `v26.09.1`; latest release is `v26.11.2`, and the TrueCharts chart uses `v26.11.2`. Plan's tag is still published, so this is a version choice for the maintainer.
