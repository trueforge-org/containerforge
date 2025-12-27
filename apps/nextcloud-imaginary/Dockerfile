# Stage 1: Build imaginary binary
FROM ghcr.io/trueforge-org/golang:1.25.1@sha256:b45268d9e708d20793c55803d550b9fc64ecfc000b82ea043712076d913af089 as go

ARG IMAGINARY_COMMIT=b632dae8cc321452c3f85bcae79c580b1ae1ed84

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
FROM ghcr.io/trueforge-org/golang:1.25.1@sha256:b45268d9e708d20793c55803d550b9fc64ecfc000b82ea043712076d913af089

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

COPY --from=go /go/bin/imaginary /usr/local/bin/imaginary

USER 568

ENV MALLOC_ARENA_MAX=2

CMD ["imaginary", "-p", "9000"]
