# Build stage: upstream bun base, pinned by version (no digest is recorded in the plan)
ARG BUN_VERSION=1.4.4
FROM oven/bun:${BUN_VERSION}-slim AS build

WORKDIR /app
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile
COPY . .
RUN bun run build:bin

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG VTRACER_VERSION=0.6.4
ARG TARGETARCH

# QTWEBENGINE_CHROMIUM_FLAGS is an upstream calibre flag; keep only if calibre needs it headless (UNVERIFIED)
ENV NODE_ENV=production \
    HOME=/config \
    QTWEBENGINE_CHROMIUM_FLAGS="--no-sandbox" \
    PIPX_HOME=/opt/pipx \
    PIPX_BIN_DIR=/usr/local/bin

USER root

# UNVERIFIED: every package name below is copied from the upstream debian:testing-slim list.
# Ubuntu 26.04 package names and availability are not checked (e.g. imagemagick-7.q16 may be named differently).
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      assimp-utils ca-certificates calibre curl dasel dcraw djvulibre-bin dvisvgm \
      ffmpeg ghostscript gosu graphicsmagick imagemagick-7.q16 inkscape latexmk \
      libheif-examples libjxl-tools libreoffice libva2 libvips-tools \
      libemail-address-perl libemail-outlook-message-perl lmodern mupdf-tools pandoc \
      poppler-utils potrace python3-numpy python3-tinycss2 resvg \
      texlive texlive-fonts-recommended texlive-latex-extra texlive-latex-recommended texlive-xetex \
      python3 python3-pip pipx \
 && rm -rf /var/lib/apt/lists/*

# markitdown via pipx (upstream installs it this way; Brotli upgrade is temporary upstream)
RUN pipx install "markitdown[all]" \
 && pipx runpip markitdown install --upgrade "Brotli>=1.2.1" "brotlicffi>=1.2.1.0"

# VTracer: musl builds only (upstream). UNVERIFIED: runs on glibc ubuntu; tarball layout not inspected.
# UNVERIFIED: no SHA-256 is recorded yet; add the verified checksum before merge.
RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64) vt_arch=x86_64 ;; \
      arm64) vt_arch=aarch64 ;; \
      *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/vtracer.tar.gz \
      "https://github.com/visioncortex/vtracer/releases/download/${VTRACER_VERSION}/vtracer-${vt_arch}-unknown-linux-musl.tar.gz"; \
    tar -xzf /tmp/vtracer.tar.gz -C /usr/local/bin vtracer; \
    chmod 0755 /usr/local/bin/vtracer; \
    rm -f /tmp/vtracer.tar.gz

# Application: compiled binary and static assets
# UNVERIFIED: /app/LICENSE in the upstream repo is assumed, not checked
COPY --from=build /app/dist/convertx /app/convertx
COPY --from=build /app/public /app/public
COPY --from=build /app/LICENSE /usr/share/licenses/convertx/LICENSE

# Upstream writes to ./data under /app. /app is read-only at runtime, so point it at /config.
RUN mkdir -p /usr/share/licenses/convertx \
 && ln -s /config/data /app/data \
 && chown -R root:root /app \
 && chmod -R 755 /app

# run as 568
USER apps
COPY --chmod=0755 . /

EXPOSE 3000
VOLUME ["/config"]
WORKDIR /app
CMD ["/start.sh"]
