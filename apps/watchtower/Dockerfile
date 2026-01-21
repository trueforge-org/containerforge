FROM ghcr.io/trueforge-org/golang:rolling@sha256:51c610afee97a366fb99ce3f80f69bbbb6b14838430045d742cb03a83d8624e3 AS builder

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

FROM ghcr.io/trueforge-org/ubuntu:24.04@sha256:5e17d35aea5a235316958f3cb7d6c4ea7fb2026199c797d66e4a2b91eef2db51

ENV WATCHTOWER_LABEL_ENABLE=true

USER apps:apps

# copy files from other container
COPY --from=builder /app/watchtower/watchtower /app/watchtower

HEALTHCHECK CMD [ "/app/watchtower", "--health-check"]

COPY --chmod=0775 . /

WORKDIR /app
