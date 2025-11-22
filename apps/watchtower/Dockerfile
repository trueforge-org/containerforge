FROM ghcr.io/trueforge-org/golang:rolling AS builder

USER root

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /app

ARG VERSION

ENV WORKDIR=/app

RUN git clone --branch "${WATCHTOWER_VERSION}" https://github.com/containrrr/watchtower.git

RUN cd watchtower && \
  GO111MODULE=on CGO_ENABLED=0 GOOS=linux go build -a -ldflags "-extldflags '-static' -X github.com/containrrr/watchtower/internal/meta.Version=$(git describe --tags)" . && \
  GO111MODULE=on go test ./... -v && \
  chown -R apps:apps /app && chmod -R 755 /app

FROM ghcr.io/trueforge-org/ubuntu:24.04

USER apps:apps

# copy files from other container
COPY --from=builder /app/watchtower/watchtower /app/watchtower

HEALTHCHECK CMD [ "/watchtower", "--health-check"]

COPY --chmod=0775 . /

WORKDIR /app
