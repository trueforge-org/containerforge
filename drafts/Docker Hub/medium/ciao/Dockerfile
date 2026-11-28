# syntax=docker/dockerfile:1@sha256:572cebbc2b15e6f84c077742952674889cb63cd5e9b80abdffcbe587b6f19183

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS builder

ARG VERSION
ARG TARGETARCH
USER root

ENV RAILS_ENV=production \
    BUNDLE_WITHOUT=development:test \
    GEM_HOME=/usr/local/bundle \
    BUNDLE_APP_CONFIG=/usr/local/bundle \
    HOME=/tmp

# hadolint ignore=DL3008
# UNVERIFIED: apt Ruby is 3.3, upstream uses 4.0.6; fallback is to copy Ruby 4.0.6 from the official image
RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    libsqlite3-dev \
    libyaml-dev \
    pkg-config \
    ruby \
    ruby-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN \
  echo "**** download ciao ${VERSION} ****" && \
  mkdir -p /app && \
  curl -fsSL "https://github.com/brotandgames/ciao/archive/refs/tags/${VERSION}.tar.gz" \
    | tar -xz -C /app --strip-components=1

WORKDIR /app

# UNVERIFIED: bundler 4.0.16 (from Gemfile.lock BUNDLED WITH) on Ruby 3.3
RUN \
  echo "**** install gems ****" && \
  gem install bundler -v 4.0.16 && \
  bundle config set --local without 'development test' && \
  bundle install --jobs "$(nproc)" --retry 3 && \
  rm -rf /usr/local/bundle/cache/*.gem && \
  find /usr/local/bundle/gems/ -name "*.c" -delete && \
  find /usr/local/bundle/gems/ -name "*.o" -delete

RUN \
  echo "**** precompile assets ****" && \
  SECRET_KEY_BASE=foo bundle exec rake assets:precompile && \
  rm -rf /tmp/* /app/app/assets /app/lib/assets /app/spec /app/tmp/cache /app/vendor/assets

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

# hadolint ignore=DL3008
RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    libsqlite3-0 \
    libyaml-0-2 \
    ruby \
    tzdata && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app

# Make /app read-only friendly: runtime writes go to /config (db) or /tmp (logs, pids, storage)
RUN \
  echo "**** relink writable paths ****" && \
  rm -rf /app/db/sqlite /app/log /app/tmp /app/storage && \
  mkdir -p /app/db && \
  ln -s /config/db /app/db/sqlite && \
  ln -s /tmp/ciao/log /app/log && \
  ln -s /tmp/ciao/tmp /app/tmp && \
  ln -s /tmp/ciao/storage /app/storage && \
  chown -R root:root /app && \
  chmod -R 755 /app && \
  mkdir -p /usr/share/licenses/ciao && \
  cp /app/LICENSE /usr/share/licenses/ciao/

ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    EXECJS_RUNTIME=Disabled \
    GEM_HOME=/usr/local/bundle \
    BUNDLE_WITHOUT=development:test \
    BOOTSNAP_CACHE_DIR=/tmp/bootsnap \
    HOME=/tmp

WORKDIR /app

EXPOSE 3000
VOLUME /config

COPY --chmod=0755 . /

USER apps
