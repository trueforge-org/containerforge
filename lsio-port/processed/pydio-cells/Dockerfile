
FROM ghcr.io/trueforge-org/ubuntu:24.4 as buildstage


ENV \
  HOME="/config" \
  CELLS_WORKING_DIR="/config" \
  GOPATH="/tmp"

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base \
    go \
    openssl && \
  echo "**** fetch source code ****" && \
  mkdir -p \
    /tmp/src/github.com/pydio/cells && \
  if [ -z ${VERSION+x} ]; then \
    VERSION=$(curl -sX GET "https://api.github.com/repos/pydio/cells/releases/latest" \
      | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /tmp/cells-src.tar.gz -L \
    https://github.com/pydio/cells/archive/v${VERSION}.tar.gz && \
  tar xf \
    /tmp/cells-src.tar.gz -C \
    /tmp/src/github.com/pydio/cells --strip-components=1 && \
  echo "**** compile cells  ****" && \
  cd /tmp/src/github.com/pydio/cells && \
  GOARCH=$TARGETARCH GOOS=linux go build -trimpath \
    -ldflags "\
    -X github.com/pydio/cells/v4/common.version=${VERSION:1} \
    -X github.com/pydio/cells/v4/common.BuildStamp=${BUILD_DATE} \
    -X github.com/pydio/cells/v4/common.BuildRevision=v${VERSION}" \
    -o /app/cells -x . && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/* \
    "${HOME}"/.cache \
    "${HOME}"/go

FROM ghcr.io/trueforge-org/ubuntu:24.4

ARG VERSION

ENV \
  HOME="/config" \
  CELLS_WORKING_DIR="/config" \
  GOPATH="/tmp" \
  PATH=/app/:$PATH

RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    openssl && \

COPY --from=buildstage /app/cells /app/

COPY root/ /
