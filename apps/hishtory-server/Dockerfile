## TODO: pin version tag
FROM ghcr.io/trueforge-org/golang:rolling@sha256:be0a42e1af759466bd249b5ce04c288e8beab4df14ac634fc9aa6db04bbe8b03 AS builder

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
FROM ghcr.io/trueforge-org/postgresql-client:rolling@sha256:9096db20fdeb452347a1ea16e5dda8a21d6aba03f63b79c2c694f13e72d213b6

# set version label
ARG VERSION
ARG TARGETARCH
USER apps

COPY --from=builder /server /app/server
COPY . /

EXPOSE 8080
