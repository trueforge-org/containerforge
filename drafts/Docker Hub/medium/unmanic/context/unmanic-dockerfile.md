# Unmanic docker/Dockerfile (commit 1c324b8)

Source URL(s): https://raw.githubusercontent.com/Unmanic/unmanic/1c324b8/docker/Dockerfile (fetched 2026-11-27)

## Base and labels
- `FROM ubuntu:24.04`. Maintainer label only.
- ENV: `LIBVA_DRIVERS_PATH=/usr/lib/x86_64-linux-gnu/dri`, `NVIDIA_DRIVER_CAPABILITIES=compute,video,utility`, `NVIDIA_VISIBLE_DEVICES=all`.

## Build args
| ARG | Default |
| --- | --- |
| JELLYFIN_FFMPEG_VERSION | 7 |
| BTBN_FFMPEG_RELEASE | autobuild-2026-06-08-14-24 |
| BTBN_FFMPEG_VERSION | 8 |
| NODE_MAJOR | 22 |

## Build steps (apt, arch-conditional)
- Build deps: autoconf, automake, build-essential, cmake, g++, git, libaom/libass/libdav1d/libfdk-aac/libmp3lame/libopus/libsvtav1/libvpx/libx264/libx265 dev packages, meson, nasm, ninja, pkg-config, yasm and others.
- Runtime libs: libmediainfo0v5, libglib2.0-0, libharfbuzz0b, libxml2 etc.
- VAAPI: `va-driver-all`; Vulkan: libvulkan1, mesa-vulkan-drivers, vulkan-tools.
- x86 only: Intel GPU repo and intel-media-va-driver-non-free, libmfx1, libmfxgen1, libvpl2 and others.
- FFmpeg: x86 and aarch64 both install `jellyfin-ffmpeg${JELLYFIN_FFMPEG_VERSION}` from repo.jellyfin.org, symlinked to `/usr/local/bin/ffmpeg` and `ffprobe`. Also optional BtbN GPL build from GitHub releases API (`BtbN/FFmpeg-Builds`, tag `BTBN_FFMPEG_RELEASE`) into `/usr/lib/btbn-ffmpeg`; skipped if asset not found.
- Tools: git, jq, nano, sqlite3, nodejs (NodeSource, NODE_MAJOR 22), libimage-exiftool-perl, hwinfo, vainfo.
- Python: `python3-venv` at `/opt/venv`; `/etc/pip.conf` constrains setuptools<81; pip installs `/tmp/requirements.txt` (from repo root `requirements.txt`).
- Unmanic itself: `COPY /dist/ /src/` (pre-built wheel, must be built on host with `python3 ./setup.py bdist_wheel`), then `pip install /src/*.whl`.
- `mkdir /app /config /tmp/unmanic /library`; `chown 1000:1000` on `/app /config /tmp/unmanic`. `ENV HOME_DIR=/config`, `VIRTUAL_ENV=/opt/venv`.
- `COPY /docker/root /` (not fetched).

## Runtime
- `ENTRYPOINT ["/entrypoint.sh"]`, `CMD ["/usr/bin/unmanic"]`. No `USER` (root inside image; entrypoint from `docker/root`, not fetched).
- `EXPOSE 8888/tcp`.

## Gotchas
- Needs a host-built wheel in `dist/` before `docker build`.
- Image full_size ~609 MB per Docker Hub tags API.
- The BtbN step tolerates a missing asset (prints a message). The jellyfin ffmpeg step has no fallback in the script.
