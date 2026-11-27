FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    php8.5-cli \
    php8.5-curl \
    unzip && \
  echo "**** fetch cryptofolio ****" && \
  mkdir -p /app/cryptofolio /tmp/cryptofolio && \
  curl -fL -o /tmp/cryptofolio/app.zip \
    "https://github.com/Xtrendence/Cryptofolio/releases/download/${VERSION}/API-And-Website.zip" && \
  curl -fL -o /tmp/cryptofolio/src.zip \
    "https://github.com/Xtrendence/Cryptofolio/archive/refs/tags/${VERSION}.zip" && \
  unzip -q /tmp/cryptofolio/app.zip -d /app/cryptofolio && \
  mkdir -p /usr/share/licenses/cryptofolio && \
  unzip -q -j /tmp/cryptofolio/src.zip '*/LICENSE.md' -d /usr/share/licenses/cryptofolio && \
  echo "**** map writable data to /config ****" && \
  rm -rf /app/cryptofolio/api/data && \
  ln -s /config/data /app/cryptofolio/api/data && \
  # UNVERIFIED: upstream Apache maps /api/ to api/ (Alias in apache/000-default.conf). php -S only serves the docroot, so expose api/ inside website/.
  ln -s /app/cryptofolio/api /app/cryptofolio/website/api && \
  chown -R apps:apps /app/cryptofolio && \
  chmod -R 755 /app/cryptofolio && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# copy local files
USER apps
COPY --chmod=0755 . /

ENV HOME=/config TZ=Etc/UTC

# ports and volumes
EXPOSE 80
VOLUME /config

WORKDIR /config
