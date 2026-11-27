# Initial draft from plan.md. Not built or tested.
# UNVERIFIED: node:26 and golang:1.27 digests are not pinned; resolve them before merge.

ARG VERSION="v0.34.0"

############## web UI build ##############
FROM docker.io/library/node:26 AS web
ARG VERSION
ENV NODE_ENV=production \
    npm_config_cache=/tmp/npm

RUN set -eux; \
    mkdir -p /tmp/src; \
    curl -fL -o /tmp/gravity.tar.gz "https://github.com/BeryJu/gravity/archive/refs/tags/${VERSION}.tar.gz"; \
    tar xzf /tmp/gravity.tar.gz -C /tmp/src --strip-components=1; \
    rm -f /tmp/gravity.tar.gz; \
    cd /tmp/src; \
    make web-install; \
    make web-build

############## Go build ##############
FROM docker.io/library/golang:1.27 AS build
ARG VERSION
ARG TARGETARCH

# Build-only tooling for the Makefile resource targets. Not copied to the final image.
# UNVERIFIED: tshark install may need debconf answers in a non-interactive build.
RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tshark; \
    rm -rf /var/lib/apt/lists/*

COPY --from=web /tmp/src /tmp/src
WORKDIR /tmp/src

# UNVERIFIED: these targets download blocklists and iPXE/netboot.xyz files at build time.
RUN set -eux; \
    make internal/resources/macoui internal/resources/blocky internal/resources/tftp

ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=${TARGETARCH} \
    GOCACHE=/tmp/gocache \
    GOPATH=/tmp/gopath

# UNVERIFIED: upstream sets BuildHash from git (GIT_BUILD_HASH). No .git in a tarball, so the tag is used here.
RUN set -eux; \
    go mod download; \
    mkdir -p /tmp/out; \
    go build -trimpath \
      -ldflags "-s -w -X beryju.io/gravity/pkg/extconfig.Version=${VERSION} -X beryju.io/gravity/pkg/extconfig.BuildHash=${VERSION}" \
      -o /tmp/out/gravity ./cmd/server/main

############## runtime ##############
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

USER root

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
      nmap \
      bash-completion \
      ca-certificates; \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /tmp/out/gravity /app/gravity/gravity
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/gravity/LICENSE

# Upstream data path is /data. Point it at the persistent /config volume (start.sh creates /config/data).
RUN set -eux; \
    chmod 0755 /app/gravity/gravity; \
    ln -s /config/data /data

ENV HOME=/config

USER apps
COPY --chmod=0755 . /

EXPOSE 8008

VOLUME /config
WORKDIR /config
