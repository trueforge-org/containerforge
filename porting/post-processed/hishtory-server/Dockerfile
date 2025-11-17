## TODO: pin version tag
FROM ghcr.io/trueforge-org/golang:rolling AS builder

RUN \
  apk add --no-cache \
    build-base && \
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
FROM ghcr.io/trueforge-org/postgresql-client:rolling@sha256:ac871d6d14f90a7e95b54edda31ea6117b865e4e93912bf3c69308341e10ee0e

# set version label
ARG VERSION
ARG TARGETARCH

COPY --from=builder /server /app/server
COPY . /

EXPOSE 8080
