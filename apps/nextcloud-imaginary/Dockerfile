# Stage 1: Build imaginary binary
FROM ghcr.io/trueforge-org/golang:1.26.4@sha256:b085b40db77ac1569d4984a86d09906e8aeef4c91407f0dc2ba95b8a5199dc31 as go

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
FROM ghcr.io/trueforge-org/golang:1.26.4@sha256:b085b40db77ac1569d4984a86d09906e8aeef4c91407f0dc2ba95b8a5199dc31

USER root

RUN set -ex; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libvips42t64 \
        libjxl0.11 \
        libheif1 \
        imagemagick \
        poppler-utils; \
    rm -rf /var/lib/apt/lists/*

COPY --from=go /config/go/bin/imaginary /usr/local/bin/imaginary

USER apps
COPY --chmod=0755 . /

ENV MALLOC_ARENA_MAX=2

CMD ["imaginary", "-p", "9000"]
