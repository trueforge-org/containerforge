FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
USER root

# UNVERIFIED: the Ruby version shipped by ubuntu 26.04 must match the Ruby 3.3 the upstream Gemfile expects.
# Single stage for this first draft; split into a runtime stage once the package set is verified.
ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=1 \
    RAILS_SERVE_STATIC_FILES=TRUE \
    BUNDLE_PATH=/app/vendor/bundle \
    TMPDIR=/tmp \
    HOME=/config

RUN \
  echo "**** install build and runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    git \
    libffi-dev \
    libpq-dev \
    libyaml-dev \
    netcat-openbsd \
    nodejs \
    npm \
    ruby-full && \
  echo "**** install bundler and yarn ****" && \
  gem install bundler --no-document && \
  npm install -g yarn && \
  echo "**** fetch source code ****" && \
  mkdir -p /app && \
  (curl -fL -o \
    /tmp/tracks-src.tar.gz \
    "https://github.com/tracksapp/tracks/archive/refs/tags/v${VERSION}.tar.gz") && \
  tar xf \
    /tmp/tracks-src.tar.gz -C \
    /app --strip-components=1 && \
  echo "**** install gems and precompile assets ****" && \
  cd /app && \
  cp config/database.docker.yml config/database.yml && \
  cp config/site.docker.yml config/site.yml && \
  bundle install --without development test --jobs 4 && \
  SECRET_KEY_BASE=build-only-dummy bundle exec rails assets:precompile && \
  echo "**** make writable paths point at /tmp (app is read-only at runtime) ****" && \
  rm -rf /app/log /app/tmp && \
  ln -s /tmp/log /app/log && \
  ln -s /tmp/rails-tmp /app/tmp && \
  echo "**** cleanup ****" && \
  install -D -m 0644 /app/COPYING /usr/share/licenses/tracks/COPYING && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /root/.cache \
    /root/.npm \
    /var/lib/apt/lists/*

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 3000
VOLUME /config

WORKDIR /app
