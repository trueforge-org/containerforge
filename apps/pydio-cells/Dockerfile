FROM ghcr.io/trueforge-org/golang:1.26.0@sha256:66c4ecd659c51f95aabf2632a65685b467d03747b3c2a690604b62ac9229641a as buildstage
USER root

ARG VERSION
ARG TARGETARCH
ARG BUILD_DATE


ENV \
  HOME="/config" \
  CELLS_WORKING_DIR="/config" \
  GOPATH="/tmp"

RUN \
  echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    golang-go \
    openssl && \
  echo "**** fetch source code ****" && \
  mkdir -p \
    /tmp/src/github.com/pydio/cells && \
  (curl -fL -o \
    /tmp/cells-src.tar.gz \
    https://github.com/pydio/cells/archive/v${VERSION}.tar.gz || curl -fL -o \
    /tmp/cells-src.tar.gz \
    https://github.com/pydio/cells/archive/${VERSION}.tar.gz || curl -fL -o \
    /tmp/cells-src.tar.gz \
    https://github.com/pydio/cells/archive/refs/tags/v${VERSION}.tar.gz) && \
  tar xf \
    /tmp/cells-src.tar.gz -C \
    /tmp/src/github.com/pydio/cells --strip-components=1 && \
  echo "**** compile cells  ****" && \
  cd /tmp/src/github.com/pydio/cells && \
  GOARCH=$TARGETARCH GOOS=linux go build -trimpath \
    -ldflags "\
    -X github.com/pydio/cells/v4/common.version=${VERSION} \
    -X github.com/pydio/cells/v4/common.BuildStamp=${BUILD_DATE} \
    -X github.com/pydio/cells/v4/common.BuildRevision=v${VERSION}" \
    -o /app/cells -x . && \
  echo "**** cleanup ****" && \
  apt-get autoremove -y && \
  rm -rf \
    /tmp/* \
    "${HOME}"/.cache \
    "${HOME}"/go

FROM ghcr.io/trueforge-org/ubuntu:24.04@sha256:fdcc4e24cd12eed53bb1338ab6dd5651f5326bcbb98920aa3e8f0c8f5c9b2458

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME="/config" \
  CELLS_WORKING_DIR="/config" \
  GOPATH="/tmp" \
  PATH=/app/:$PATH

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    openssl
COPY --from=buildstage /app/cells /app/

USER apps
COPY --chmod=0755 . /

WORKDIR /config
VOLUME /config
