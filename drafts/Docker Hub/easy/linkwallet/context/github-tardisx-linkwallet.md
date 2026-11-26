# tardisx/linkwallet (GitHub, ARCHIVED)

Source URL(s) + fetch date:
- https://github.com/tardisx/linkwallet (repo; archived; see README notice)
- https://raw.githubusercontent.com/tardisx/linkwallet/main/README.md
- https://raw.githubusercontent.com/tardisx/linkwallet/main/Dockerfile
- https://raw.githubusercontent.com/tardisx/linkwallet/59f70ae/Dockerfile (draft blob link)
- https://raw.githubusercontent.com/tardisx/linkwallet/main/LICENSE
- https://raw.githubusercontent.com/tardisx/linkwallet/main/.goreleaser.yaml
- https://raw.githubusercontent.com/tardisx/linkwallet/main/cmd/linkwallet/linkwallet.go (main package; goreleaser `main: ./cmd/linkwallet/`)
- https://raw.githubusercontent.com/tardisx/linkwallet/main/web/web.go
- https://github.com/tardisx/linkwallet/releases
- Release asset URLs (direct downloads, not fetched): `https://github.com/tardisx/linkwallet/releases/download/v<V>/linkwallet_Linux_x86_64.tar.gz`, `.../linkwallet_Linux_arm64.tar.gz`, `.../linkwallet_<V>_checksums.txt`
- Fetched 2026-11-26

## Status
- Marked "ARCHIVED - 2025-05-23" on GitHub. Read-only.
- README: project moved to https://code.ppl.town/justin/linkwallet (see code-ppl-town-justin-linkwallet.md). Stated reason: dissatisfaction with GitHub's AI direction.

## What it is
Self-hosted bookmark manager with full-text search of page content (Bleve index). Scrapes and indexes bookmarked pages locally and re-scrapes on a schedule. Tags optional. Bulk import/export (plain text). Single cross-platform binary with an embedded database (no separate DB). Go project.

## Install/build steps
- Docker: docker-compose sample (`docker-compose.yml-sample`): copy, rename, edit (usually the host path of the `/data` mount), `docker-compose up -d`. Sample's image name and entrypoint not shown in README.
- Binary: download from releases, run `./linkwallet -db-path /some/path/xxxx.db` (DB created if missing).
- Source: `go build cmd/linkwallet/linkwallet.go`.
- deb/rpm packages: not migrated to goreleaser yet (per README).

## Upstream Dockerfile (main and 59f70ae are identical as fetched)
```
FROM alpine:3.16
ENTRYPOINT ["/linkwallet"]
COPY linkwallet /
```
- No ARG, ENV, RUN, VOLUME, USER, EXPOSE, CMD. Container runs as root. Expects a prebuilt `linkwallet` binary in the build context.

## Runtime deps
None beyond the binary (static, `CGO_ENABLED=0` per goreleaser).

## Binaries/entrypoint/CLI flags
- Entry `/linkwallet`.
- Flags (`cmd/linkwallet/linkwallet.go`): only `-db-path` (`flag.StringVar(&dbPath, "db-path", "", "path to the database file")`). Empty value causes `log.Fatal("You need to specify the path to the database file with -db-path")`.
- Startup log: `linkwallet version %s starting`.
- Background: queue runner, content updater, 5-minute stats goroutine (`UpdateBookmarkStats`, panics on error), version check every 6 hours (`UpdateVersionInfo`). The version check's GitHub URL is in the `version` package (not fetched).
- If the index was just created (`rescrape` true), all bookmarks are queued for re-scraping.
- Server: `server := web.Create(bmm, cmm)`, `server.Start()`, which calls `s.engine.Run()` with no args. Gin uses the `PORT` env var (default `:8080`) and binds all interfaces. Gin mode is set by `GIN_MODE` (default debug unless set).

