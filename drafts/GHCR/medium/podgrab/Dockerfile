
# Build stage. Upstream pins golang:1.15.2, which cannot build go.mod's `go 1.25.0`, so a current Go image is used.
# UNVERIFIED: digest for golang:1.27.4 is not resolved; pin it once confirmed. Debian-based so cgo links against glibc like the runtime.
FROM golang:1.27.4 AS buildstage
ARG VERSION
ARG TARGETARCH
USER root
ENV \
  GOCACHE=/tmp/go-cache \
  GOPATH=/tmp/go \
  GOMODCACHE=/tmp/go/pkg/mod

RUN echo "*** Fetching Podgrab source ***" && \
  mkdir -p /tmp/podgrab && \
  curl -fL -o /tmp/podgrab.tar.gz \
    "https://github.com/akhilrex/podgrab/archive/${VERSION}.tar.gz" && \
  tar xzf /tmp/podgrab.tar.gz -C /tmp/podgrab --strip-components=1 && \
  rm /tmp/podgrab.tar.gz

# UNVERIFIED: cgo is kept on because the sqlite driver is likely cgo-based; check go.mod and set CGO_ENABLED=0 if it is not needed.
RUN echo "*** Building Podgrab ***" && \
  mkdir -p /app/podgrab && \
  cd /tmp/podgrab && \
  CGO_ENABLED=1 GOOS=linux GOARCH=${TARGETARCH} \
    go build -trimpath -ldflags="-s -w" -o /app/podgrab/podgrab ./main.go && \
  cp -r /tmp/podgrab/client /tmp/podgrab/webassets /app/podgrab/ && \
  mkdir -p /usr/share/licenses/podgrab && \
  cp /tmp/podgrab/LICENSE /usr/share/licenses/podgrab/LICENSE && \
  rm -rf /tmp/podgrab

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

USER root

COPY --from=buildstage /app/podgrab/ /app/podgrab/
COPY --from=buildstage /usr/share/licenses/podgrab/ /usr/share/licenses/podgrab/

RUN chown -R apps:apps /app/podgrab && \
  chmod -R 755 /app/podgrab

ENV \
  CONFIG=/config \
  DATA=/config/assets \
  GIN_MODE=release \
  HOME=/config

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

WORKDIR /app/podgrab

VOLUME /config
