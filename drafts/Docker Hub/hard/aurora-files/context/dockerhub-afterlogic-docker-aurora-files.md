# Docker Hub: afterlogic/docker-aurora-files

**Source URL(s) + fetch date:** https://hub.docker.com/r/afterlogic/docker-aurora-files · fetched 2026-11-26

## What it is
Docker setup for Aurora Files: nginx, PHP-FPM 8.3 and MySQL on Alpine. Loosely derived from khromov/alpine-nginx-php8. Publisher: afterlogic.

## Install/build steps
- `docker pull afterlogic/docker-aurora-files`
- Setup via `docker compose up`, from the GitHub clone or the Hub compose file.
- Site on port 80. Admin panel at `/adminpanel`; default login `superadmin` with an empty password. Click the button in the database settings to create or update tables.

## Version/release info
- Only `latest` tag listed; no version numbers. Hub image may lag the newest product release.
- Digest `sha256:3252fd9aa…`, ~160 MB, 10K+ pulls, last updated about 1 month ago (page relative date).

## Arch support
Not stated.

## License
Repository content under MIT (per page). The Aurora Files application itself is AGPLv3 (see github-afterlogic-aurora-files.md).

## Gotchas
- Default admin login `superadmin` with an empty password is documented by the wrapper page. Relevant to first-run security in the port.
