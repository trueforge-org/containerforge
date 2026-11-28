FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

# repo lives in /config/ipfs; caches and scratch go to /tmp
ENV IPFS_PATH=/config/ipfs \
    HOME=/config

# official kubo release tarball, verified against the upstream .sha512 file
RUN echo "*** Installing kubo ***" && \
  V="${VERSION#v}" && \
  file="kubo_v${V}_linux-${TARGETARCH}.tar.gz" && \
  curl -fsSL -o /tmp/kubo.tar.gz "https://github.com/ipfs/kubo/releases/download/v${V}/${file}" && \
  curl -fsSL -o /tmp/kubo.sha512 "https://github.com/ipfs/kubo/releases/download/v${V}/${file}.sha512" && \
  (cd /tmp && sed "s#  .*#  kubo.tar.gz#" kubo.sha512 | sha512sum -c -) && \
  tar xzf /tmp/kubo.tar.gz -C /tmp && \
  install -m 0755 /tmp/kubo/ipfs /app/ipfs && \
  ln -s /app/ipfs /usr/local/bin/ipfs && \
  echo "*** Installing licenses ***" && \
  mkdir -p /usr/share/licenses/ipfs && \
  cp /tmp/kubo/LICENSE* /usr/share/licenses/ipfs/ && \
  echo "*** Cleaning Up ***" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 4001 4001/udp 5001 8080

VOLUME /config

WORKDIR /config
