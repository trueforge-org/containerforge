# Docker Hub: xavierh/external-ip

Source URL(s) + fetch date:
- https://hub.docker.com/r/xavierh/external-ip
- Fetched 2026-11-26

## What it is
Container that polls the public IP and sends a notification via Pushover or Apprise when it changes. Source: github.com/xavier-hernandez/docker-external-ip.

## Install/build steps
Prebuilt image only. The page has no build steps.

## Env vars
Same set as upstream README: TZ, RECOVERY_ALERT (default False), DELAY (default 5 minutes), PROVIDER (default cloudflare), NOTIFICATION_TYPE (PUSHOVER or APPRISE), PUSHOVER_TOKEN, PUSHOVER_USER, PUSHOVER_TITLE, APPRISE_TITLE, APPRISE_1..APPRISE_10, SAVE_IP. Details in github-xavier-hernandez-docker-external-ip.md.

## Ports
None documented.

## Volumes/paths
`/path/to/data:/stor-external-ip`, optional, required with SAVE_IP.

## Version/release info
Only the `latest` tag is listed ("stable"). Size about 37.8 MB. "Last updated about 3 months ago" at fetch time. Pull count shown as "10K+".

## Arch support
linux/amd64, linux/arm/v7, linux/arm64/v8.

## Gotchas
- Compose example in the page uses container_name `external_ip` and restart `always`.
- Page gives no version numbers, so no version pin can be verified from this page.
