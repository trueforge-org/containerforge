# Upstream: Pryaxis/TShock (docs and release)

Source URL(s): https://tshock.readme.io/docs/getting-started (fetched 2026-11-27); https://api.github.com/repos/Pryaxis/TShock/releases/latest (one call, 2026-11-27, no usable data).

## Getting started (tshock.readme.io)
- Download from GitHub Releases; extract the archive (do not run from inside it, settings lost).
- Mono: TShock requires mono-complete per docs (Linux run via `mono TerrariaServer.exe`). Note: this container uses .NET 9 runtime instead (see ich777 Dockerfile).
- First start: choose world, server port (default 7777), then `/setup [setupcode]` in-game; owner account via `/login`.
- Upgrade: replace TerrariaServer.exe, keep the install folder.

## Release
- Failed: releases/latest returned no tag_name or assets. Version in plan: v6.2.1 (from urls.txt, not verified here).
