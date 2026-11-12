FROM ghcr.io/trueforge-org/golang:1.27.4@sha256:a91915f24d7593a9d485df9884eff50dde58df2f49d52da7fd800a6dacaacbfe AS builder

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

FROM ghcr.io/trueforge-org/postgresql-client:18.6.0@sha256:7c1565c07970e1cf3a5090b78204e282fa5a8857bec00d472c4b3ec72666d7b4

# set version label
ARG VERSION
ARG TARGETARCH
USER apps

COPY --from=builder /server /app/server
COPY --chmod=0755 . /

EXPOSE 8080
