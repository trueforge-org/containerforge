
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
USER root

# Upstream ships no Dockerfile. Its only reference script (deploy/docker/ubuntu-pts-docker-build.sh)
# installs unzip, php-cli, php-xml, git, mesa-utils and sudo. The rest of this list is inferred (UNVERIFIED).
# PTS cannot install its own system packages rootless, so build dependencies are baked in here.
RUN echo "*** Installing PHP and build tooling for Phoronix Test Suite ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    autoconf \
    git \
    php-cli \
    php-curl \
    php-gd \
    php-xml \
    php-zip \
    unzip && \
  rm -rf /var/lib/apt/lists/*

ENV \
  HOME=/config \
  PTS_USER_PATH_OVERRIDE=/config/pts \
  PTS_DOWNLOAD_CACHE_OVERRIDE=/config/download-cache \
  TMPDIR=/tmp

# No checksum is published on the release. UNVERIFIED: record a sha256 here after the first download.
RUN echo "*** Installing Phoronix Test Suite ${VERSION} ***" && \
  curl -fL -o \
    /tmp/phoronix-test-suite.tar.gz \
    "https://github.com/phoronix-test-suite/phoronix-test-suite/releases/download/v${VERSION}/phoronix-test-suite-${VERSION}.tar.gz" && \
  mkdir -p /app && \
  tar xzf \
    /tmp/phoronix-test-suite.tar.gz -C \
    /app --strip-components=1 && \
  mkdir -p /usr/share/licenses/phoronix-test-suite && \
  cp /app/COPYING /usr/share/licenses/phoronix-test-suite/COPYING && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -f /tmp/phoronix-test-suite.tar.gz

USER apps
COPY --chmod=0755 . /

VOLUME /config
