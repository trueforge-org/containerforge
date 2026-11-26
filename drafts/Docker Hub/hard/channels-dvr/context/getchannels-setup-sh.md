# getchannels.com/dvr/setup.sh (official Linux installer)

Source URL(s) + fetch date:
- https://getchannels.com/dvr/setup.sh · fetched 2026-11-26 (script is POSIX sh, 2.7 KB)

## Purpose
Downloads the Channels DVR server for the current OS/arch into `./channels-dvr`; by default then runs the OS-specific installer. Draft/plan use `DOWNLOAD_ONLY=1`.

## Install/build steps
- Usage (from getchannels.com/dvr-server): `curl -f -s https://getchannels.com/dvr/setup.sh | sh` over SSH (may request sudo). Docker path: `curl -f -s https://getchannels.com/dvr/setup.sh | DOWNLOAD_ONLY=1 sh`.
- `DOWNLOAD_ONLY` (any non-empty value): prints "Channels DVR has been downloaded." and stops. No install step.
- Writes everything relative to the **current directory** (`$(pwd)/channels-dvr`). It has no install-dir variable; to place files in `/app`, `cd /app` first (or move the result).
- Required commands: curl or wget (curl first), `uname`, `tr`, `mkdir`, `chmod`, `ln`, `pwd`, `hostname`, `grep`.
- `set -e`; EXIT trap tells the user to contact support@getchannels.com on failure.

## Download layout
- Host: `https://cdn.channelsdvr.net/dvr`. Version from `$host/latest.txt` unless `DVR_VERSION` is set. OS from `uname -s` (lowercased) unless `DVR_OS`; arch from `uname -m` unless `DVR_ARCH`.
- Arch normalisation: `amd64` -> `x86_64`, `armv8l` -> `armv7l`, `aarch64` -> `arm64`.
- Special case: Linux arm64 with version `2020.09.14.2100` is switched to `2020.11.04.2258`.
- Creates `channels-dvr/<version>/` and `channels-dvr/data` (data dir created empty).
- Files fetched into `channels-dvr/<version>/` (names suffixed `-$os-$arch`):
  - `$os-$arch.sha256` (from `$host/$version/$os-$arch.sha256`)
  - `ffmpeg` (`ffmpeg-$os-$arch`), `ffprobe` (`ffprobe-$os-$arch`), `comskip` (`comskip-$os-$arch`), `channels-dvr` (`channels-dvr-$os-$arch`)
  - `ffmpeg-dl` (`ffmpeg-dl-$os-$arch`; failure ignored)
- All files in the version directory are made executable; `channels-dvr/latest` symlink points at the version directory.
- **The sha256 file is downloaded but NOT verified by the script.**
- Final layout to use in the image: executable at `channels-dvr/<version>/channels-dvr`, reachable as `channels-dvr/latest/channels-dvr`. There is no top-level `channels-dvr/channels-dvr` file.

## Install path (when DOWNLOAD_ONLY is unset)
Fetches `https://getchannels.com/dvr/install-$os.sh` and `uninstall-$os.sh` into `channels-dvr/`, runs `install.sh`. Systemd, upstart or init.d setup happens in that OS-specific script (not in setup.sh). Not used in containers.

## Gotchas
- macOS path opens a browser; irrelevant for Linux containers.
- Final messages print `http://dvr-<hostname>:8089/`.
