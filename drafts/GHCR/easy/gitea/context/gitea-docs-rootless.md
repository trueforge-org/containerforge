# Gitea docs: Installation with Docker (rootless)

## Source URL(s) + date

- https://docs.gitea.com/installation/install-with-docker-rootless
- Fetched 2026-11-27

## What it is

- Official rootless image install guide. Docs version selector lists 29-dev and 28.4.0 as current.

## Image tags (docs)

- `docker.gitea.com/gitea:28.4.0-rootless` (docs image host; plan uses GHCR tag from chart).
- `:latest-rootless`, `:1-rootless`, `:28.4.0-rootless` (stable); `:main-nightly-rootless` (dev); `:1.x-nightly-rootless` (release branch nightly).

## Differences vs rootful image (docs)

- Rootless does not require root on host; stricter UID/GID requirement.
- Rootless uses its builtin SSH server (rootful uses standalone OpenSSH).
- Volume mapping and directory layout differ.

## Ports

- `3000:3000` (web), `2222:2222` (SSH).

## Volumes/paths

- `./data:/var/lib/gitea`, `./config:/etc/gitea`.
- Mounts `/etc/timezone:ro`, `/etc/localtime:ro`.

## User/UID

- Default uid:gid `1000:1000`. Host dirs must be owned by 1000:1000 (`sudo chown 1000:1000 config/ data/`).
- Custom user example: `user: 1001` (then volumes must match that uid).
- Named volumes need no chown.

## Errors (docs)

- Wrong permissions produce: `mkdir: can't create directory '/var/lib/gitea/git': Permission denied`, `/var/lib/gitea/git is not writable`, `docker setup failed`.

## Env vars / config

- Docs point to "Environment variables" and "Configuration Cheat Sheet" pages (not fetched).

## Gotchas

- Rootless image must use built-in SSH server.
- Named volume setup: mount both `gitea-data:/var/lib/gitea` and `gitea-config:/etc/gitea`.
