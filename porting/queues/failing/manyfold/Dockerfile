FROM ghcr.io/trueforge-org/node:22.22.0

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
    apt-get update && \
    apt-get install -y --no-install-recommends \
        libassimp-dev \
        file \
        imagemagick \
        libheif-dev \
        libjpeg-dev \
        libwebp-dev \
        libjemalloc-dev \
        libarchive-dev \
        libmariadb3 \
        pciutils \
        postgresql-client \
        ruby \
        bundler && \
    apt-get install -y --no-install-recommends --no-install-suggests \
        build-essential \
        libffi-dev \
        libmariadb-dev \
        libpq-dev \
        ruby-dev \
        libyaml-dev && \
    echo "**** install manyfold ****" && \
    mkdir -p /app/www && \
    (curl -fsSL "https://api.github.com/repos/manyfold3d/manyfold/git/matching-refs/tags/v${VERSION}" | jq -r '.[0].object.sha' > /app/www/GIT_SHA || echo "unknown" > /app/www/GIT_SHA) && \
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
    RUBY=$(ruby -e 'print RUBY_VERSION') && \
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
    apt-get purge -y --auto-remove \
        build-essential \
        libffi-dev \
        libmariadb-dev \
        libpq-dev \
        ruby-dev \
        libyaml-dev && \
    apt-get clean && \
    rm -rf \
        /var/lib/apt/lists/* \
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

WORKDIR /config
VOLUME /config
