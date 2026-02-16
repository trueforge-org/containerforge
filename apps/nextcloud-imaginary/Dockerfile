# Stage 1: Build imaginary binary
FROM ghcr.io/trueforge-org/golang:1.26.0@sha256:ecb4c82c8be78165ae38c3c7bc1b0e7f5c65255ad79d2b0aa2c83d2084a8424a as go

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
FROM ghcr.io/trueforge-org/golang:1.26.0@sha256:ecb4c82c8be78165ae38c3c7bc1b0e7f5c65255ad79d2b0aa2c83d2084a8424a

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

ENV MALLOC_ARENA_MAX=2

CMD ["imaginary", "-p", "9000"]
