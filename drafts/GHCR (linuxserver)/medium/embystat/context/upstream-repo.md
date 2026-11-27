# Upstream: mregni/EmbyStat (repo page and release)
Sources: https://github.com/mregni/EmbyStat; https://github.com/mregni/EmbyStat/releases/tag/0.2.0-beta.30 (fetched 2026-11-27). api.github.com releases/latest NOT fetched (not in urls.txt; covered by Dockerfile).

## What it is
- "Multiplatform statistics server for Emby server"; computes stats from a local Emby or Jellyfin server
- Stack: .NET Core 3.1 (page), LiteDB 5, SignalR, NLog, React
- License MIT; not flagged archived
- README: "sleep mode"; still Alpha; JellyStat suggested as alternative

## Install/run (per repo page)
- Windows x64/x86 on IIS or Kestrel; Docker images uping/embystat (beta-win10-x64, beta-ubuntu-x64); Debian, Ubuntu, Fedora packages
- Ports, data path and run commands NOT stated on page

## Release 0.2.0-beta.30
- Marked Latest; published 16 May (year not shown) by mregni; commit f3fc673; GPG key expired
- Asset names not loaded (page says 9 assets)
- Notes: jobs refactored; Movies/Shows incremental jobs; DB back on SQLite; NuGet updates; basic user page; targets NET6.0; UI loading improved
