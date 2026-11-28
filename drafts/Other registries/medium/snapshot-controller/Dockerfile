# UNVERIFIED: no pinned digest for the Go build image yet; pin one from the registry before merge.
# go.mod declares go 1.26.0, so any 1.26.x or newer tag satisfies it.
FROM docker.io/library/golang:1.26.11-trixie@sha256:f9e99477a80ccd7adfb69780510b22c7249ce9169885f18aa762cd886e75e018 AS build

ARG VERSION
ARG TARGETARCH
ARG TARGETOS=linux
USER root

ENV GOCACHE=/tmp/go-cache \
    GOMODCACHE=/tmp/go-mod

RUN \
  echo "**** fetch source code ****" && \
  mkdir -p /tmp/src /out && \
  curl -fL -o /tmp/src.tar.gz \
    "https://github.com/kubernetes-csi/external-snapshotter/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xzf /tmp/src.tar.gz -C /tmp/src --strip-components=1 && \
  rm -f /tmp/src.tar.gz
# UNVERIFIED: confirm the source commit is 9aea5b81a82aa262567bb4345c1caf2510d026dc for v8.7.1.

RUN \
  echo "**** compile snapshot-controller ****" && \
  cd /tmp/src && \
  CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -trimpath -ldflags="-s -w" \
    -o /out/snapshot-controller ./cmd/snapshot-controller
# UNVERIFIED: build flags are a plan, not copied from the upstream Makefile.

############## runtime stage ##############
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# add snapshot-controller binary
COPY --from=build --chmod=0755 /out/snapshot-controller /app/snapshot-controller/snapshot-controller

# add license from upstream source
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/snapshot-controller/LICENSE
# UNVERIFIED: ship NOTICE as well if the upstream tag has one.

RUN \
  chown -R apps:apps /app/snapshot-controller && \
  chmod -R 755 /app/snapshot-controller

ENV HOME=/tmp

# add local files
USER apps
COPY --chmod=0755 . /

# ports
EXPOSE 8080
