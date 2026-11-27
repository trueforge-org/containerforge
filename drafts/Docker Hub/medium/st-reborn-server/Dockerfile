
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH

ENV HOME=/config

USER root

# Prebuilt release tarball per arch (amd64 and arm64 match TARGETARCH).
# UNVERIFIED: tarball layout (top-level or subdirectory); list the archive at the build round and adjust.
# No upstream checksum is published; record the sha256 per arch at the build round and note it in the PR.
RUN echo "*** Installing SkyrimTogetherServer ${VERSION} ***" && \
  mkdir -p /app/st-server /usr/share/licenses/st-reborn-server && \
  curl -fsSL -o /tmp/st-server.tar.gz \
    "https://github.com/tiltedphoques/TiltedEvolution/releases/download/v${VERSION}/SkyrimTogetherServer-${VERSION}-linux-${TARGETARCH}.tar.gz" && \
  tar -xzf /tmp/st-server.tar.gz -C /app/st-server && \
  rm -f /tmp/st-server.tar.gz && \
  chown -R apps:apps /app && chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

EXPOSE 10578/udp

VOLUME /config
WORKDIR /config
