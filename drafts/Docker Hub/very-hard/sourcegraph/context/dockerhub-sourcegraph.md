# Docker Hub: sourcegraph/server

## Source URL(s) + date
- https://hub.docker.com/v2/repositories/sourcegraph/server/ (2026-11-27)
- https://hub.docker.com/v2/repositories/sourcegraph/server/tags?page_size=10 (2026-11-27)

## What it is
- Sourcegraph code search and navigation tool, self-hosted. Not automated.
- 45 stars, ~19.5M pulls, last_updated 2026-02-10.
- Repo description: "See https://docs.sourcegraph.com/#quickstart for documentation and install instructions." (no run instructions on page)

## Tags
- 13,371 tags in the registry (includes cosign `.att`/`.sig` artifacts).
- Versioned tags seen (newest first):
| Tag | Arch | Pushed | Digest |
| --- | --- | --- | --- |
| 6.12.5040 | amd64 | 2026-02-10 | sha256:57a5802dfb3f... |
| 6.12.3032 | amd64 | 2026-01-29 | sha256:d0f044a52612... |

- Chart pin `6.12.5040@sha256:57a5802dfb3f...` matches the 6.12.5040 tag digest.
- Only amd64 image for these tags.

## Gotchas
- Image is the published server image only. No Dockerfile or build source on Docker Hub.
- Tags carry cosign attestation artifacts; filter to version tags when listing.
