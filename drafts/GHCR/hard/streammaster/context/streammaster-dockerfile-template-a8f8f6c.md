# carlreid/StreamMaster Dockerfile.template at a8f8f6c
Source URL: https://raw.githubusercontent.com/carlreid/StreamMaster/a8f8f6cda65138226ea2cfe73c5dd0db3a040c88/Dockerfile.template (fetched 2026-11-27)

This is a template: the file starts at LABEL (no FROM in this file). The `sm` build stage (`COPY --from=sm /app/publish`) is not defined here, so base image, .NET build and the postgres package install are not visible.

## Labels
- url https://hub.docker.com/r/carlreid/streammaster/, source https://github.com/carlreid/StreamMaster, vendor/authors carlreid, title "Stream Master"

## Steps
- WORKDIR /app; RUN mkdir /config
- ENV PUID=0, PGID=0
- COPY src/scripts/docker-entrypoint.sh, docker-ensure-initdb.sh -> /usr/local/bin/; chmod +x; symlink docker-enforce-initdb.sh -> docker-ensure-initdb.sh
- COPY --from=sm /app/publish . ; COPY --from=sm /app/publish/wwwroot ./wwwroot
- COPY src/scripts/backup.sh, restore.sh, yt.sh -> /usr/local/bin/
- COPY src/scripts/entrypoint.sh -> /entrypoint.sh; env.sh -> /env.sh; chmod +x all

## Ports
- EXPOSE 7095 (StreamMaster)
- EXPOSE 5432 (Postgres)

## Entrypoint
- ENTRYPOINT ["/entrypoint.sh", "dotnet", "StreamMaster.API.dll"]
- STOPSIGNAL SIGINT

## User
- No USER line; runs as root (PUID/PGID default 0)

## Gotchas
- Postgres is expected inside the same container (EXPOSE 5432, docker-entrypoint/initdb scripts), while TrueCharts values use a separate postgresql dependency with POSTGRES_HOST from secret.
