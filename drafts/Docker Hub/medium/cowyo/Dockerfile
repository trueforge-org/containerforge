FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS frontend

ARG VERSION
USER root

# UNVERIFIED: frontend layout (web/ and internal/site/build) is from the upstream main Dockerfile, not the v3.0.1 tag.
# UNVERIFIED: Node version in this base (upstream uses node:24).
RUN echo "*** Building cowyo frontend ***" && \
  mkdir -p /tmp/src && \
  curl -fL \
    "https://github.com/schollz/cowyo/archive/refs/tags/v${VERSION}.tar.gz" | \
  tar xz -C /tmp/src --strip-components=1 && \
  cd /tmp/src/web && \
  npm_config_cache=/tmp/npm-cache npm ci && \
  npm_config_cache=/tmp/npm-cache npm run build && \
  rm -rf /tmp/npm-cache

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS build

ARG VERSION
ARG TARGETARCH
USER root

# UNVERIFIED: Go toolchain comes from the ubuntu base (1.27.4 per its bake file); go.mod needs 1.26.5 or newer.
ENV \
  CGO_ENABLED=0 \
  GOOS=linux \
  GOARCH=${TARGETARCH} \
  GOCACHE=/tmp/go-cache \
  GOPATH=/tmp/go

RUN echo "*** Fetching cowyo ${VERSION} ***" && \
  mkdir -p /tmp/src /app/cowyo && \
  curl -fL \
    "https://github.com/schollz/cowyo/archive/refs/tags/v${VERSION}.tar.gz" | \
  tar xz -C /tmp/src --strip-components=1

COPY --from=frontend /tmp/src/internal/site/build /tmp/src/internal/site/build

RUN echo "*** Building cowyo ***" && \
  cd /tmp/src && \
  go build -trimpath -ldflags="-s -w" -o /app/cowyo/cowyo ./cmd/cowyo && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/*

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
USER root

COPY --from=build /app/cowyo/ /app/cowyo/

ENV \
  HOME=/config \
  SQLITE_PATH=/config/cowyo2.sqlite3

USER apps
COPY --chmod=0755 . /

EXPOSE 8001

VOLUME /config

WORKDIR /config
