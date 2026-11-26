# SheetAble/SheetAble (upstream repo, v0.8.1)

Source URL(s) + fetch date (all 2026-11-26):
- https://raw.githubusercontent.com/SheetAble/SheetAble/v0.8.1/backend/Dockerfile
- https://raw.githubusercontent.com/SheetAble/SheetAble/v0.8.1/README.md
- https://raw.githubusercontent.com/SheetAble/SheetAble/v0.8.1/LICENSE
- https://raw.githubusercontent.com/SheetAble/SheetAble/v0.8.1/backend/.goreleaser.yml (`.yaml` returned 404)
- https://raw.githubusercontent.com/SheetAble/SheetAble/v0.8.1/backend/api/config/config.go
- https://raw.githubusercontent.com/SheetAble/SheetAble/v0.8.1/backend/api/utils/pdfToImage.go
- https://raw.githubusercontent.com/SheetAble/SheetAble/v0.8.1/backend/.env.sample
- https://github.com/SheetAble/SheetAble/releases

## What it is
Self-hosted music sheet organiser. Go backend (`backend/`, CGO sqlite) with an embedded React frontend (per README and plan). Accounts can be created for others. Metadata partly from the Open Opus API (README). Maintainer listed as vallezw. License AGPL-3.0 (LICENSE is the GNU AGPL v3 text, "Version 3, 19 November 2007"; README says "AGPL").

## Install/build steps
Upstream `backend/Dockerfile` (v0.8.1):
- Stage 1: `FROM golang:alpine as builder`; `apk add build-base git`; `ADD . /app`; `WORKDIR /app`; `COPY go.mod go.sum ./`; `go mod download`; `COPY . .`; `RUN CGO_ENABLED=1 GOOS=linux go build -a -installsuffix cgo -o main .`
- Stage 2: `FROM alpine:latest`; `apk add --no-cache ca-certificates curl`; `mkdir /app`; `WORKDIR /app/`; `COPY --from=builder /app/main .`
- `EXPOSE 8000`; `CMD ["./main"]`. No ENV, no USER, no VOLUME.
- Musl/alpine build (not glibc).

Release build (`backend/.goreleaser.yml`, verbatim-ish): five builds, all `binary: sheetable`, `CGO_ENABLED=1`:
- linux amd64 (no extra compiler env)
- linux arm64 with `CC=aarch64-linux-gnu-gcc`, `CXX=aarch64-linux-gnu-g++`
- linux arm with goarm 6 and 7, `CC=arm-linux-gnueabi-gcc`
- darwin (ldflags `-s`, osxcross clang; ignores darwin/386)
- windows amd64 (`-buildmode=exe`, mingw)
- `changelog: skip: true`. No `main:` path set, no `archives:` or `checksum:` section in the fetched file. Archive names therefore follow goreleaser defaults; the observed names match the plan pattern (see below).
- Cross-compilers for arm64 and arm imply a glibc (gnu) build for linux.

## Runtime deps
glibc-linked binary when built by goreleaser (plan.md says dynamically linked glibc; the goreleaser config supports that). Upstream Docker runtime needs `ca-certificates curl` (alpine). Runtime fetches over HTTPS to `pdf2png.sheetable.net` and `api.openopus.org` (see below).

## Binaries/entrypoint/CLI flags
Single binary `sheetable` (`./main` in the upstream image). No CLI flags observed in the fetched files.

## Env vars (table; from config.go NewConfig() and .env.sample)
| Variable | Code default (NewConfig) | Notes |
| --- | --- | --- |
| `ADMIN_EMAIL` | `admin@admin.com` | seeded admin email |
| `ADMIN_PASSWORD` | `sheetable` | seeded admin password |
| `API_SECRET` | `sheetable` | JWT secret; the public default is used if unset |
| `SERVER_URL` | `http://localhost:8080` | |
| `CONFIG_PATH` | `./config/` | relative to working dir |
| `DB_DRIVER` | `sqlite` | `mysql`, `postgres` or `sqlite` (.env.sample) |
| `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME` | none | |
| `DB_PORT` | none (zero) | .env.sample comments: postgres 5432, mysql 3306 |
| `PORT` | none (zero) | docs say default 8080; .env.sample comment shows 7373 as an example |
| `DEV` | none (false) | bool; 1 enables dev mode |
| `SMTP_ENABLED` | `"0"` | |
| `SMTP_FROM`, `SMTP_SERVER_ADDR`, `SMTP_HOST_SERVER_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD` | none | `.env.sample` examples: `noreply@email.com`, `smtp.mail.com`, `587` |

