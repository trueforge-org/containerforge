
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config

# Prebuilt release tarball. TARGETARCH (amd64, arm64) matches the asset names.
# UNVERIFIED: no published checksum, and the tarball layout is assumed to hold a single `openobserve` binary.
# UNVERIFIED: the runtime libs (liblzma, zlib, libbz2) that upstream copies from its builder are in the ubuntu base.
RUN echo "*** Installing OpenObserve ${VERSION} ***" && \
  mkdir -p /app && \
  curl -fsSL -o /tmp/openobserve.tar.gz \
    "https://downloads.openobserve.ai/releases/openobserve/${VERSION}/openobserve-${VERSION}-linux-${TARGETARCH}.tar.gz" && \
  tar xzf /tmp/openobserve.tar.gz -C /app/ && \
  rm /tmp/openobserve.tar.gz && \
  mkdir -p /usr/share/licenses/openobserve && \
  curl -fsSL -o /usr/share/licenses/openobserve/LICENSE \
    "https://raw.githubusercontent.com/openobserve/openobserve/${VERSION}/LICENSE" && \
  chown -R apps:apps /app && \
  chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

EXPOSE 5080

VOLUME /config
