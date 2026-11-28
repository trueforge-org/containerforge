FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# build variables
ARG VERSION
ARG TARGETARCH
ARG CURL_IMPERSONATE_VERSION=1.0.0rc2
# UNVERIFIED: SHA-512 values were not captured; take them from the upstream Dockerfile at the chosen commit
ARG CURL_IMPERSONATE_SHA512_X86_64=UNVERIFIED
ARG CURL_IMPERSONATE_SHA512_AARCH64=UNVERIFIED
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    nginx \
    patchelf \
    php8.5-cli \
    php8.5-curl \
    php8.5-fpm \
    php8.5-intl \
    php8.5-mbstring \
    php8.5-memcached \
    php8.5-sqlite3 \
    php8.5-xml \
    php8.5-zip && \
  echo "**** fetch rss-bridge source ${VERSION} ****" && \
  mkdir -p /app && \
  curl -fL -o /tmp/rss-bridge.tar.gz \
    "https://github.com/RSS-Bridge/rss-bridge/archive/refs/tags/${VERSION}.tar.gz" && \
  tar -xzf /tmp/rss-bridge.tar.gz -C /app --strip-components=1 && \
  echo "**** install curl-impersonate (chrome131 TLS fingerprint) ****" && \
  case "${TARGETARCH}" in \
    amd64) CI_ARCH="x86_64-linux-gnu"; CI_SHA512="${CURL_IMPERSONATE_SHA512_X86_64}" ;; \
    arm64) CI_ARCH="aarch64-linux-gnu"; CI_SHA512="${CURL_IMPERSONATE_SHA512_AARCH64}" ;; \
    *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  curl -fL -o /tmp/curl-impersonate.tar.gz \
    "https://github.com/lexiforest/curl-impersonate/releases/download/v${CURL_IMPERSONATE_VERSION}/libcurl-impersonate-v${CURL_IMPERSONATE_VERSION}.${CI_ARCH}.tar.gz" && \
  echo "${CI_SHA512}  /tmp/curl-impersonate.tar.gz" | sha512sum -c - && \
  mkdir -p /usr/local/lib/curl-impersonate && \
  tar -xzf /tmp/curl-impersonate.tar.gz -C /usr/local/lib/curl-impersonate && \
  patchelf --set-soname libcurl.so.4 /usr/local/lib/curl-impersonate/libcurl-impersonate.so && \
  echo "**** license files ****" && \
  mkdir -p /usr/share/licenses/rss-bridge && \
  cp /app/LICENSE /usr/share/licenses/rss-bridge/ && \
  echo "**** cleanup ****" && \
  apt-get purge -y patchelf && \
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf /tmp/* /var/lib/apt/lists/* /root/.cache

# rootless layout: /app is read-only at runtime, state lives in /config
RUN \
  chown -R apps:apps /app && \
  ln -sfn /config/config.ini.php /app/config.ini.php && \
  ln -sfn /config/whitelist.txt /app/whitelist.txt

# add local files (nginx and php-fpm configs, start.sh)
USER apps
COPY --chmod=0755 . /

ENV HOME=/tmp \
    LD_PRELOAD=/usr/local/lib/curl-impersonate/libcurl-impersonate.so \
    CURL_IMPERSONATE=chrome131

# ports and volumes
EXPOSE 8080

WORKDIR /app
VOLUME /config
