FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install portainer ce ****" && \
  mkdir -p /tmp/pt /app && \
  curl -fL -o /tmp/portainer.tar.gz \
    "https://github.com/portainer/portainer/releases/download/${VERSION}/portainer-${VERSION}-linux-${TARGETARCH}.tar.gz" && \
  curl -fL -o /tmp/portainer.checksum.txt \
    "https://github.com/portainer/portainer/releases/download/${VERSION}/portainer-${VERSION}-linux-${TARGETARCH}-checksum.txt" && \
  # UNVERIFIED: checksum .txt layout is assumed to start with the sha256 hash.
  expected_sha=$(awk '{print $1}' /tmp/portainer.checksum.txt | head -n1) && \
  echo "${expected_sha}  /tmp/portainer.tar.gz" | sha256sum -c - && \
  tar xzf /tmp/portainer.tar.gz -C /tmp/pt && \
  # UNVERIFIED: tarball layout (portainer/ top directory with binary, public/, mustache-templates/) is from memory.
  mv /tmp/pt/portainer/portainer /app/portainer && \
  mv /tmp/pt/portainer/public /app/public && \
  mv /tmp/pt/portainer/mustache-templates /app/mustache-templates && \
  echo "**** add license ****" && \
  mkdir -p /usr/share/licenses/portainer && \
  curl -fL -o /usr/share/licenses/portainer/LICENSE \
    "https://raw.githubusercontent.com/portainer/portainer/${VERSION}/LICENSE" && \
  chown -R apps:apps /app && \
  chmod -R 755 /app && \
  rm -rf /tmp/*

ENV HOME=/config \
    XDG_CACHE_HOME=/tmp/cache

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 9000 9443 8000

VOLUME /config
