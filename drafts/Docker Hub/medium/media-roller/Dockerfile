# syntax=docker/dockerfile:1@sha256:572cebbc2b15e6f84c077742952674889cb63cd5e9b80abdffcbe587b6f19183

# Build stage: the Go binary is built from the pinned upstream commit (no releases or tags exist).
# UNVERIFIED: pin golang:1.27.4 by digest before merge (docker buildx imagetools inspect).
FROM golang:1.27.4@sha256:5f1b98fa02fe396ebce2a0227a0e08309e11792915b9dd2e1f71053d7e7e6666 AS build

ARG VERSION
ENV GOCACHE=/tmp/go-cache \
    GOMODCACHE=/tmp/go-mod

# UNVERIFIED: no upstream checksum is published for the commit tarball. Pin its sha256 after the first download.
RUN set -eux; \
    mkdir -p /tmp/src /tmp/build; \
    curl -fsSL -o /tmp/src.tar.gz "https://github.com/rroller/media-roller/archive/${VERSION}.tar.gz"; \
    tar xzf /tmp/src.tar.gz -C /tmp/src --strip-components=1; \
    cd /tmp/src; \
    go mod download; \
    go build -o /tmp/build/media-roller ./src

# Python base provides python3 and pip on the same ubuntu userland (yt-dlp needs python3).
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG YTDLP_VERSION=2026.11.23
# Checksum of the yt-dlp zipapp for YTDLP_VERSION, from the release SHA2-256SUMS file.
ARG YTDLP_SHA256=e8665ed64d6b9172773e812f891fb707a0cb1ee8d9ef4fc1acb00cabee4c5256
USER root

ENV MR_DOWNLOAD_DIR=/config/download \
    TMPDIR=/tmp \
    XDG_CACHE_HOME=/tmp/cache \
    DENO_DIR=/tmp/deno

# ffmpeg from the distro. Upstream uses a static build from mwader/static-ffmpeg; not used here.
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ffmpeg; \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /tmp/build/media-roller /app/media-roller
COPY --from=build /tmp/src/templates /app/templates
COPY --from=build /tmp/src/static /app/static

# yt-dlp pinned zipapp. The upstream "--update --update-to nightly" step is dropped because /app is read-only.
# Bumping YTDLP_VERSION also needs YTDLP_SHA256.
# UNVERIFIED: the yt-dlp-ejs plugin and curl_cffi from upstream are not installed yet; check whether yt-dlp needs them.
# TODO (UNVERIFIED): deno is needed for yt-dlp JS challenges. Its version and checksum are not pinned yet.
RUN set -eux; \
    curl -fsSL -o /usr/local/bin/yt-dlp "https://github.com/yt-dlp/yt-dlp/releases/download/${YTDLP_VERSION}/yt-dlp"; \
    echo "${YTDLP_SHA256}  /usr/local/bin/yt-dlp" | sha256sum -c -; \
    chmod 0755 /usr/local/bin/yt-dlp

RUN set -eux; \
    chown -R root:root /app; \
    chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

WORKDIR /config
VOLUME /config
