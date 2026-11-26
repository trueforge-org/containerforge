# moby/moby (repository, LICENSE)

Source URL(s) + fetch date:
- https://github.com/moby/moby (repo page)
- https://raw.githubusercontent.com/moby/moby/master/LICENSE
- Fetched 2026-11-26

## What it is
- Moby project: "a collaborative project for the container ecosystem to assemble container-based systems". Source of Docker Engine (dockerd), used as the base for docker-library dind. Default branch `master`.
- Dockerfile at repo root (also `Dockerfile.simple`, `Dockerfile.windows`). Docs in `docs/` plus man pages and README.md, CONTRIBUTING.md, TESTING.md.

## License
- Apache License, Version 2.0 (January 2004). Copyright 2013-2018 Docker, Inc. (LICENSE). Repo page also reports Apache-2.0.

## Version/release info and asset naming
- Repo release list was empty in the fetched page. README cites the tag format `docker-v29.0.0` as an example for Docker Engine 29.0.0 (per the summariser; not confirmed against the tag list).
- Engine static tarballs are published on download.docker.com, not as GitHub release assets (see download-docker-com-static-index.md).

## Gotchas
- Plan's assumption that moby tags are `v29.10.0` is not confirmed. README example uses `docker-v29.0.0`.
