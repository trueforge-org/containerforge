FROM ghcr.io/trueforge-org/golang:1.27.1@sha256:b068d80b5f6d257316b4f66ac5b2099f8ebbcd780855da5e80e4bccb3e9b18d8 AS builder

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

FROM ghcr.io/trueforge-org/postgresql-client:9.6.24@sha256:3f2db888d65f642aad283346798bb4eeff542220ee6467e30929ba5aefbfdaff

# set version label
ARG VERSION
ARG TARGETARCH
USER apps

COPY --from=builder /server /app/server
COPY --chmod=0755 . /

EXPOSE 8080
