# vstavrinov/acestream-engine (engine image source)

**Source URL(s) + fetch date:** https://raw.githubusercontent.com/vstavrinov/acestream-engine/master/Dockerfile · fetched 2026-11-26 (named reference from plan.md section 1; no repo URL in draft)

## What it is
Dockerfile that packages the closed-source Ace Stream engine (`start-engine`, `acestreamengine`) on Python 3.10. Shows how the vendor tarball is installed.

## Install/build steps and build deps
- `FROM python:3.10`
- `SHELL ["/bin/bash", "-o", "pipefail", "-c"]`
- No ARG instructions.
- ENV: `BASE_URL=https://download.acestream.media/linux`, `ACE_VERSION=3.2.11_ubuntu_22.04_x86_64_py3.10`, `PYTHONDONTWRITEBYTECODE=0`, `TMPDIR=/dev/shm`.
- Creates user `ace` (bash shell, home `/srv/ace`, created if missing).
- `WORKDIR /srv/ace`; `ADD setup.cfg` into the working directory.
- One RUN: downloads `acestream_$ACE_VERSION.tar.gz` from `$BASE_URL` with curl and pipes into `tar` extraction; enters `lib`, unzips the `.egg` file(s) and deletes them; creates symlinks `.ACEStream` and `engine_runtime.json` in home pointing to `/dev/shm`; `pip install --no-cache-dir --upgrade -r requirements.txt`.
- No apt installs in the engine Dockerfile.

## Runtime deps
Python 3.10 base (`python:3.10`), engine `requirements.txt` packages (per plan: pycryptodome, lxml, apsw, psutil, pynacl, iso8601, aiohttp; not verified here).

## Binaries/entrypoint/CLI flags
- No ENTRYPOINT.
- CMD (shell form): `mkdir /dev/shm/.ACEStream`; `./start-engine --client-console --live-cache-type memory`.
- Asset: `acestream_3.2.11_ubuntu_22.04_x86_64_py3.10.tar.gz` from `https://download.acestream.media/linux/`. Naming pattern: `acestream_<ACE_VERSION>.tar.gz`, where ACE_VERSION = `<engine>_<ubuntu release>_<arch>_py<pyver>`.

## Env vars
| Name | Value |
| --- | --- |
| `BASE_URL` | `https://download.acestream.media/linux` |
| `ACE_VERSION` | `3.2.11_ubuntu_22.04_x86_64_py3.10` |
| `PYTHONDONTWRITEBYTECODE` | `0` |
| `TMPDIR` | `/dev/shm` |

## Ports
None declared.

## Volumes/paths and persistent data
`/srv/ace` (home/workdir), `/dev/shm` (`.ACEStream`, `engine_runtime.json` symlinks).

## User/UID & permissions
Runs as `ace` (uid not stated in Dockerfile; chart uses uid 1000).

## Config files and formats
`requirements.txt` (pip), `setup.cfg`.

## Healthcheck/readiness endpoints
None.

## Version/release info and asset naming
Engine version pinned via `ACE_VERSION` ENV; tarball named as above. No checksum in the Dockerfile.

## Arch support
Only x86_64 (asset name). No arm64 build referenced.

## Gotchas
- Dockerfile is `FROM python:3.10`, not the ubuntu base; the plan's ubuntu-26.04 CPython 3.10 shared library question is not answered here.
- Engine relies on `/dev/shm` for runtime state (symlinks), which conflicts with read-only rootfs (see plan.md section 9).
- Fetched Dockerfile did not show `libpython3.10.so` handling beyond the pip install.

## Contradictions with plan.md
- None on version or base image. plan.md section 1 states base `python:3.10`: confirmed.
