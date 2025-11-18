## TODO: pin version tag
FROM ghcr.io/trueforge-org/node:rolling@sha256:70adf71e6e9d204219ace16d177a96c7b06cc3d881c413eaaa312ed27d13479a

ARG VERSION
ARG TARGETARCH
USER root

ENV RAILS_ENV="production" \
    NODE_ENV="production" \
    RACK_ENV="production" \
    DOCKER_TAG=lscr.io/linuxserver/manyfold:v${VERSION} \
    PORT=3214 \
    RAILS_SERVE_STATIC_FILES=true \
    APP_VERSION=v${VERSION} \
    HOME=/config

RUN \
  apk add --no-cache \
    assimp-dev \
    file \
    gcompat \
    imagemagick \
    imagemagick-heic \
    imagemagick-jpeg \
    imagemagick-webp \
    jemalloc \
    libarchive \
    mariadb-connector-c \
    pciutils \
    postgresql16-client \
    ruby \
    ruby-bundler && \
  apk add --no-cache --virtual=build-dependencies \
    build-base \
    libffi-dev \
    mariadb-dev \
    postgresql-dev \
    ruby-dev \
    yaml-dev && \
  echo "**** install manyfold ****" && \
  mkdir -p /app/www && \
  curl -sX GET "https://api.github.com/repos/manyfold3d/manyfold/git/matching-refs/tags/v${VERSION}" \
    | jq -r '.[].object.sha' > /app/www/GIT_SHA && \
  curl -s -o \
    /tmp/manyfold.tar.gz -L \
    "https://github.com/manyfold3d/manyfold/archive/v${VERSION}.tar.gz" && \
  tar xf \
    /tmp/manyfold.tar.gz -C \
    /app/www/ --strip-components=1 && \
  cd /app/www && \
  npm install -g corepack && \
  corepack enable && \
  yarn install && \
  gem install foreman && \
  RUBY=$(apk list ruby | grep -oP '.*-\K(\d\.\d\.\d)') && \
  sed -i "s/\d.\d.\d/${RUBY}/" .ruby-version && \
  bundle config set --local deployment 'true' && \
  bundle config set --local without 'development test' && \
  bundle config force_ruby_platform true && \
  bundle install && \
  touch db/schema.rb && \
  DATABASE_URL="nulldb://user:pass@localhost/db" \
  SECRET_KEY_BASE="placeholder" \
  APP_VERSION=v${VERSION} \
  bundle exec rake assets:precompile && \
  rm db/schema.rb && \
  echo "**** cleanup ****" && \
  yarn cache clean && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    $HOME/.bundle/cache \
    $HOME/.cache \
    $HOME/.npm \
    $HOME/.yarn \
    /app/www/node_modules/ \
    /app/www/tmp/cache/ \
    /app/www/vendor/bundle/ruby/3.3.0/cache/* \
    /tmp/*

USER apps
COPY . /
COPY ./root /

EXPOSE 3214
