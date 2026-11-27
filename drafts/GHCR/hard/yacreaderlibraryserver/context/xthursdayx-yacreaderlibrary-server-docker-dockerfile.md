# xthursdayx/yacreaderlibrary-server-docker (Dockerfile)

Source URL(s) + date: https://raw.githubusercontent.com/xthursdayx/yacreaderlibrary-server-docker/f1d5f1b9e32bc19d6ac06873e071ff67f332388a/Dockerfile (github blob variant same) (fetched 2026-11-27)

## Args
- `DECOMPRESSION_BACKEND="7zip"` (also `libarchive`); `PDF_BACKEND="poppler"` (builder stage).
- `YACR_VERSION="10.4.0"` (bumped by depup workflow); `YACR_REPOSITORY=https://github.com/YACReader/yacreader.git`.

## Build
- Base: `ghcr.io/linuxserver/baseimage-ubuntu:resolute` (Ubuntu 26.04; Jammy not usable: needs CMake >= 3.25, Qt >= 6.4).
- build-env apt: 7zip, build-essential, ca-certificates, cmake, curl, git, libarchive-dev, libgl-dev, libpoppler-qt6-dev, ninja-build, qt6-5compat-dev, qt6-base-dev, qt6-base-dev-tools, qt6-l10n-tools, qt6-tools-dev, qt6-tools-dev-tools.
- source: `git clone --depth 1 --branch ${YACR_VERSION} ${YACR_REPOSITORY} /src`.
- prep-7zip: downloads `https://github.com/YACReader/yacreader-7z-deps/raw/main/7z2301-src.7z` (sha256 pinned), builds `7z.so` (Format7zF), installs to `/app/lib/7zip/7z.so`.
- prep-libarchive: no extra step.
- builder: `cmake -S /src -B /src/build -G Ninja ...` (remaining lines truncated in fetch; build target not fully captured).

## Runtime (final stage, base = linuxserver baseimage-ubuntu:resolute)
- apt: runtime-packages from builder + kimageformat6-plugins, libqt6sql6-sqlite, netcat-openbsd, qt6-image-formats-plugins.
- `COPY --from=builder /app /app`; `COPY root/ /` (s6 overlay service scripts).
- ENV: `APPNAME="YACReaderLibraryServer"`, `HOME="/config"`, `LC_ALL="en_US.UTF-8"`, `PATH="/app/bin:${PATH}"`.
- `EXPOSE 8080`.
- `VOLUME ["/config", "/comics"]`.
- HEALTHCHECK `--interval=30s --timeout=5s --start-period=60s --start-interval=5s --retries=3` `curl -fsS -o /dev/null http://localhost:8080/v2/version`.
- No ENTRYPOINT/CMD in Dockerfile; s6 (from base image) starts the server.

## Labels
- org.opencontainers.image.title/version/source; `com.xthursdayx.yacreader.decompression-backend`.

## Gotchas
- Unarr backend retired; `unarr` tag now points to libarchive image (README).
- Build stage uses `git clone --branch <tag>`; YACReader release tag must exist.
