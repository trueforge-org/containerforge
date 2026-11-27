# Context index: fossil

| Source URL | File | Status |
| --- | --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/fossil/values.yaml | truecharts-fossil.md | fetched |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/fossil/Chart.yaml | truecharts-fossil.md | fetched |
| https://raw.githubusercontent.com/nicholaswilde/docker-fossil/ca99797/Dockerfile | upstream-dockerfile-fossil.md | fetched |
| https://github.com/nicholaswilde/docker-fossil/blob/ca99797/Dockerfile | upstream-dockerfile-fossil.md | same file as raw Dockerfile |
| https://raw.githubusercontent.com/nicholaswilde/docker-fossil/ca99797/root/... (cont-init.d/30-config, services.d/fossil/run) | upstream-dockerfile-fossil.md | fetched as follow-ups (found via GitHub contents API) |
| https://archive.ubuntu.com/ubuntu | ubuntu-archive.md | shared cache copy |
| https://fossil-scm.org | fossil-scm-downloads.md | HTTP 302, not followed |
| https://fossil-scm.org/home/uv/download.html | fossil-scm-downloads.md | fetched (lists fossil-src-2.23.tar.gz) |
| https://fossil-scm.org/home/doc/trunk/www/changes.wiki | fossil-scm-downloads.md | fetched, no version heading matched in grep |
| https://fossil-scm.org/home/doc/trunk/www/permutedindex.html | none | not fetched: docs index, no build input |
| https://packages.ubuntu.com/resolute/fossil | none | failed: connection error (HTTP 000), one alternative `packages.ubuntu.com/noble/fossil` also 000 |

Skipped categories: none beyond the urls.txt filter. Docker Hub: not applicable, image is GHCR (community image `ghcr.io/nicholaswilde/fossil`).

## Failures
- packages.ubuntu.com: HTTP 000 on resolute, plus one alternative (noble), not retried. Plan's `1:2.26-2` deb version is therefore not confirmed by this run.

## plan.md corrections
- None edited.
- Not verified this run, left for the plan: the apt candidate `1:2.26-2` (packages.ubuntu.com failed), and the latest upstream version (download page shows 2.23; plan line 8 mentions 2.29 pending, not checked in changes.wiki).