The app reads `.env` from the working directory (`dotenvFile` default `.env`), then the process environment overrides it.

## Ports
Dockerfile `EXPOSE 8000` (stale vs docs). Effective port is `PORT`; docs and TrueCharts use 8080 or another port. Plan.md sets PORT explicitly.

## Volumes/paths and persistent data
- `CONFIG_PATH` holds uploaded sheets, thumbnails and `database.db` (sqlite).
- Thumbnails are written to `<CONFIG_PATH>/sheets/thumbnails/<name>.png` (`utils/pdfToImage.go`).

## User/UID & permissions
No USER in upstream Dockerfile (runs as root in the upstream image).

## Config files and formats
`.env` file (dotenv) in working dir. Sample at `backend/.env.sample`, groups: databases, user data, general, development, SMTP. Config is also overridable via env.

## Healthcheck/readiness endpoints
Not fetched from source (plan.md cites `/health` in `api/controllers/routes.go`; not checked here).

## Version/release info and asset naming
- Releases page: v0.8.1 (Latest, 14 Jan; ESLint cleanup, non-Latin name bug fix, CI Ubuntu lowered, Go bumped to 1.19); v0.8 (09 Jul; Linux ARM binaries added, user management, Docker metadata build); v0.7 (23 Jun; email and forgot-password); v0.6.5 (15 Jun); v0.6.4 (01 Feb); v0.6.3 (23 Dec); v0.6.2 (06 Nov); v0.6.1 Patch I (03 Nov); v0.6 (31 Oct; Docker containers for x86 and ARM, automated Go binary release); v0.5 (29 Sep). The page does not state years.
- Release page shows "Assets 10" for v0.8.1, but file names did not load in the fetch.
- Asset naming (from plan.md, consistent with goreleaser defaults; not listed on the fetched page): `SheetAble_<VERSION>_linux_<amd64|arm64>.tar.gz` and `SheetAble_<VERSION>_checksums.txt`. Tag is `v<VERSION>`.
- Skipped as a direct download (rule): `/releases/download/v0.8.1/SheetAble_0.8.1_linux_amd64.tar.gz`, `..._linux_arm64.tar.gz`, `SheetAble_0.8.1_checksums.txt`.

## Arch support
linux amd64 and arm64 (goreleaser builds, README/Docker Hub do not list arch). Linux arm (v6/v7) also built by goreleaser.

## Other external network calls (from source)
- `https://pdf2png.sheetable.net/createthumbnail`: hardcoded in `RequestToPdfToImage` (`backend/api/utils/pdfToImage.go`). Every uploaded PDF is POSTed as multipart form field `file` together with `name`. The client sets `InsecureSkipVerify: true` (TLS verification off). The response body is saved as `<CONFIG_PATH>/sheets/thumbnails/<name>.png`. Status is checked, but the later `os.Create` error overwrites the status error. Any upload error calls `panic(err)`. No env var disables this call.
- Open Opus API (`api.openopus.org`): README says metadata comes partly from Open Opus; the call site was not read in this pass.

## Gotchas
- Dockerfile `EXPOSE 8000` disagrees with docs port 8080 and the default `PORT` in docs.
- `PORT` and `DB_PORT` have no code default (Go zero value); set them explicitly.
- Default `API_SECRET` is `sheetable` when unset (public value).
- Default admin account `admin@admin.com` / `sheetable` (code and installation docs).
- Stale: last release 2023-01-14.

## Contradictions with plan.md
- plan.md section 9: "CONFIG_PATH (default: working directory root)". Code default is `./config/` (see correction below).
- plan.md section 1 "PORT (docs say default 8080)": docs say 8080; code sets no default. Consistent with plan (plan sets PORT explicitly).
- plan.md section 10: pdf2png call, `InsecureSkipVerify`, panic on error: confirmed by source.
- plan.md says the goreleaser config is `backend/.goreleaser.yml`: confirmed (the `.yaml` name is 404).
