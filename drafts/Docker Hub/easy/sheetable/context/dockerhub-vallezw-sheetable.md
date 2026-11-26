# vallezw/sheetable (Docker Hub)

Source URL(s) + fetch date:
- https://hub.docker.com/r/vallezw/sheetable (fetched 2026-11-26)

## What it is
Docker Hub image page for SheetAble (self-hosted music sheet organiser). Links to https://github.com/SheetAble/server (organisation https://github.com/SheetAble) and https://sheetable.net.

## Install/build steps
Only `docker pull vallezw/sheetable` is shown.

## Version/release info and asset naming
- Only tag listed: `latest` (digest begins sha256:87db05053…, size 18.3 MB). No version tags listed.
- Updated "over 3 years ago" (repo header) / "almost 4 years ago" (tag). No exact date.
- 100K+ pulls.

## Env vars, ports, volumes
Not listed on the page. Points to sheetable.net docs.

## Arch support
Not listed.

## Gotchas
- The page does not show the version of the code in `latest`. Compare with the GitHub v0.8.1 tag.
- The Docker Hub page links to `SheetAble/server`; the fetched Dockerfile and goreleaser config live in `SheetAble/SheetAble` (`backend/`).

## Contradictions with plan.md
- None found on this page. plan.md's `docker.io/vallezw/sheetable:v0.8.1` tag is not visible here (only `latest` is shown).
