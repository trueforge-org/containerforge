FROM ghcr.io/trueforge-org/golang:1.27.4@sha256:00f64ec10e368246f73dd85badaeb4935861ccebe80107f0681914ae7f62a033 AS builder

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

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:51a8cb185ca9a4d55f1ebff3d3d063ea49262babb5096ddba4a1f5432995ed01

ENV WATCHTOWER_LABEL_ENABLE=true

USER apps
COPY --chmod=0755 . /

# copy files from other container
COPY --from=builder /app/watchtower/watchtower /app/watchtower


COPY --chmod=0775 . /

WORKDIR /app
