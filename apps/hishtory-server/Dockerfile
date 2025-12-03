## TODO: pin version tag
FROM ghcr.io/trueforge-org/golang:rolling@sha256:b39c7038a39d0ca7a495190d14c78e8445e301edc9736010e5a793705deddfa9 AS builder

ARG TARGETARCH
ARG VERSION
USER root

RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential python3 && \
    rm -rf /var/lib/apt/lists/* && \
  curl -s -o \
    /tmp/hishtory.tar.gz -L \
    "https://github.com/ddworken/hishtory/archive/v${VERSION}.tar.gz" && \
  mkdir -p /build/hishtory && \
  tar xf \
    /tmp/hishtory.tar.gz -C \
    /build/hishtory/ --strip-components=1 && \
  cd /build/hishtory && \
  unset GOPATH; go mod download && \
  unset GOPATH; go build -o /server -ldflags "-X main.ReleaseVersion=v0.`cat VERSION`" backend/server/server.go

## TODO: change to an actual tag when this has an actual tag.
FROM ghcr.io/trueforge-org/postgresql-client:rolling@sha256:239304ba289d2766baca8ed08bead9120df1766f0c488f5d2a9fb8fdbc5a23f9

# set version label
ARG VERSION
ARG TARGETARCH
USER apps

COPY --from=builder /server /app/server
COPY . /

EXPOSE 8080
