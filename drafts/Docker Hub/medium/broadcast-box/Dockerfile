
# UNVERIFIED: plan cites ubuntu digest f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a...; 92 apps use f01a4295... (the digest used here).
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS builder

ARG VERSION
ARG TARGETARCH
USER root

# Go and Node ship in the ubuntu base. Build caches go to /tmp.
ENV \
  HOME=/tmp \
  GOCACHE=/tmp/go-build \
  GOPATH=/tmp/go \
  npm_config_cache=/tmp/npm \
  CGO_ENABLED=0

# No upstream checksum is published for the tag archive.
RUN echo "*** Downloading broadcast-box ${VERSION} ***" && \
  mkdir -p /build /out && \
  curl -fsSL -o \
    /tmp/broadcast-box.tar.gz \
    "https://github.com/Glimesh/broadcast-box/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xzf \
    /tmp/broadcast-box.tar.gz -C \
    /build --strip-components=1 && \
  rm /tmp/broadcast-box.tar.gz && \
  echo "*** Building web frontend ***" && \
  cd /build/web && \
  npm install && \
  npm run build && \
  echo "*** Building backend ***" && \
  cd /build && \
  go build -trimpath -o /out/broadcast-box . && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/*

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  APP_ENV=production \
  HOME=/config

COPY --from=builder /out/broadcast-box /app/broadcast-box
COPY --from=builder /build/web/build /app/web/build
COPY --from=builder /build/LICENSE /usr/share/licenses/broadcast-box/LICENSE

RUN echo "*** Setting permissions ***" && \
  chown -R apps:apps /app && chmod -R 755 /app

USER apps
COPY --chmod=0755 . /


# 8080/tcp is HTTP/WHIP/WHEP. 8080/udp is WebRTC media via UDP_MUX_PORT (start.sh default).
EXPOSE 8080
EXPOSE 8080/udp

VOLUME /config
