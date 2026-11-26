# Comskip README

Source: https://github.com/erikkaashoek/Comskip (raw README on master), fetched 2026-11-26

## What it is
- Commercial detector (http://www.kaashoek.com/comskip/).

## Requirements
- FFmpeg headers and shared libs (2.4+)
- libargtable2 (option parsing)
- Optional: SDL (GUI)

## Build steps (from GitHub)
- Needs GNU autotools (autoconf, automake, libtool).
- `git clone git://github.com/erikkaashoek/Comskip` (or https) -> `cd Comskip` -> `./autogen.sh` -> `./configure` -> `make`.
- Tarball build: `./configure && make` (no autogen).
- Static: `./configure --enable-static` (not supported on macOS).

## Ubuntu deps (per README)
- Xenial: `apt-get install -y autoconf libtool git build-essential libargtable2-dev libavformat-dev libsdl1.2-dev`
- Modern equivalent (matching Dockerfile): build-essential libargtable2-dev autoconf libtool-bin libavformat/libavcodec/libavutil-dev libsdl1.2-dev

## Gotchas
- README references old Ubuntu releases (14.04–16.04) and ffmpeg-opti builds; not current package names.
- Windows cross-compile script `cross_compile_comskip.sh` exists (not relevant to Linux container).
