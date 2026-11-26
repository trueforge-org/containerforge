# Upstream Dockerfile @ V1.0.0-beta-4 (Casvt/Kapowarr)

## Source URL(s) + date
- https://raw.githubusercontent.com/Casvt/Kapowarr/V1.0.0-beta-4/Dockerfile (2026-11-26)
- Not fetched: https://github.com/Casvt/Kapowarr/blob/V1.0.0-beta-4/Dockerfile (same file as raw).

## Full file
```
# syntax=docker/dockerfile:1
FROM python:3.8-slim-buster
STOPSIGNAL SIGINT
WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt
COPY . .
EXPOSE 5656
CMD [ "python3", "/app/Kapowarr.py" ]
```

## Install/build steps + deps
- `pip3 install -r requirements.txt` into the system Python (no venv). No apt packages.

## Runtime deps
- Python 3.8 (`python:3.8-slim-buster`, EOL).

## Entrypoint/flags
- `CMD python3 /app/Kapowarr.py`. No ENTRYPOINT. No flags.

## Ports
- `EXPOSE 5656`.

## Volumes/paths
- `WORKDIR /app`; source copied to `/app`. No VOLUME instruction.

## User/UID
- No `USER` line: runs as root.

## Gotchas
- No PUID/PGID handling in this Dockerfile (V1.3.2 docs use PUID/PGID; see casvt-docs-docker.md).
- `STOPSIGNAL SIGINT`.
- No LICENSE copy in this Dockerfile.
