FROM ghcr.io/trueforge-org/golang:rolling@sha256:ecb4c82c8be78165ae38c3c7bc1b0e7f5c65255ad79d2b0aa2c83d2084a8424a AS builder

USER root

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /app

ARG VERSION

ENV WORKDIR=/app

RUN git clone --branch "${VERSION}" https://github.com/containrrr/watchtower.git

RUN cd watchtower && \
  GO111MODULE=on CGO_ENABLED=0 GOOS=linux go build -a -ldflags "-extldflags '-static' -X github.com/containrrr/watchtower/internal/meta.Version=$(git describe --tags)" . && \
  GO111MODULE=on go test ./... -v && \
  chown -R apps:apps /app && chmod -R 755 /app

FROM ghcr.io/trueforge-org/ubuntu:24.04@sha256:5348eb7725294e8090c15b7b495e517f82f4b31497d3bb9de71bbe37476e7454

ENV WATCHTOWER_LABEL_ENABLE=true

USER apps:apps

# copy files from other container
COPY --from=builder /app/watchtower/watchtower /app/watchtower

HEALTHCHECK CMD [ "/app/watchtower", "--health-check"]

COPY --chmod=0775 . /

WORKDIR /app
