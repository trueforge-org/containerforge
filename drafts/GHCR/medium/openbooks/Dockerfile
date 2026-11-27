FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION
ARG TARGETARCH
USER root

# Go and Node come from the ubuntu base (/usr/local/go, /usr/local/bin/node).
# Built from the v${VERSION} tag for both amd64 and arm64: the upstream release has no arm64 binary.
# UNVERIFIED: the web build (server/app) with a current Node is not yet tested; upstream used node:16 (EOL).
# UNVERIFIED: the web asset location that the Go build embeds is assumed; confirm in the probe build.
ENV GOCACHE=/tmp/go-build \
    GOMODCACHE=/tmp/go-mod \
    npm_config_cache=/tmp/npm-cache \
    CGO_ENABLED=0

RUN echo "*** Building OpenBooks ***" && \
    mkdir -p /tmp/src /out/licenses && \
    curl -fL "https://github.com/evan-buss/openbooks/archive/refs/tags/v${VERSION}.tar.gz" | \
        tar xz -C /tmp/src --strip-components=1 && \
    cp /tmp/src/LICENSE /out/licenses/LICENSE && \
    cd /tmp/src/web/server/app && \
    npm ci && \
    npm run build && \
    cd /tmp/src && \
    GOARCH="${TARGETARCH}" go build -o /out/openbooks ./cmd/openbooks && \
    rm -rf /tmp/src /tmp/go-build /tmp/go-mod /tmp/npm-cache /tmp/* /var/tmp/*

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

COPY --from=build /out/openbooks /app/openbooks
COPY --from=build /out/licenses/LICENSE /usr/share/licenses/openbooks/LICENSE

RUN mkdir -p /config && \
    chown -R apps:apps /app /config && \
    chmod 0755 /app/openbooks

ENV HOME=/config \
    BASE_PATH=/

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
