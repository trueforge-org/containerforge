# Build stage: Go compiles here and only the static binary is copied.
# UNVERIFIED: no digest pinned yet for the Go image; go.mod needs go 1.26.3, so check the tag provides it.
FROM golang:1.27@sha256:5f1b98fa02fe396ebce2a0227a0e08309e11792915b9dd2e1f71053d7e7e6666 AS buildstage

# set version label
ARG VERSION

ENV GOCACHE=/tmp/go-cache \
    GOMODCACHE=/tmp/go-mod

RUN \
  echo "**** fetch source code ****" && \
  mkdir -p /tmp/gatus /app/gatus && \
  curl -fL -o /tmp/gatus-src.tar.gz \
    "https://github.com/TwiN/gatus/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xzf /tmp/gatus-src.tar.gz -C /tmp/gatus --strip-components=1 && \
  echo "**** compile gatus ****" && \
  cd /tmp/gatus && \
  CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /app/gatus/gatus . && \
  echo "**** license ****" && \
  install -D /tmp/gatus/LICENSE /usr/share/licenses/gatus/LICENSE && \
  echo "**** cleanup ****" && \
  rm -rf /tmp/*

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# add gatus binary and license
COPY --from=buildstage /app/gatus /app/gatus
COPY --from=buildstage /usr/share/licenses/gatus /usr/share/licenses/gatus

ENV GATUS_LOG_LEVEL=INFO

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8080
VOLUME /config

WORKDIR /config
