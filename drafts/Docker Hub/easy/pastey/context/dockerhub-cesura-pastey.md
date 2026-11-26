# cesura/pastey (Docker Hub)

**Source URL(s) + fetch date**
- https://hub.docker.com/r/cesura/pastey (fetched 2026-11-26)

**What it is**
- "A lightweight, self-hosted paste platform." Publisher cesura.

**Version/release info and asset naming**
- Only tag shown on the page: `latest` (digest begins `sha256:4c4f6e7a3...`, size 1.5 GB). Page says last updated about 4 years ago.
- The chart pins `0.5.1@sha256:4c4f6e7a31f574a2034e0807bf874e03e350c8931d4477521fae2b3f3e2aecfe`, whose digest matches the `latest` digest shown here; `latest` therefore appears to equal `0.5.1` (full image).
- Chart `slimImage` pins `0.5.1-slim@sha256:dc994c07aa45ce94e7f67958c4d03a6dac95f56427e7113500f0e88a258d3b13`. README names `latest-slim` as the slim tag.

**Install/run**
- `docker pull cesura/pastey`. README run example: `docker run -d -p 5000:5000 -v /path/to/local/dir:/app/data cesura/pastey:latest`. Slim: `latest-slim`.
- Port, volumes and env are not stated on the Docker Hub page itself (README covers them).

**Arch support**
- Not stated on the page.
