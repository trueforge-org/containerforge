## TODO: pin version tag
FROM ghcr.io/trueforge-org/golang:rolling@sha256:acbb7d5055789d4e4da6343772b3ce7b6215b13f726252c4dd59f3027f8b6eb1 AS builder

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
FROM ghcr.io/trueforge-org/postgresql-client:rolling@sha256:e1ed0aeb4ecb455b14d1facd73e8ac3896aee97c70d6c09973f2ba8b62906b8d

# set version label
ARG VERSION
ARG TARGETARCH
USER apps
COPY container-test.yaml /container-test.yaml

COPY --from=builder /server /app/server
COPY . /

EXPOSE 8080
