# syntax=docker/dockerfile:1@sha256:572cebbc2b15e6f84c077742952674889cb63cd5e9b80abdffcbe587b6f19183

# Build stage: the upstream release ships no binaries, so compile from source.
# UNVERIFIED: the ubuntu base is assumed to ship Go in /usr/local/go (plan section 3).
# If it does not, use a pinned golang:<ver> build stage instead.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION
ARG TARGETARCH
USER root
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

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

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
