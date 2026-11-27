# Go downloads page (go.dev/dl)

Source URL(s) + date:
- https://go.dev/dl (2026-11-27, HTML, about 1.1 MB)

Facts:
- Latest stable Go on the page: `go1.27.4`.

Relevance to podgrab: the Dockerfile pins `GO_VERSION=1.15.2` (very old), and go.mod requires `go 1.25.0`. See github-podgrab-dockerfile.md gotchas.
