FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

# set version label
ARG VERSION
# UNVERIFIED: no upstream checksum is published; pin on first download (trust-on-first-use)
ARG SHLINK_SHA256=""
ARG SHLINK_RUNTIME=rr
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    php8.5-cli \
    php8.5-pgsql \
    php8.5-sqlite3 \
    php8.5-intl \
    php8.5-bcmath \
    php8.5-zip \
    php8.5-mbstring \
    php8.5-xml \
    php8.5-curl \
    unzip && \
  echo "**** fetch shlink ****" && \
  curl -fL -o \
    /tmp/shlink.zip \
    "https://github.com/shlinkio/shlink/releases/download/v${VERSION}/shlink${VERSION}_php8.5_dist.zip" && \
  echo "${SHLINK_SHA256}  /tmp/shlink.zip" | sha256sum -c - && \
  mkdir -p /app/shlink && \
  unzip -q /tmp/shlink.zip -d /app/shlink && \
  echo "**** fetch roadrunner when the zip does not ship it ****" && \
  if [ "${SHLINK_RUNTIME}" = "rr" ] && [ ! -x /app/shlink/bin/rr ]; then \
    cd /app/shlink && \
    php vendor/bin/rr get --no-interaction --no-config --location bin/ && \
    chmod +x bin/rr; \
  fi && \
  test -f /app/shlink/vendor/autoload.php && \
  echo "**** link data to config ****" && \
  rm -rf /app/shlink/data && \
  ln -s /config/data /app/shlink/data && \
  echo "**** license ****" && \
  if [ -f /app/shlink/LICENSE ]; then \
    install -D /app/shlink/LICENSE /usr/share/licenses/shlink/LICENSE; \
  fi && \
  echo "**** cleanup ****" && \
  chown -R apps:apps /app/shlink && \
  chmod -R 755 /app/shlink && \
  rm -rf \
    /tmp/* \
    $HOME/.cache \
    $HOME/.composer && \
  rm -rf /var/lib/apt/lists/*

# copy local files
USER apps
COPY --chmod=0755 . /

ENV SHLINK_RUNTIME=${SHLINK_RUNTIME} \
    PORT=8080 \
    TZ=Etc/UTC

# ports and volumes
EXPOSE 8080
VOLUME /config

WORKDIR /app/shlink
