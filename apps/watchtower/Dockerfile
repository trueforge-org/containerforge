FROM ghcr.io/trueforge-org/golang:1.26.2@sha256:4c7fe67fee3c86649d2d42485dfb9202a2667d34eaf2c9d009b1e755a61d444c AS builder

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

FROM ghcr.io/trueforge-org/ubuntu:24.04@sha256:01cc09f895d289305f12087ced3d9b01ad74ec5e958384d3274a7caa87a94c37

ENV WATCHTOWER_LABEL_ENABLE=true

USER apps
COPY --chmod=0755 . /

# copy files from other container
COPY --from=builder /app/watchtower/watchtower /app/watchtower


COPY --chmod=0775 . /

WORKDIR /app
