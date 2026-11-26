# Docker Hub: shaneisrael/fireshare

Source URL(s) + fetch date:
- https://hub.docker.com/r/shaneisrael/fireshare (fetched 2026-11-26)
- Also referenced by the draft as `https://hub.docker.com/r/shaneisrael/fireshare` (same page)

## What it is

Publisher shaneisrael. "Simple self-hosted video sharing". Overview page empty. 1M+ pulls, rating 5. Pull command `docker pull shaneisrael/fireshare`.

## Tags and arch

- Only `latest` shown (updated about 22 hours before fetch). Digest `sha256:73b4bea64...`. Size 1.7 GB.
- No version-numbered tags shown on the page. Architectures not listed (tags tab not fetched).
- Chart pins `1.9.6@sha256:73b4bea645262d40f6b3a07c25afe29c4f2692c1be995b30dac320b7d83b32f2`.
- Hub docs example uses `shaneisrael/fireshare:latest` (standard CUDA) and `shaneisrael/fireshare:latest-lite` (CPU only). Lite is the one ContainerForge ports.

## Ports, volumes, env

- Not on the Hub page. Compose example from the upstream docs (fetched via the Fireshare site) is in `github-fireshare-app-fireshare.md`.

## Gotchas

- The Docker Hub image is the CUDA variant unless the `-lite` tag is used.
