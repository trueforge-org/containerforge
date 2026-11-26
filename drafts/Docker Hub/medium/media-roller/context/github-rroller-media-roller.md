# GitHub: rroller/media-roller (README facts)

Source URL(s): https://github.com/rroller/media-roller (fetched 2026-11-26)

## What it is
- Self-hosted, mobile-friendly web tool, Go backend. Takes a URL (YouTube, Reddit, Twitter, etc.), downloads video with yt-dlp, transcodes to one mp4, returns a direct link.
- No authentication. README says it is for a home network and "should not be exposed to public traffic".
- Built on yt-dlp, which self-updates to nightly every 12 hours.

## Env vars
| Var | Default | Purpose |
| --- | --- | --- |
| MR_DOWNLOAD_DIR | /download | save location |
| MR_PROXY | empty | passed to yt-dlp --proxy |
| MR_MEDIA_LIST_ENABLED | true | show Downloads library on home page (false hides) |
| MR_COOKIES_DIR | cookies (/app/cookies in Docker) | dir holding cookies.txt |

## Ports
- 3000

## Volumes/paths
- /download (saved files)
- /app/cookies (dir containing optional Netscape cookies.txt)

## Config files
- Optional cookies.txt; if present passed to yt-dlp --cookies for web and API downloads. Must be writable (yt-dlp updates the jar). Keep outside download and static folders.

## Endpoints
- `/api/download?url=...`; `/api/download?preset=ios&url=...` (H.264/AAC mp4)
- `/fetch?url=...` for PC bookmarklet

## Install/run
- Docker: `docker run -p 3000:3000 -v "$(pwd)/download:/download" -v "/abs/path/cookies:/app/cookies" ronnieroller/media-roller`
- Images also on ghcr.io/rroller/media-roller:master

## Gotchas
- Daily GitHub Actions bot PR updates Go, yt-dlp, Go modules and Alpine images. Python and FFmpeg upgrades are manual.
