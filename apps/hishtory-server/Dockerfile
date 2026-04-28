FROM ghcr.io/trueforge-org/golang:1.26.2@sha256:ad85bce6a931f436c6e3395e2253e3c6bcc8094c050091ae802d13402bcb625f AS builder

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

FROM ghcr.io/trueforge-org/postgresql-client:9.6.24@sha256:c7ea20fbec42f93e8c45d05676673654dfba12665f63b9dc7020a00e01cff3cc

# set version label
ARG VERSION
ARG TARGETARCH
USER apps

COPY --from=builder /server /app/server
COPY --chmod=0755 . /

EXPOSE 8080
