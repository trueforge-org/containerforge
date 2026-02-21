# Stage 1: Build imaginary binary
FROM ghcr.io/trueforge-org/golang:1.26.0@sha256:12392062fe5039157140f7a2e875b28b40c3b13a033744ab6168708d1d95acf8 as go

ARG VERSION
ARG IMAGINARY_COMMIT=b632dae8cc321452c3f85bcae79c580b1ae1ed84

USER root

RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential \
        pkg-config \
        libvips-dev \
        libjxl-dev \
        libheif-dev \
        libmagickwand-dev \
        poppler-utils; \
    rm -rf /var/lib/apt/lists/*; \
    go install github.com/h2non/imaginary@${IMAGINARY_COMMIT}

# Stage 2: Minimal runtime
FROM ghcr.io/trueforge-org/golang:1.26.0@sha256:12392062fe5039157140f7a2e875b28b40c3b13a033744ab6168708d1d95acf8

USER root

RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libvips42 \
        libjxl0.7 \
        libheif1 \
        imagemagick \
        poppler-utils; \
    rm -rf /var/lib/apt/lists/*

COPY --from=go /config/go/bin/imaginary /usr/local/bin/imaginary

USER apps
COPY --chmod=0755 . /

ENV MALLOC_ARENA_MAX=2

CMD ["imaginary", "-p", "9000"]
