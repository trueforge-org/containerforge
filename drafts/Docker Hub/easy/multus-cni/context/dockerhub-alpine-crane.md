# Docker Hub: alpine/crane

**Source URL(s) + fetch date:** https://hub.docker.com/r/alpine/crane · fetched 2026-11-26

## What it is
Docker Hub listing for the `crane` CLI image, published under "alpine" (sponsored OSS). Used as `craneImage` in the multus-cni TrueCharts chart.

## Tags / arch
- Only `latest` shown in fetched page; chart pins `0.22.1@sha256:ab2ff377...`. Architectures not listed on page.
- Size ~7.3 MB; 100K+ pulls.

## Entrypoint/usage
- No ENTRYPOINT stated; examples pass subcommands directly (`docker run --rm alpine/crane ls ubuntu`), consistent with ENTRYPOINT crane.
- Multi-arch copy/tag examples. Login example mounts `$(pwd)/.docker:/root/.docker`.

## Env vars
None documented.

## Volumes
Example mounts `/root/.docker` for credentials.

## Gotchas
- Page content is partial (digest truncated); arch list not stated.
