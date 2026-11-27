FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
USER root

RUN echo "*** Installing nginx and PHP ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    nginx \
    php8.5-fpm \
    php8.5-cli \
    php8.5-mysql \
    php8.5-curl \
    php8.5-xml \
    php8.5-mbstring && \
  rm -rf /var/lib/apt/lists/*

# UNVERIFIED: no published checksum for the tag archive; the tag is the only pin.
# UNVERIFIED: the archive ships a LICENSE file at its root.
RUN echo "*** Installing YOURLS ${VERSION} ***" && \
  mkdir -p /app/yourls && \
  curl -fsSL -o /tmp/yourls.tar.gz \
    "https://github.com/YOURLS/YOURLS/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xzf /tmp/yourls.tar.gz -C /app/yourls --strip-components=1 && \
  mv /app/yourls/user /app/yourls-user-default && \
  ln -s /config/yourls/user /app/yourls/user && \
  install -D -m 0644 /app/yourls/LICENSE /usr/share/licenses/yourls/LICENSE && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config

WORKDIR /app/yourls
