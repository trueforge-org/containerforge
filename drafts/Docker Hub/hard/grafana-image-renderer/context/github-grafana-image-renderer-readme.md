# grafana-image-renderer README

Source URL: https://raw.githubusercontent.com/grafana/grafana-image-renderer/master/README.md
Date fetched: 2026-11-26

## What it is
- Go backend service for Grafana. Renders panels/dashboards with headless Chromium.
- Output: PDF and PNG. Grafana Enterprise adds CSV and email via Grafana Reports.

## Build (per README)
- `docker build .`
- Go: `go build -buildvcs -o grafana-image-renderer .`
- Chromium from Debian packages. Debian codename trixie (13). `CHROMIUM_VERSION` ARG reruns update/upgrade step.
- Cachebuster date in Dockerfile forces manual package refresh.

## Tests and tooling
- Acceptance: `IMAGE=<tag> go test ./tests/acceptance/... -count=1`
- Formatter `go tool goimports`, linter `golangci-lint run`.

## Release
- Git tag must be `vX.Y.Z` (with `v` prefix). GitHub Actions builds and deploys.

## Not in README
- License, env var table, docker run flags, ports, config file paths, server/healthcheck subcommand details. Docs page pointer (`/docs/sources/_index.md`) is a placeholder.

## Gotchas
- Release tags use a `v` prefix (`vX.Y.Z`).
