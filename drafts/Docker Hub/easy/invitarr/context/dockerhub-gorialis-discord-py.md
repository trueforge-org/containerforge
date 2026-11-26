# gorialis/discord.py (Docker Hub)

Source URL(s) + fetch date:
- https://hub.docker.com/r/gorialis/discord.py (named base image of upstream Invitarr Dockerfile)
- Fetched 2026-11-26

## What it is
Dockerfiles/images for Python bots using discord.py. Listed under "Languages & frameworks".

## Tags
- Pattern `<pyver>-<distro>-<source>-<variant>`. Python 3.14.4, 3.13.13, 3.12.13, 3.11.15, 3.10.20 shown/mentioned. Distros: trixie, slim-trixie, bookworm, slim-bookworm, alpine. Source: `master` (discord.py master) or `pypi` (released package). Variants: `minimal`, `full`, `extras`.
- `latest` = trixie/pypi/full (also `full`, `pypi`, `trixie`).
- 150 variants, 2464 tags. Largest shown: `alpine-extras` 651.8 MB.
- Python 3.8 and 3.9 and Debian bullseye removed; trixie added.
- Pull count 500K+. Architectures not stated.

## Variants
- `minimal`: discord.py with voice and docs support, plus ffmpeg.
- `full` (default): adds precompiled common packages (asyncpg, Pillow, lxml, matplotlib, pylint).
- `extras`: builds on full (aiomysql, beautifulsoup4, redis, sqlalchemy, tox).

## Usage
- `FROM gorialis/discord.py`, set WORKDIR, pip install requirements, copy code, run bot.
- Example tag `gorialis/discord.py:alpine-extras`. The `3.9-alpine` tag in page example has been removed.

## Warnings
- Maintainer says the image no longer gets much active effort, may be the last update, and users should consider building their own purpose-built image.

## Licensing
discord.py is MIT License (copyright Rapptz).

## Relevance to plan
Plan does not use this base (it uses ContainerForge python base and installs discord.py 2.x into /app/venv). Upstream's base is discord.py-pinned Python; plan's 2.x port is consistent with the upstream image being unmaintained.
