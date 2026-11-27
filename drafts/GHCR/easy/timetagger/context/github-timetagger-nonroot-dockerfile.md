# Upstream Dockerfile: almarklein/timetagger @ 681720d (deploy/repo.nonroot.Dockerfile)

Source URL(s) + date: https://raw.githubusercontent.com/almarklein/timetagger/681720d84c94be660f30947db4b23e52d36cbe32/deploy/repo.nonroot.Dockerfile (fetched 2026-11-27)

## Build
- Base: `python:3.13-slim-bookworm` (single stage).
- `groupadd -g 1000 timetagger`; `useradd -r -u 1000 -m -g timetagger timetagger`; `mkdir /opt/timetagger`; chown to timetagger.
- `USER 1000`; `WORKDIR /opt/timetagger`; `COPY . /opt/timetagger` (build context = repo root).
- `pip --no-cache-dir install pip --upgrade`; `pip --no-cache-dir install uvicorn uvloop httptools`; `pip install --no-cache-dir --no-warn-script-location -e .` (editable install from repo).
- `CMD ["python", "-m", "timetagger"]`. No ENTRYPOINT, no EXPOSE, no VOLUME, no HEALTHCHECK, no ENV.

## Runtime
- UID/GID 1000 (rootless-compatible). `COPY` has no `--chown`, so repo files are owned by root:root; only /opt/timetagger dir is chowned to timetagger.
- Default bind/port and data dir are not set in this Dockerfile (chart sets TIMETAGGER_BIND).

## Gotchas
- Dockerfile comment says it is used by CI to push to GHCR; the chart tag `v26.1.3-nonroot` is a release tag, not confirmed to match this commit.
- Dockerfile is for the nonroot variant only; root variant is a separate Dockerfile (not fetched).
