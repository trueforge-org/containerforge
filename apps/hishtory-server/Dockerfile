## TODO: pin version tag
FROM ghcr.io/trueforge-org/golang:rolling@sha256:2ba11b36bd37525691b6d9988fe84d59ef36d65a54e0f62b59272dcd67655580 AS builder

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
FROM ghcr.io/trueforge-org/postgresql-client:rolling@sha256:631fb4324c38b66293f0951b7b40171ac892a400293330bc41301e3bbe702296

# set version label
ARG VERSION
ARG TARGETARCH
USER apps

COPY --from=builder /server /app/server
COPY . /

EXPOSE 8080
