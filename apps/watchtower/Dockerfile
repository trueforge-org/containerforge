FROM ghcr.io/trueforge-org/golang:rolling@sha256:b4224a2abd8322eafc4c63ea85ad1cf5afe5d7e133d4ef5ee8a5409b4a22ef2a AS builder

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
COPY container-test.yaml /container-test.yaml

# copy files from other container
COPY --from=builder /app/watchtower/watchtower /app/watchtower

HEALTHCHECK CMD [ "/app/watchtower", "--health-check"]

COPY --chmod=0775 . /

WORKDIR /app
