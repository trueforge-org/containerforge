# Docker Hub: ckulka/baikal

**Source URL(s) + fetch date:** https://hub.docker.com/r/ckulka/baikal · fetched 2026-11-26

## What it is
"Ready-to-go Baikal server, incl. docker-compose.yml & Systemd service file." CalDAV/CardDAV server with admin interface, built on sabre/dav. 5M+ pulls, 48 stars.

## Tags
- Weekly rebuilds: `latest` and `apache` (newest Apache-based), `apache-php8.2`, `nginx`, `nginx-php8.2`.
- Version tags per release (0.10.1, 0.10.0, 0.9.5 and older back to 0.2.7 in the Tags tab): `<ver>`, `<ver>-apache`, `<ver>-apache-php8.2`, `<ver>-php8.2`, `<ver>-nginx`, `<ver>-nginx-php8.2`.
- `0.10.1-nginx` is listed (links to `nginx.dockerfile`). Chart and draft use this tag.
- `experimental` tag: latest source, for testing only.
- Latest is 0.10.1-era, not 0.13.0: no `0.13.0` tag appears on the fetched page.

## Install/build steps
- `docker pull ckulka/baikal`
- Example run: `docker run --rm -it -p 80:80 ckulka/baikal:nginx`

## Persistent data
`/var/www/baikal/Specific` and `/var/www/baikal/config`.

## Architectures
amd64, arm32v7, arm64v8, i386. Versions 0.4.5 and older amd64 only; 0.9.0 and older no i386.

## Licence
Not stated on the Hub page (Baikal is GPL-3.0-only per upstream composer.json).

## Last updated / size
Latest tag updated 4 days before fetch (page relative date); 190.3 MB; digest `sha256:171f97a24…`.

## Contradictions with plan.md
- plan.md Version 0.13.0 vs the image: the Hub shows tags up to 0.10.1 only. plan.md notes the chart uses 0.10.1-nginx; the 0.13.0 target is a new build, not a published image tag. Not a plan error; recorded for awareness.
