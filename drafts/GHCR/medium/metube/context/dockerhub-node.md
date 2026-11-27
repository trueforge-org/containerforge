# Docker Hub: library/node (builder base for metube)

Source URL(s) + date:
- https://hub.docker.com/v2/repositories/library/node/ (2026-11-27)
- https://hub.docker.com/v2/repositories/library/node/tags?page_size=10 (2026-11-27)

## Facts
- namespace library, name node, active image, not automated.
- last_updated 2026-11-24T20:41:41Z; pull_count 7,533,285,232; star_count 14215.
- Tags page (first 10 of the API list): latest, trixie, lts-trixie, lts-lithium, lts-bookworm, lts, lithium-trixie, lithium-bookworm, lithium, krypton-trixie.
- `latest` full_size 445058582 bytes.

## Gotchas
- The metube Dockerfile pins `node:22-alpine@sha256:c610fcdf...` (digest comment explains QEMU arm64 issue). That tag is not in the first 10 results, so it was not verified here.
