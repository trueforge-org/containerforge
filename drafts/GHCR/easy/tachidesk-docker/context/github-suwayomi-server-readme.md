# Upstream README: Suwayomi/Suwayomi-Server

Source URL(s) + date: https://raw.githubusercontent.com/Suwayomi/Suwayomi-Server/master/README.md (fetched 2026-11-27)

## What it is
- Free, open-source manga reader server running Mihon (Tachiyomi) extensions. Not a fork of Mihon. Java-based; runs anywhere Java runs.
- Ships bundled with Suwayomi-WebUI when downloading the release; Suwayomi-VUI also integrated.
- Features: extensions, library, auto library updates, auto chapter download, offline downloads, backup/restore (Mihon-compatible), tracking, FlareSolverr support, OPDS and OPDS-PSE at `/api/opds/v1.2`.

## Install / run
- Release bundles: `linux-x64`, `win64`, `macOS-x64`, `macOS-arm64` (launcher scripts). Jar release can be run directly.
- Docker: official image `Suwayomi/tachidesk` package; source at suwayomi/docker-tachidesk. Default URL http://localhost:4567.
- Preview builds: Suwayomi-Server-preview repo (index.json `.latest`).

## Runtime deps
- Java (bundled in OS bundles; the Docker image uses eclipse-temurin JRE).
- Optional WebView: JCEF with X11 libs (libxrender, libxcomposite, libxdamage, libxkbcommon, libxtst) on GNU/Linux. Missing libs give "Could not load 'jcef' library".

## Gotchas
- WebView is optional, only needed for some extensions.
- Mihon (Tachiyomi) and Neko can sync with the server via the Suwayomi extension/tracker.
- Wiki page "Configuring-Tachidesk-Server" was not retrievable (404 on raw wiki URL). Config keys come from docker startup script (see github-docker-tachidesk-scripts.md).
