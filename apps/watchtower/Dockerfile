FROM ghcr.io/trueforge-org/golang:1.27.4@sha256:a91915f24d7593a9d485df9884eff50dde58df2f49d52da7fd800a6dacaacbfe AS builder

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

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:cdc35c1e179c9ebb98d18ad2f3c3b5ff340fbda5e75ccbd4f022ef7da5885760

ENV WATCHTOWER_LABEL_ENABLE=true

USER apps
COPY --chmod=0755 . /

# copy files from other container
COPY --from=builder /app/watchtower/watchtower /app/watchtower


COPY --chmod=0775 . /

WORKDIR /app
