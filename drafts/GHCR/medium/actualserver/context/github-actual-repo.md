# Upstream repo README: actualbudget/actual

**Source URL(s):** https://raw.githubusercontent.com/actualbudget/actual/master/README.md (fetched 2026-11-27); https://github.com/actualbudget/actual (repo root, same content); https://api.github.com/repos/actualbudget/actual/releases/latest

## What it is
- Actual: local-first personal finance tool, envelope budgeting, multi-device sync, NodeJS, MIT.
- Monorepo packages: loot-core, desktop-client, desktop-electron, sync-server, etc.

## Install options (README)
1. PikaPods (managed), 2. Fly.io (managed), 3. Self-hosted Docker image, 4. Desktop apps.
- Docker docs: https://actualbudget.org/docs/install/docker

## Release (api.github.com releases/latest, 2026-11-27)
- tag_name: `v26.11.0`, published 2026-11-02.
- Assets are desktop AppImages/dmg/appx (`Actual-linux-x86_64.AppImage`, `Actual-linux-arm64.AppImage`, ...). No server artifact on the release; server ships via npm.

## Gotchas
- Release assets are the desktop client, not the sync server.
