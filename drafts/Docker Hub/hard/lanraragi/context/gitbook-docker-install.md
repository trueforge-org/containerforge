# LANraragi docs: Docker install (follow-up)

Source URL(s): https://sugoi.gitbook.io/lanraragi/installing-lanraragi/docker.md. Fetched 2026-11-26.

## Image / requirements
- Image `difegue/lanraragi`. Tags for major releases (e.g. `0.4.0`); `nightly` tracks dev (dangerous).
- Docker >= 20.10.0 recommended (faccessat2). Doc says base Alpine 3.14 (outdated; pinned Dockerfile uses alpine:3.20).

## Run
- `docker run --name=lanraragi -p 3000:3000 --mount type=bind,source=[CONTENT_DIR],target=/home/koyomi/lanraragi/content --mount type=bind,source=[DATABASE_DIR],target=/home/koyomi/lanraragi/database --mount type=bind,source=[THUMBNAIL_DIR],target=/home/koyomi/lanraragi/thumb difegue/lanraragi`
- Optional `--restart always`; optional bind `/home/koyomi/lanraragi/lib/LANraragi/Plugin/Sideloaded`.
- Compose: service/container `lanraragi`, ports `3000:3000`, volumes content/thumb/database, restart `unless-stopped`.
- Named volumes alternative: lrr-database and lrr-thumbnails (content stays bind).

## Ports / paths
- Web UI `http://localhost:3000`. Remap host side only (`-p HOST:3000`), since healthcheck assumes 3000.
- content: archives (thumbnails also generated there). database: `database.rdb`. thumb: `/home/koyomi/lanraragi/thumb`.

## Env
| Var | Default | Notes |
| --- | --- | --- |
| LRR_UID | 9001 | run-as UID |
| LRR_GID | 9001 | run-as GID |
| LRR_NETWORK | - | keep `:3000` for healthcheck; SSL setups |
| LRR_AUTOFIX_PERMISSIONS | 1 (Dockerfile) | `-1` disables startup perm fixing |
- UMASK and PUID/PGID not mentioned.

## Startup permissions
- Thumb owned by LRR UID/GID; content files owner-readable, folders owner-executable. Slow for large libraries; may block Swarm startup.

## Upgrade
- pull, stop, rm, re-run with same mounts. Data persists in mounted dirs/volumes.

## Build own
- `npm run docker-build` from a cloned repo.
- Doc caveat: missing trailing backslash in its run command.
