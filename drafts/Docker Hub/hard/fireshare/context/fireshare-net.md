# fireshare.net

Source URL(s) + fetch date:
- https://fireshare.net (fetched 2026-11-26)

## What it is

Fireshare: self-hosted tool that turns a server folder into a searchable library of videos and images, each file with its own shareable URL. No re-encoding for viewers. "No upload caps". Optional transcoding adds quality levels.

Features: per-file privacy (public, link-only, password-protected), rich link previews (Discord, Slack, Twitter), automatic sorting by game with cover art, multi-user accounts with ten permission keys (since v1.8.0), two-factor auth, IP whitelisting, Firesync companion tray app (Windows/Linux, not part of this image). Single Docker container, no external database.

## Version and license

- Shows current version v1.8.1 (the site may be behind the release).
- "GPLv3", "no paid tier". Source on GitHub. About 1.5k stars, 730k Docker pulls (per page).
- LDAP removed in v1.8.0; users needing it told to pin to 1.7.9.

## Links

- Full install docs: https://github.com/fireshare-app/fireshare#installation
- Docker Hub: https://hub.docker.com/r/shaneisrael/fireshare
- Changelog: /changelog; demo: https://demo.fireshare.net
- GitHub: https://github.com/fireshare-app/fireshare; issues: https://github.com/fireshare-app/fireshare/issues
- Firesync (not used here): https://github.com/fireshare-app/firesync
