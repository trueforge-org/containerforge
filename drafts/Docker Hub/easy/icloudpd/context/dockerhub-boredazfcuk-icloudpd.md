# Docker Hub: boredazfcuk/icloudpd

Source URL(s) + fetch date: https://hub.docker.com/r/boredazfcuk/icloudpd · fetched 2026-11-26

## What it is
Alpine-based Docker container for the icloudpd CLI (per page). Syncs photo streams from multiple iDevices, stores credentials in the system keyring, can convert HEIC to JPG. Notifications: Telegram, Prowl, Pushover, WebHook, DingTalk, Discord, openhab, IYUU, WeCom, msmtp, Signal. Apple Advanced Data Protection is not supported and must be off.

## Install/build steps
- Pull: `docker pull boredazfcuk/icloudpd`.

## Env vars, ports, volumes
- Not listed on the Docker Hub page (placeholder README, pointing to CONFIGURATION.md in the GitHub repo, which was not fetched).

## Version/release info
- Tag `latest` only. Size 97.4 MB. Pull count 1M+. Updated about one month before fetch.

## Arch support
- Not stated.

## Gotchas
- Page advertises Alpine 3.24.1, while the GitHub Dockerfile says `alpine:3.23.4`. The chart pins tag 1.0.826. Versions disagree across sources.
- Page's features (remote re-auth via Telegram, Nextcloud upload) are beyond plan.md scope.
