# Notifiarr client README (main branch)

Source URL(s) + date: https://raw.githubusercontent.com/Notifiarr/notifiarr/main/README.md (fetched 2026-11-27). Wiki https://notifiarr.wiki returned 403 (not retried); notifiarr.com not fetched.

## What the client is
- Unified client for Notifiarr.com. Built with Go and Svelte. Runs on most OSes.
- License: MIT, copyright 2020-2026 Go Lift (per README).

## Features
- Service/network health checks with notifications
- Trigger scripts/commands from Discord; media requests from Discord
- TRaSH profile sync to Radarr/Sonarr; backup corruption checks for starr apps
- Scheduled notifications (system snapshots, media/downloads dashboards, URL polling, Plex sessions)
- Plex finished-watching notifications; Tautulli user map; automated Plex trash emptying
- Radarr collection gaps; MDBList and Radarr/Sonarr library syncing

## Install/config facts
- Docker run method, default port(s), config file path, DN_ env vars, volumes, healthcheck/ping URLs: NOT in README.
- Install guide link (not fetched): https://notifiarr.wiki/pages/client/install/
- Troubleshooting link (not fetched): https://notifiarr.wiki/pages/client/troubleshooting/
- Wiki source: github.com/Notifiarr/mkdocs-wiki.

## Gotchas
- Chart-level facts (DN_API_KEY, DN_BIND_ADDR, /config, /tmpdir) are in truecharts-notifiarr.md; upstream runtime paths beyond that are unverified here.
