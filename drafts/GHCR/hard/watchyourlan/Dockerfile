FROM --platform=$BUILDPLATFORM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  GOCACHE=/tmp/go-build \
  GOMODCACHE=/tmp/go-mod

# UNVERIFIED: apt golang-go may be older than the module's go directive in backend/go.mod. Check at first build (pwndrop uses the same apt approach).
RUN echo "*** Installing Go toolchain ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends golang-go && \
  rm -rf /var/lib/apt/lists/*

# Build from the tagged source with CGO disabled, so the binary runs on the ubuntu runtime.
RUN echo "*** Building WatchYourLAN ${VERSION} ***" && \
  mkdir -p /tmp/watchyourlan /out && \
  curl -fsSL -o /tmp/watchyourlan.tar.gz \
    "https://github.com/aceberg/WatchYourLAN/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xzf /tmp/watchyourlan.tar.gz -C /tmp/watchyourlan --strip-components=1 && \
  cd /tmp/watchyourlan/backend && \
  CGO_ENABLED=0 GOOS=linux GOARCH="${TARGETARCH}" \
    go build -ldflags="-w -s" -o /out/WatchYourLAN ./cmd/WatchYourLAN && \
  cp /tmp/watchyourlan/LICENSE /out/LICENSE && \
  rm -rf /tmp/watchyourlan /tmp/watchyourlan.tar.gz /tmp/go-build /tmp/go-mod

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

USER root

ENV \
  HOME=/config

# UNVERIFIED: arp-scan and tzdata are not pinned to a version yet. Pin them at first build (see apps/valkey).
RUN echo "*** Installing runtime packages ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    arp-scan \
    libcap2-bin \
    tzdata && \
  rm -rf /var/lib/apt/lists/*

# UNVERIFIED: lets the non-root user run arp-scan raw-socket scans (plan section 9, option 1). Not tested on this base.
RUN setcap cap_net_raw+ep "$(command -v arp-scan)"

COPY --from=build /out/WatchYourLAN /app/WatchYourLAN
COPY --from=build /out/LICENSE /usr/share/licenses/watchyourlan/LICENSE

RUN chown -R apps:apps /app && chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

EXPOSE 8840

VOLUME /config
