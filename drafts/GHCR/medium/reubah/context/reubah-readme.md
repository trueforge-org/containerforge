# Upstream README: dendianugerah/reubah (commit 04469cf)

Source URL: https://raw.githubusercontent.com/dendianugerah/reubah/04469cf95ea7105f9d60e4906eab5533fb70ccd1/README.md (fetched 2026-11-27)

## Docker usage (from README)
- `docker run -d --name reubah -p 8081:8081 -v doc-temp:/tmp -e PORT=8081 --restart unless-stopped ghcr.io/dendianugerah/reubah:latest`
- Access at http://localhost:8081
- docker-compose also shown (not inspected).

## Requirements
- Go 1.22+; LibreOffice (document conversion).
- Local dev: `go mod download`; `go run cmd/server/main.go`.

## Env vars
| Name | Value |
| --- | --- |
| PORT | 8081 (README example) |

No other env vars documented.

## Volumes
- `/tmp` mounted as a volume in the README example.

## License
- MIT (LICENSE file in repo).
