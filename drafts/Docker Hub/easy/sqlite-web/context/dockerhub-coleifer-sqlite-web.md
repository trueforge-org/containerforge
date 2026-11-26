# coleifer/sqlite-web (Docker Hub)

Source URL(s) + fetch date:
- https://hub.docker.com/r/coleifer/sqlite-web (fetched 2026-11-26)

## What it is
"Docker image for running web-based SQLite database browser." 100K+ pulls, 11 stars.

## Install/build steps
- `docker pull coleifer/sqlite-web`
- Example run: `docker run -it --rm -p 8080:8080 -v /path/containing/database:/data -e SQLITE_DATABASE="db_filename.db" coleifer/sqlite-web`
- Page also has a bash helper script (default host port 8012, maps to container 8080).
- Source: https://github.com/coleifer/sqlite-web ; Dockerfile: https://github.com/coleifer/sqlite-web/blob/master/docker/Dockerfile (the master Dockerfile, not the 8c72947 pin).

## Env vars
- `SQLITE_DATABASE`: database filename (page). Not read by the Dockerfile at 8c72947 or by sqlite_web.py; the image in the README uses the ENTRYPOINT with a positional argument (README: "Pass the database filename as the argument").

## Ports
8080 (container), mapped with `-p 8080:8080`.

## Volumes
Host directory mounted at `/data`.

## Version/release info and asset naming
- Only tag shown: `latest` (digest sha256:1e5b86237…, 48.1 MB). Updated over 1 year ago. No exact date.

## Arch support
Not listed.

## Gotchas
- Page's example uses `SQLITE_DATABASE`; the Dockerfile ENTRYPOINT takes the filename as an argument and has no code path for the env var, so the published image may differ from the repo Dockerfile.
- Page says "Docker image" but the README docker example uses `ghcr.io/coleifer/sqlite-web:latest`.

## Contradictions with plan.md
- plan.md section 6 says SQLITE_DATABASE is "image-level, not upstream": the Docker Hub page documents it as the image's variable. Corrected in plan.md.
