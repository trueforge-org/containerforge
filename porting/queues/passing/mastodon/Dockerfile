FROM ghcr.io/trueforge-org/node:22.22.0

ARG VERSION
ARG TARGETARCH
USER root

ENV RAILS_ENV="production" \
    NODE_ENV="production" \
    PATH="${PATH}:/app/www/bin" \
    S6_STAGE2_HOOK="/init-hook" \
    MASTODON_USE_LIBVIPS="true"

RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg \
        file \
        libpq5 \
        libidn12 \
        ruby \
        bundler \
        rdoc \
        libvips \
        libheif1 \
        libyaml-0-2 && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libidn-dev \
        libpq-dev \
        libxml2-dev \
        libxslt1-dev \
        linux-headers-generic \
        libssl-dev \
        ruby-dev \
        libvips-dev \
        libyaml-dev && \
    echo "**** install mastodon ****" && \
    mkdir -p /app/www && \
    (curl -fsL -o \
        /tmp/mastodon.tar.gz \
        "https://github.com/mastodon/mastodon/archive/refs/tags/v${VERSION}.tar.gz" || curl -fsL -o \
        /tmp/mastodon.tar.gz \
        "https://github.com/mastodon/mastodon/archive/refs/tags/${VERSION}.tar.gz") && \
    tar xf \
        /tmp/mastodon.tar.gz -C \
        /app/www/ --strip-components=1 && \
    cd /app/www && \
    bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test exclude' && \
    bundle config set silence_root_warning true && \
    bundle install -j"$(nproc)" --no-cache && \
    npm install -g corepack && \
    corepack enable && \
    yarn workspaces focus --production @mastodon/mastodon && \
    ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=precompile_placeholder \
    ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=precompile_placeholder \
    ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=precompile_placeholder \
    OTP_SECRET=precompile_placeholder \
    SECRET_KEY_BASE=precompile_placeholder \
    bundle exec rails assets:precompile && \
    bundle exec bootsnap precompile --gemfile app/ lib/ && \
    rm -rf /app/www/node_modules && \
    cd streaming && \
    yarn workspaces focus --production @mastodon/streaming && \
    echo "**** cleanup ****" && \
    yarn cache clean && \
    apt-get purge -y --auto-remove \
        build-essential \
        libidn-dev \
        libpq-dev \
        libxml2-dev \
        libxslt1-dev \
        linux-headers-generic \
        libssl-dev \
        ruby-dev \
        libvips-dev \
        libyaml-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    # Remove assets not needed in runtime because they were compiled & copied to public
    rm -r \
        /app/www/app/javascript/fonts \
        /app/www/app/javascript/icons \
        /app/www/app/javascript/styles && \
    rm -rf \
        # Remove vendored sources for building native extensions.
        /app/www/vendor/bundle/ruby/*/gems/hiredis-*/vendor/hiredis \
        /app/www/vendor/bundle/ruby/*/gems/nokogiri-*/gumbo-parser \
        /app/www/vendor/bundle/ruby/*/gems/nokogiri-*/patches \
        /app/www/vendor/bundle/ruby/*/gems/pghero-*/app/assets \
        # Remove build logs, temp files, and cache.
        /app/www/vendor/bundle/ruby/*/build_info/ \
        /app/www/vendor/bundle/ruby/*/cache/ \
        /app/www/tmp/cache \
        $HOME/.bundle/cache \
        $HOME/.composer \
        /tmp/* && \
    find /app/www/vendor/bundle/ruby/*/extensions/ \( -name gem_make.out -o -name mkmf.log \) -delete && \
    # Remove tests, documentations and other useless files.
    find /app/www/vendor/bundle/ruby/*/gems/ \( -name 'doc' \
        -o -name 'spec' \
        -o -name 'test' \) \
        -type d -maxdepth 2 -exec rm -fr "{}" + && \
    find /app/www/vendor/bundle/ruby/*/gems/ \( -name 'README*' \
        -o -name 'CHANGELOG*' \
        -o -name 'CONTRIBUT*' \
        -o -name '*LICENSE*' \
        -o -name 'Rakefile' \
        -o -name '.*' \) \
        -type f -delete

USER apps
COPY --chmod=0755 . /
COPY ./root /

EXPOSE 80 443

VOLUME /config

WORKDIR /config
