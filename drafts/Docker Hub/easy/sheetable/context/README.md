# sheetable context

Fetched 2026-11-26.

## Sources

| Source URL | File |
| --- | --- |
| https://github.com/SheetAble/SheetAble (v0.8.1 Dockerfile, README, LICENSE, goreleaser config, config.go, pdfToImage.go, .env.sample; releases page) | github-sheetable-sheetable.md |
| https://github.com/SheetAble/SheetAble/releases | github-sheetable-sheetable.md |
| https://sheetable.net/docs | docs-sheetable-configuration.md |
| https://sheetable.net/docs/configuration | docs-sheetable-configuration.md |
| https://sheetable.net/docs/Installation/installation | docs-sheetable-configuration.md |
| https://sheetable.net/docs/Installation/installation-docker | docs-sheetable-configuration.md |
| https://hub.docker.com/r/vallezw/sheetable | dockerhub-vallezw-sheetable.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/sheetable (values.yaml) | truecharts-sheetable.md |

## Skipped

- https://cla-assistant.io/trueforge-org/containerforge: CLA page (skip rule).
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/schemas/container-settings.schema.json: forgetool schema (skip rule).
- https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json: forgetool schema (skip rule).
- https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu: containerforge base app link (skip rule).
- https://github.com/SheetAble/SheetAble/releases/download/v0.8.1/SheetAble_0.8.1_linux_amd64.tar.gz: direct archive download (skip rule). Naming pattern recorded in github-sheetable-sheetable.md.
- https://github.com/SheetAble/SheetAble/releases/download/v0.8.1/SheetAble_0.8.1_linux_arm64.tar.gz: direct archive download (skip rule). Same pattern.
- https://github.com/SheetAble/SheetAble/releases/download/v${VERSION}: template placeholder (skip rule).
- https://github.com/SheetAble/SheetAble/releases/download/v0.8.1 checksums (SheetAble_0.8.1_checksums.txt, in plan.md): release asset (skip rule). Naming recorded in github-sheetable-sheetable.md.
- https://raw.githubusercontent.com/SheetAble/SheetAble/v${VERSION}/LICENSE (plan.md template): covered by the v0.8.1 LICENSE fetch.
- https://github.com/SheetAble and https://github.com/SheetAble/SheetAble/ (org index and repo root with trailing slash): covered by the repo fetch.
- https://github.com/SheetAble/SheetAble/blob/v0.8.1/backend/Dockerfile: covered by the raw Dockerfile fetch.
- https://pdf2png.sheetable.net/createthumbnail: runtime upload endpoint, not a documentation page; behaviour taken from pdfToImage.go in the repo fetch.
- https://api.openopus.org: runtime metadata API, not a documentation page; not fetched (README mentions it only).
- https://github.com/SheetAble/server (Docker Hub text): linked from the Docker Hub page, not referenced by draft.md or plan.md; not fetched.
- https://pdf2png... and api.openopus.org appear in plan.md section 10 only.

## Fetch failures

- https://raw.githubusercontent.com/SheetAble/SheetAble/v0.8.1/backend/.goreleaser.yaml: 404; the `.yml` name worked.
- https://github.com/SheetAble/SheetAble/releases: page loaded, but asset file names did not load ("Assets 10" only). Asset names recorded from plan.md as unverified.

## plan.md corrections

- Section 9, first bullet: "`CONFIG_PATH` (default: working directory root)" -> "`CONFIG_PATH` (code default `./config/`, relative to the working directory; the docs only say the root dir is implied)". Source: github-sheetable-sheetable.md (backend/api/config/config.go, NewConfig).

Checked and left unchanged:
- Section 1 default login `admin@admin.com` / `sheetable` marked "(docs)": correct for installation-docker (docs-sheetable-configuration.md). The code default matches as well.
- Section 1 "Docs example: CONFIG_PATH=/app/config/, volume /app/config": correct for installation-docker.
- Section 10 pdf2png behaviour (InsecureSkipVerify, panic on error, no env toggle): confirmed by pdfToImage.go.

## Unverified (not changed)

- Section 1 "Archive content: one file, sheetable, no LICENSE file": not checked (tarball not fetched).
- Section 1 "Checksum source" file name and sha256 values: not fetched.
- Section 7 seeder behaviour (`api/seed/seeder.go`), `/health` route (`api/controllers/routes.go`), and the bind address `0.0.0.0`: not fetched.
- Section 10 Open Opus call `https://api.openopus.org` from composer lookups: not checked.
- Section 1 `DEV` being 0 or 1: the docs say 0 or 1; the config struct reads it as a bool.
- Dockerfile `EXPOSE 8000` vs plan's "8000" statement: confirmed (stale; docs say 8080).
