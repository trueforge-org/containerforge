# NOTE: this is an initial draft. Several build steps are UNVERIFIED (see plan.md
# sections 3, 4 and 10). It has not been built.

# Stage 1: dlib model files used by the recognizer.
# UNVERIFIED: the download URLs live in the fork's Dockerfile (lines 2-11, not reviewed).
# Copy them here together with any published checksums; none are invented.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS recognizer-models

USER root
RUN mkdir -p /opt/recognizer/models
# TODO(UNVERIFIED): fetch shape_predictor_5/68 landmarks, dlib resnet and mmod detector
# models here, verify them, then bunzip2 them into /opt/recognizer/models.

# Stage 2: recognizer binary (Go + dlib via go-face). A Go build stage, copied out with COPY --from.
# UNVERIFIED: golang:1.20-buster is the fork's pin; confirm it still builds (plan section 4, step 1).
FROM golang:1.20-buster@sha256:eb3f9ac805435c1b2c965d63ce460988e1000058e1f67881324746362baf9572 AS recognizer

ARG VERSION
ENV GOCACHE=/tmp/go-cache
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      libdlib-dev libblas-dev liblapack-dev libatlas-base-dev \
      libjpeg62-turbo-dev gfortran && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /src /out && \
    curl -fsSL -o /tmp/src.tgz "https://github.com/skrashevich/double-take/archive/refs/tags/v${VERSION}.tar.gz" && \
    tar xzf /tmp/src.tgz -C /src --strip-components=1 && \
    rm -f /tmp/src.tgz
# UNVERIFIED: the recognizer package path inside the repo. Adjust once the fork layout is read.
WORKDIR /src/recognizer
RUN CGO_ENABLED=1 go build -o /out/recognizer .

# Stage 3: Node API and frontend. Native modules (better-sqlite3 8.x, canvas 2.11) need Node 16.
# UNVERIFIED: node:16 is not a ContainerForge base. The plan's spike decides the final approach.
FROM node:16-bullseye-slim AS api

ARG VERSION
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential python3 ccache \
      libcairo2-dev libpango1.0-dev libjpeg-dev libgif-dev librsvg2-dev && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /double-take && \
    curl -fsSL -o /tmp/src.tgz "https://github.com/skrashevich/double-take/archive/refs/tags/v${VERSION}.tar.gz" && \
    tar xzf /tmp/src.tgz -C /double-take --strip-components=1 && \
    rm -f /tmp/src.tgz

WORKDIR /double-take/api
RUN npm install && \
    npm cache clean --force

# Stage 4: frontend (Vue). UNVERIFIED: upstream uses bun; the tag below is a placeholder pin.
FROM oven/bun@sha256:3aa040e5445efa09d75bb428a64ba50db13e2b3ac9b6b0c7f145615f62b2ee18 AS frontend

ARG VERSION
RUN mkdir -p /src && \
    apt-get update && apt-get install -y --no-install-recommends curl ca-certificates && \
    curl -fsSL -o /tmp/src.tgz "https://github.com/skrashevich/double-take/archive/refs/tags/v${VERSION}.tar.gz" && \
    tar xzf /tmp/src.tgz -C /src --strip-components=1 && \
    rm -f /tmp/src.tgz
WORKDIR /src/frontend
RUN bun install --frozen-lockfile && bun run -b build

# Final runtime stage.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# Runtime libraries for canvas. UNVERIFIED package names on this base.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      libcairo2 libpango-1.0-0 libjpeg62-turbo libgif7 librsvg2-2 && \
    rm -rf /var/lib/apt/lists/*

ENV NODE_ENV=production \
    CONFIG_PATH=/config/storage/config

COPY --from=api /double-take /double-take
COPY --from=frontend /src/frontend/dist /double-take/frontend/dist
COPY --from=recognizer /out/recognizer /usr/local/bin/recognizer
COPY --from=recognizer-models /opt/recognizer/models /opt/recognizer/models

# Upstream creates /.storage and links it into the app root. Keep that link, but
# point it at the persistent volume so nothing writes outside /config.
RUN ln -s /config/storage /double-take/.storage && \
    rm -rf /tmp/* /var/lib/apt/lists/*

USER apps
COPY --chmod=0755 . /

EXPOSE 3000

VOLUME /config
WORKDIR /double-take
