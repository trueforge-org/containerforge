FROM ghcr.io/trueforge-org/golang:1.26.0@sha256:acbb7d5055789d4e4da6343772b3ce7b6215b13f726252c4dd59f3027f8b6eb1 AS builder

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

FROM ghcr.io/trueforge-org/ubuntu:24.04@sha256:e5507376cb59a4669ad6179bc43e081b150558c96ab8e06b558e3b62c71241c8

ENV WATCHTOWER_LABEL_ENABLE=true

USER apps
COPY container-test.yaml /container-test.yaml

# copy files from other container
COPY --from=builder /app/watchtower/watchtower /app/watchtower


COPY --chmod=0775 . /

WORKDIR /app
