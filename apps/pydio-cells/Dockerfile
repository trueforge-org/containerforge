FROM ghcr.io/trueforge-org/golang:1.26.4@sha256:6dd40678b06a315906c7f1737e157c0d94fd5b48586b7d058daa39fb18f7bf75 as buildstage
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

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:a79e2182efe0bb3d2abd67d2bd445c8c5e2ecd1722ce0a59a678630ab5a4a80d

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