## Env vars
| Name | Meaning | Source |
| --- | --- | --- |
| `PORT` | listen port (default 8080) | README (documented); gin reads it (indirect) |
| `GIN_MODE` | gin mode (`release` suppresses debug output) | gin behaviour, not documented by linkwallet |
No other env vars documented or read in the fetched files.

## Ports
8080/tcp (binary default). With the upstream sample docker-compose.yml the host port is 8109.

## Volumes/paths and persistent data
- `-db-path` file (bolt/bolthold DB) plus Bleve index at `<path>.bleve` (per plan; the `db` package was not fetched, UNVERIFIED).
- Upstream compose sample mounts `/data`.

## Routes (`web/web.go`)
`GET /`, `/manage`, `/config`, `/bulk_add`, `/single_add`, `/export`, `/bookmarklet`, `/edit/:id`, `/info`, `/graph/:type`; `POST /manage/results`, `/config`, `/search`, `/add`, `/add_bulk`, `/tags`, `/scrape/:id`, `/edit/:id`; `DELETE /edit/:id`. Static at `/assets`.

## User/UID & permissions
Upstream runs as root (no USER).

## Config files and formats
- Settings are stored in the database via the web config page (`/config`), including `BaseURL`.

## Auth
None: `web/web.go` has no login route and no auth middleware. Middleware is only cache headers for `/assets/`, gzip, and gin's default logger/recovery. State-changing routes (add, delete, config save) are open to any caller who reaches the server.

## BaseURL / bookmarklet (README)
Behind a reverse proxy or on another machine, set `BaseURL` on the config page or the bookmarklets do not work.

## Healthcheck/readiness endpoints
None documented. `/` serves the search page.

## Version/release info and asset naming
- Latest tag `v0.1.1` (commit `b50a2ae`), per Forgejo mirror. GitHub releases page shows it as latest with 12 assets (names not listed by fetch).
- Asset naming (from `.goreleaser.yaml` name_template, `{{ .ProjectName }}_{{ title .Os }}_{x86_64|i386|arm64|...}`): `linkwallet_Linux_x86_64.tar.gz`, `linkwallet_Linux_arm64.tar.gz`. Windows archives are zip. Checksums file default name `linkwallet_<V>_checksums.txt` (no checksum section in goreleaser config, so default applies).
- Archive formats: `tar.gz` for Linux/darwin/freebsd, zip for windows. Build targets: linux, windows, darwin, freebsd; goarch arm (6,7), arm64, amd64.

## Arch support
Binaries for linux amd64 and arm64 (and arm v6/v7). Forgejo lists linux arm64, armv6, armv7, x86_64.

## License
MIT License. LICENSE: "Copyright (c) 2022 Justin Hawkins".

## Gotchas
- Archived upstream. Renovate on GitHub will never see a newer release.
- goreleaser also has docker stanzas (`tardisx/linkwallet:{{ .Tag }}-amd64` etc.) which show the Docker Hub image is published upstream. Not used by the plan.
- version check runs every 6 hours (linkwallet.go). Needs outbound network.

## Contradictions with plan.md
- Plan section 1 says "the README says the project moved". Confirmed.
- Plan section 1 says "`GIN_MODE=release` is read by gin". Consistent with gin behaviour (not linkwallet doc).
- Plan section 1 says the Dockerfile is `FROM alpine:3.16`, `ENTRYPOINT ["/linkwallet"]`, `COPY linkwallet /`. Confirmed.
- Plan section 1 says "UNVERIFIED whether any login exists". web/web.go has no auth. Resolved (no auth in the fetched code).
- Plan section 10 says version check every 6 hours calls GitHub. Interval confirmed in linkwallet.go; the GitHub URL is in the `version` package (not fetched). Partly unverified.
- Plan section 1 says the amd64 binary is statically linked (checked with `file`). Not checked here; goreleaser CGO_ENABLED=0 is consistent.
- Plan section 1 says each tarball holds `linkwallet`, `LICENSE`, `README.md`. Not verified (goreleaser defaults suggest LICENSE and README are included; not confirmed).
