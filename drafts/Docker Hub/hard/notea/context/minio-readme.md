# MinIO README

Source URL(s): https://github.com/minio/minio · fetched 2026-11-26 (raw master README)

## What it is
- S3-API-compatible object storage, AGPL-3.0 (docs CC BY 4.0).
- Status: community edition no longer maintained; ships as source only; no new prebuilt binaries (older binaries on GitHub Releases / dl.min.io, unmaintained).

## Build from source
- Requires Go 1.24 or newer.
- `go install github.com/minio/minio@latest` (recommended) or `go build`; cross-compile with `GOOS`/`GOARCH`.
- No make target mentioned.

## Run
- `minio server PATH` where PATH is an empty local folder.
- API port 9000. Console port random by default; fix with `--console-address :9001`.
- Default root credentials `minioadmin:minioadmin` (env var names not stated in README).

## Gotchas
- Source-built binaries in production are at user's own risk (AGPLv3, no warranty).
