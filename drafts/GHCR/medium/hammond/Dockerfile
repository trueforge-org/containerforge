# NOTE: this is an initial draft. It has not been built. Upstream's Node 16 UI build
# is end-of-life and may fail on the Node version from apt (plan section 10).

# Shared source fetch at the release tag. No checksum is published upstream.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS source

ARG VERSION
USER root
RUN mkdir -p /src && \
    curl -fsSL -o /tmp/hammond-src.tar.gz \
      "https://github.com/AlfHou/hammond/archive/refs/tags/${VERSION}.tar.gz" && \
    tar xzf /tmp/hammond-src.tar.gz -C /src --strip-components=1 && \
    rm -f /tmp/hammond-src.tar.gz

# Go API build stage. The upstream go.mod says go 1.16; the apt toolchain is confirmed in the build log.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS gobuild

USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends golang-go && \
    rm -rf /var/lib/apt/lists/*
ENV GOCACHE=/tmp/go-cache \
    GOMODCACHE=/tmp/go-mod \
    CGO_ENABLED=0

COPY --from=source /src/server /src/server
WORKDIR /src/server
RUN mkdir -p /out && \
    go build -trimpath -ldflags="-s -w" -o /out/app ./main.go && \
    rm -rf /tmp/*

# UI build stage. UNVERIFIED: Node from apt on this base. Upstream used node:16-alpine, which is EOL.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS uibuild

USER root
RUN apt-get update && \
    apt-get install -y --no-install-recommends nodejs npm && \
    rm -rf /var/lib/apt/lists/*
ENV HOME=/tmp \
    npm_config_cache=/tmp/npm

COPY --from=source /src/ui /src/ui
WORKDIR /src/ui
RUN npm install && \
    npm run build && \
    rm -rf /tmp/*

# Final runtime stage.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

COPY --from=gobuild /out/app /app/hammond/app
COPY --from=uibuild /src/ui/dist /app/hammond/dist
COPY --from=source /src/LICENSE /usr/share/licenses/hammond/LICENSE

# Upstream chmod 777 on /config and /assets is replaced by ownership on /config only.
# /app/hammond stays read-only at runtime.
RUN chmod -R 0755 /app/hammond && \
    rm -rf /tmp/* /var/lib/apt/lists/*

# All writes go to /config (CONFIG and DATA are remapped there, see settings.yaml).
ENV HOME=/config \
    CONFIG=/config/config \
    DATA=/config/assets \
    GIN_MODE=release

USER apps
COPY --chmod=0755 . /

EXPOSE 3000

VOLUME /config
WORKDIR /app/hammond
