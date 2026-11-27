# Crafty docs and craftycontrol.com

## Source URL(s) + date
- https://craftycontrol.com (fetched 2026-11-27, marketing text)
- https://docs.craftycontrol.com (fetched 2026-11-27, nav only)
- https://docs.craftycontrol.com/pages/getting-started/installation/docker/ (fetched 2026-11-27, text extracted)

## Docker install (docs)
- Two methods: pre-built image `registry.gitlab.com/crafty-controller/crafty-4:latest` or `arcadiatechnology/crafty-4:latest` (Docker Hub); or local build `docker build . -t crafty-4`.
- Documented `docker run` (abridged):
  - `--name crafty_container --detach --restart always`
  - `-p 8443:8443 -p 8123:8123 -p 19132:19132/udp -p 25500-25600:25500-25600`
  - `-e TZ=Etc/UTC`
  - `-v <dir>/docker/backups:/crafty/backups`, `logs:/crafty/logs`, `servers:/crafty/servers`, `config:/crafty/app/config`, `import:/crafty/import`
- docker-compose example uses `registry.gitlab.com/crafty-controller/crafty-4:latest`.
- Docs warn: Docker for Windows/WSL2 not supported (volume permission issue).
- Update: `docker pull` new image, recreate container with same options.

## Site facts
- Crafty Controller: self-hosted web panel for Minecraft servers (Argon2 password hashing, SSL web server by default).
- Default web UI port in docs: 8443 (HTTPS).

## Failures
- https://docs.craftycontrol.com/ root: navigation shell only.
- https://docs.craftycontrol.com/pages/getting-started/ (guessed follow-up): 404.
