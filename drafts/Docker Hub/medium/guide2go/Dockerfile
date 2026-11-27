# syntax=docker/dockerfile:1

# Build stage: the upstream release ships no binaries, so compile from source.
# UNVERIFIED: the ubuntu base is assumed to ship Go in /usr/local/go (plan section 3).
# If it does not, use a pinned golang:<ver> build stage instead.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS build

ARG VERSION
ARG TARGETARCH
ENV GOCACHE=/tmp/go-cache \
    GOPATH=/tmp/go \
    CGO_ENABLED=0

# UNVERIFIED: no upstream tarball checksum is published; integrity comes from go.sum.
RUN set -eux; \
    mkdir -p /src /out; \
    curl -fsSL "https://github.com/mar-mei/guide2go/archive/refs/tags/${VERSION}.tar.gz" | tar xz --strip-components=1 -C /src; \
    cd /src; \
    GOOS=linux GOARCH="${TARGETARCH}" go build -trimpath -ldflags="-s -w" -o /out/guide2go .; \
    cp LICENSE /out/LICENSE

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
USER root

ENV HOME=/config

COPY --from=build /out/guide2go /app/guide2go
COPY --from=build /out/LICENSE /usr/share/licenses/guide2go/LICENSE

RUN set -eux; \
    ln -s /app/guide2go /usr/local/bin/guide2go; \
    chown -R root:root /app; \
    chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

# 8080 is only served when Local Images Cache or Proxy Images is enabled in the config.
EXPOSE 8080
VOLUME /config
WORKDIR /config
