# Docker Hub: library/registry

Source URL(s) + fetch date:
- https://hub.docker.com/_/registry · 2026-11-26
- https://registry.hub.docker.com/_/registry (listed in the draft; same official image page, not separately fetched) · 2026-11-26

## Facts
- Docker Official Image, 1B+ pulls, 4.2K stars. Maintained by the Docker Community.
- Tags: `3.1.2`, `3.1`, `3`, `latest` (single Dockerfile on GitHub). Digest for latest begins `sha256:82f6ff4a7…`. 19.5 MB.
- Architectures: amd64, arm32v6, arm32v7, arm64v8, ppc64le, riscv64, s390x.
- User, env, volumes, entrypoint and CMD: not stated on the page.
- Usage: `docker run -d -p 5000:5000 --restart always --name registry registry:3`.
