# Build stage: upstream builder image (tag only). UNVERIFIED: pin the digest before merge.
FROM --platform=$BUILDPLATFORM quay.io/projectquay/golang:1.26 AS build

ARG VERSION
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

RUN set -eux; \
    mkdir -p /src; \
    curl -fL -o /tmp/src.tar.gz "https://github.com/csi-addons/kubernetes-csi-addons/archive/refs/tags/${VERSION}.tar.gz"; \
    tar xzf /tmp/src.tar.gz -C /src --strip-components=1; \
    rm /tmp/src.tar.gz

WORKDIR /src
ENV CGO_ENABLED=0 \
    GOOS=$TARGETOS \
    GOARCH=$TARGETARCH \
    GOCACHE=/tmp/gocache \
    GOMODCACHE=/tmp/gomod

# UNVERIFIED: LDFLAGS and the build line against the Makefile at the tagged version.
RUN set -eux; \
    if [ "${TARGETVARIANT:-}" = "v7" ]; then export GOARM=7; fi; \
    mkdir -p /out; \
    go build -ldflags "-s -w" -a -o /out/csi-addons-manager cmd/manager/main.go

# Final stage
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

COPY --from=build --chmod=0755 /out/csi-addons-manager /app/csi-addons-manager
COPY --from=build /src/LICENSE /usr/share/licenses/csi-addons-controller/LICENSE

ENV HOME=/tmp

USER apps
COPY --chmod=0755 . /

# Metrics (8080) and health probes (8081), from the chart's manager arguments.
EXPOSE 8080 8081
