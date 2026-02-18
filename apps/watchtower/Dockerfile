FROM ghcr.io/trueforge-org/golang:rolling@sha256:74ea31a8f0af085d1bf920c5b10b75349effddab995cc4c2e2cc401a93b16839 AS builder

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

FROM ghcr.io/trueforge-org/ubuntu:24.04@sha256:a42a7b2fe3c044339769eca34c011337ec5ecdbb7ff3c2af30bc9105afb035b8

ENV WATCHTOWER_LABEL_ENABLE=true

USER apps

# copy files from other container
COPY --from=builder /app/watchtower/watchtower /app/watchtower

HEALTHCHECK CMD [ "/app/watchtower", "--health-check"]

COPY --chmod=0775 . /

WORKDIR /app
