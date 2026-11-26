# Komet/MediaElch README and build docs

**Sources:**
- https://raw.githubusercontent.com/Komet/MediaElch/master/README.md (fetched 2026-11-26)
- Followed: https://mediaelch.github.io/mediaelch-doc/contributing/build/index.html
- Followed: https://mediaelch.github.io/mediaelch-doc/contributing/build/ubuntu_22_04.html

## What it is
- Media manager for Kodi: movies, TV shows, concerts, music; metadata stored as NFO files; fanart from fanart.tv.
- Scrapers: TMDb, Videobuster, TVMaze, fernsehserien.de, IMDb, fanart.tv; music: TheAudioDB, AllMusic, Discogs.

## Build systems / platforms (docs)
- qmake and CMake supported; Qt 5 and Qt 6 supported.
- Platforms: Windows, macOS, Ubuntu 22.04+, openSUSE Leap 15+, openSUSE Tumbleweed, Fedora 36+.
- Docs version 2.12.0.

## Ubuntu 22.04 build steps (qmake; no CMake given)
- apt: build-essential git libcurl4-gnutls-dev (alt: libcurl4-openssl-dev) libmediainfo-dev
- Qt5 (distro): qt5-qmake qtbase5-dev qtbase5-dev-tools qtdeclarative5-dev qtmultimedia5-dev qttools5-dev qttools5-dev-tools libqt5opengl5 libqt5opengl5-dev libqt5svg5 libqt5svg5-dev
- Commands:
  ```
  git clone https://github.com/Komet/MediaElch.git
  cd MediaElch
  git submodule update --init
  mkdir build && cd build
  qmake ..
  make -j4
  sudo make install
  ```
- Install path not stated.

## Runtime deps
- ffmpeg (random screenshots).
- Internet access for scrapers/fanart (implied).

## Not stated
- CLI flags, config/settings paths, license on the doc pages (check repo LICENSE).
- Minimum CMake version, compiler requirements, Qt minimum version.

## Latest release
- See `komet-mediaelch-release.md` (v2.12.0).
