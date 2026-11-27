# Docker Hub: library/ubuntu (base reference only)

Source URL(s) + date:
- https://hub.docker.com/v2/repositories/library/ubuntu/ (fetched 2026-11-27)
- https://hub.docker.com/v2/repositories/library/ubuntu/tags?page_size=10 (fetched 2026-11-27)

## What it is
- Official Ubuntu base image, maintained by Canonical. Status active. Not the RStudio image itself.
- Last updated 2026-11-23.

## Tags (latest page, 10 of 768)
| tag | last_updated |
| --- | --- |
| 26.10 | 2026-11-23 |
| 24.04 | 2026-11-23 |
| 22.04 | 2026-11-23 |
| rolling | 2026-11-23 |
| stonking, stonking-20261117.1 | 2026-11-23 |
| noble, noble-20261110.1 | 2026-11-23 |
| jammy, jammy-20261114.1 | 2026-11-23 |

## Gotchas
- Rocker Dockerfile (rstudio_4.6.2) uses `FROM docker.io/library/ubuntu:resolute` (26.04 codename).
- Multi-arch: amd64, arm64, arm/v7, ppc64le, s390x, riscv64.
