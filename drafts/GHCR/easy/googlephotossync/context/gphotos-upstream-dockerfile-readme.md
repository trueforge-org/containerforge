# Upstream gphotos-sync Dockerfile, release, license, README

## Source URL(s) + date

- https://raw.githubusercontent.com/gilesknap/gphotos-sync/master/Dockerfile (identical to pinned b50baadcd769c09f32b5f9c1020dc3b75540c6f1 Dockerfile; diffed)
- https://api.github.com/repos/gilesknap/gphotos-sync/releases/latest
- https://api.github.com/repos/gilesknap/gphotos-sync/license
- https://raw.githubusercontent.com/gilesknap/gphotos-sync/master/README.rst (fetched as README.md; the .md name returned 404)
- Fetched 2026-11-27

## Status

- README.rst top banner: "This project was archived on Oct 4th 2024" (see discussion link gphotos-sync-discussion/discussions/1). Upstream is archived; no release since 3.2.5 per the releases/latest API.

## What it is

- Python CLI `gphotos-sync` (PyPI `gphotos-sync`). Read-only backup of Google Photos (photos, videos, albums, Creations).
- Documented as: "This software is read only and never modifies your cloud library".

## Build (Dockerfile, master = pinned)

- Build stage: `FROM python:3.11 as build`, `ARG PIP_OPTIONS=.`, `python -m venv /venv`, `ENV PATH=/venv/bin:$PATH`, `COPY . /context`, `WORKDIR /context`, `RUN pip install ${PIP_OPTIONS}`.
- Runtime stage: `FROM python:3.11-slim as runtime`, `COPY --from=build /venv/ /venv/`, `ENV PATH=/venv/bin:$PATH`.
- `ENTRYPOINT ["gphotos-sync"]`, `CMD ["--version"]`.
- No apt packages in template. No EXPOSE, VOLUME, USER, HEALTHCHECK.

## Release (releases/latest)

- tag `3.2.5`, published 2024-07-14T07:25:32Z.
- Assets: `gphotos_sync-3.2.5-py3-none-any.whl`, `gphotos_sync-3.2.5.tar.gz`, `requirements-dev-3.x.txt`, `requirements-test-ubuntu-latest-3.10.txt` (others listed).
- Download base: `https://github.com/gilesknap/gphotos-sync/releases/download/3.2.5/<asset>`.
- Wheel is pure Python (`py3-none-any`).

## License

- Apache-2.0 (SPDX `Apache-2.0`), per license API.

## CLI facts (README.rst)

- Flag `--flush-index`: rebuilds the index DB. Required once when upgrading to 3.2.4 or later (schema change; error `sqlite3.OperationalError: no such column: IsSharedAlbum` if skipped).
- Docs site (not fetched; 404 on gilesknap.github.io/gphotos-sync): tutorial at `.../main/tutorials/installation.html`.
- Config/token paths and env vars: NOT in README.rst. Still UNVERIFIED.

## Gotchas

- Upstream archived 2024-10-04; no fixes/releases after 3.2.5.
- Google API limits (README): videos transcoded to lower quality; originals converted to "High Quality"; GPS info removed from metadata.
- Pure-Python wheel; arch-independent.
