# Docs site: icloud-photos-downloader.github.io

Source URL(s) + fetch date: https://icloud-photos-downloader.github.io/icloud_photos_downloader/ · fetched 2026-11-26

## What it is
Online documentation for icloudpd 1.34.0: "A command-line tool to download your iCloud photos to local storage."

## Operation modes
- Copy (default): pulls down new photos.
- Sync: also removes local files whose originals were deleted in iCloud (`--auto-delete`).
- Move: downloads, then removes from iCloud (`--keep-icloud-recent-days`).

## Other listed features
- Live Photos saved as separate image and video files; RAW and RAW+JPEG supported; same-name de-duplication.
- Single download or continuous monitoring via `--watch-with-interval`; `--until-found` and `--recent` for incremental runs; `--set-exif-datetime`.

## Sub-pages linked (not fetched)
install.html, authentication.html, selecting.html, naming.html, mode.html, size.html, raw.html, metadata.html, webui.html, nas.html, reference.html. The page has no dedicated Docker or Configuration page.

## Gotchas
- The `authentication.html` sub-page was not fetched; the same content was read from the GitHub raw `docs/authentication.md` at tag v1.34.0 (see github-icloud-photos-downloader.md).
