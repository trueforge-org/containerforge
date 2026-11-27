# C4illin/ConvertX Dockerfile (commit 42224e3f1f1ad0eb6e6d2bac661a5b3f2b2a2976)
Source URL(s): https://raw.githubusercontent.com/C4illin/ConvertX/42224e3f1f1ad0eb6e6d2bac661a5b3f2b2a2976/Dockerfile (also github blob URL, fetched 2026-11-27)

## Build stages
- base: `FROM oven/bun:1.4.4-slim`; WORKDIR /app; COPY package.json bun.lock; `bun install --frozen-lockfile`; COPY . .; `bun run build:bin`
- release: `FROM debian:testing-slim`; LABEL org.opencontainers.image.source=https://github.com/C4illin/ConvertX
- test: `FROM release`, copies /usr/local/bin/bun from base.
- default final target: release (last stage `FROM release`).

## Release stage packages (apt, --no-install-recommends)
assimp-utils, ca-certificates, calibre, curl, dasel, dcraw, djvulibre-bin, dvisvgm, ffmpeg, ghostscript, gosu, graphicsmagick, imagemagick-7.q16, inkscape, latexmk, libheif-examples, libjxl-tools, libreoffice, libva2, libvips-tools, libemail-address-perl, libemail-outlook-message-perl, lmodern, mupdf-tools, pandoc, poppler-utils, potrace, python3-numpy, python3-tinycss2, resvg, texlive (+ fonts-recommended, latex-extra, latex-recommended, xetex), python3, python3-pip, pipx.
- pipx install "markitdown[all]" (PIPX_HOME=/opt/pipx, PIPX_BIN_DIR=/usr/local/bin)
- pipx runpip markitdown install --upgrade "Brotli>=1.2.1" "brotlicffi>=1.2.1.0" (commented "Remove when patch is released")

## Users
- `groupadd -g 1000 convertx`; `useradd -u 1000 -g convertx -d /home/convertx -m -s /bin/bash convertx`
- No USER directive in Dockerfile shown (check entrypoint.sh, not fetched; gosu is installed).

## VTracer
- Pinned 0.6.4 from https://github.com/visioncortex/vtracer/releases/download/0.6.4/<asset>
- Assets: vtracer-x86_64-unknown-linux-musl.tar.gz (default) or vtracer-aarch64-unknown-linux-musl.tar.gz (when uname -m = aarch64).
- Extracted to /usr/local/bin/vtracer.

## Paths
- /app/public and /app/convertx (bun compiled binary from dist/convertx).
- `mkdir data` in /app (relative to WORKDIR /app -> /app/data).
- /entrypoint.sh (COPY, chmod +x; not fetched).

## Runtime
- EXPOSE 3000/tcp
- ENV QTWEBENGINE_CHROMIUM_FLAGS="--no-sandbox" (calibre)
- ENV NODE_ENV=production
- ENTRYPOINT ["/entrypoint.sh"]; CMD ["/app/convertx"]

## Gotchas
- Image is very large (calibre, libreoffice, texlive, imagemagick, ffmpeg, inkscape).
- Upstream base builds Bun-compiled binary; runtime is debian:testing-slim, not bun image.
