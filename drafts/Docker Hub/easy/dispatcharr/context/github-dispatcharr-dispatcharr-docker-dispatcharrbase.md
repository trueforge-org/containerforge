# Dispatcharr/Dispatcharr docker/DispatcharrBase (tag v0.34.1)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/Dispatcharr/Dispatcharr/v0.34.1/docker/DispatcharrBase · 2026-11-26

## Structure
- ARG `FFMPEG_IMAGE=ghcr.io/dispatcharr/ffmpeg:latest`. Stages `builder` and `final`, both `FROM ${FFMPEG_IMAGE}`.
- ENV (both stages): `DEBIAN_FRONTEND=noninteractive`, `UV_PROJECT_ENVIRONMENT=/dispatcharrpy`, `VIRTUAL_ENV=/dispatcharrpy`, `PATH=$VIRTUAL_ENV/bin:$PATH`, `UV_COMPILE_BYTECODE=1`, `UV_LINK_MODE=copy`.
- Builder apt: `ca-certificates software-properties-common gnupg2 curl wget`; deadsnakes PPA; `python3.13 python3.13-dev python3.13-venv libpython3.13`; `libpcre2-dev`; `build-essential gcc g++ gfortran libopenblas-dev libopenblas0 ninja-build`; comskip deps `autoconf automake libtool pkg-config libargtable2-dev libavformat-dev libswscale-dev`.
- Final apt: same base set and PPA; `python3.13 python3.13-venv libpython3.13`; `libpcre2-8-0 libopenblas0 procps pciutils jq`; `nginx libargtable2-0`; `libavformat62 libavcodec62 libavutil60 libswscale9`; `vlc-bin vlc-plugin-base`.
- uv: `COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/`.
- Venv: `WORKDIR /tmp/build`, copies pyproject.toml, version.py, README.md; `uv sync --python 3.13 --no-cache --no-install-project --no-dev`.
- NumPy: built from source wheel (`--no-binary numpy`, `-Csetup-args=-Dcpu-baseline="none"`, `-Dcpu-dispatch="none"`) into `/opt/`.
- Comskip: builds `https://github.com/erikkaashoek/Comskip/archive/refs/heads/master.tar.gz` (master, not a tag), installs `/usr/local/bin/comskip`.
- Redis: `redis-server` from packages.redis.io (apt). No version pinned here.
- PostgreSQL: `postgresql-17 postgresql-contrib-17` from apt.postgresql.org (pgdg).
- Render group `-g 109`; `/etc/localtime` set to UTC.
- USER none; EXPOSE none; CMD none; ENTRYPOINT `["/app/docker/entrypoint.sh"]`.
- Paths: `/dispatcharrpy` (venv), `/tmp/build`, `/opt/` (numpy wheel), `/usr/local/bin/comskip`, `/bin/uv`.

## Notes vs plan.md
- Plan says "Redis 7 and PostgreSQL 17". Redis version is not pinned in this file (only `redis-server` from redis.io apt), so "Redis 7" is UNVERIFIED here.
- Plan's apt runtime list is a subset of upstream (`pciutils`, `libargtable2-0`, `libav*` are not in the plan's list). Plan builds from Ubuntu ffmpeg instead of the custom `ghcr.io/dispatcharr/ffmpeg`.
