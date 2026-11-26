# BGameiro2000/dockerfile arch-cern-root Dockerfile

Source: https://github.com/BGameiro2000/dockerfile/blob/master/arch-cern-root/Dockerfile (raw, master), fetched 2026-11-26. Full file read.

## Build
- `FROM archlinux:latest` (unpinned).
- `LABEL maintainer='BGameiro <projects+docker@bgameiro.me>'`.
- One RUN: `pacman --noconfirm -Syyu jupyter root` (full sync and upgrade, Arch packages).

## Runtime
- `EXPOSE 8888`; `VOLUME /appdata`.
- `CMD cp -R -n /usr/share/jupyter/* /appdata && root --notebook --ip=* --port=8888 --no-browser --notebook-dir=/appdata --allow-root`
  - Seeds /appdata from /usr/share/jupyter (no-clobber `-n`).
  - Runs ROOT's own `root --notebook` server (not standalone `jupyter notebook`).
  - Runs as root (`--allow-root`), no USER.

## Env / UID / arch
- No ENV, no USER, no ARG. Arch: whatever archlinux supports (Arch is x86_64 only in practice).

## Gotchas
- Fully unpinned (`archlinux:latest`, `pacman -Syyu`): not reproducible.
- Root notebook server is started through the ROOT binary, not a separate Jupyter service.
