FROM ghcr.io/trueforge-org/golang:1.26.4@sha256:6dd40678b06a315906c7f1737e157c0d94fd5b48586b7d058daa39fb18f7bf75 AS builder

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

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:a79e2182efe0bb3d2abd67d2bd445c8c5e2ecd1722ce0a59a678630ab5a4a80d

ENV WATCHTOWER_LABEL_ENABLE=true

USER apps
COPY --chmod=0755 . /

# copy files from other container
COPY --from=builder /app/watchtower/watchtower /app/watchtower


COPY --chmod=0775 . /

WORKDIR /app
