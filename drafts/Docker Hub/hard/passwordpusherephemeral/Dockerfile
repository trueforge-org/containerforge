# The universal image replaces the end-of-support pwpush-ephemeral image. Ephemeral behaviour is SQLite
# with /config not persisted, selected by settings.yaml defaults.
ARG VERSION=2.17.4
ARG RUBY_VERSION=4.0.10

# UNVERIFIED: the digest of the Ruby image is not pinned here; pin it when implementing.
FROM docker.io/library/ruby:${RUBY_VERSION}-slim-trixie AS ruby

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS build

ARG VERSION
ARG RUBY_VERSION

USER root

# Ruby comes from the official image, because Ubuntu 26.04 only ships Ruby 3.3.
COPY --from=ruby /usr/local /usr/local

# UNVERIFIED: build-essential and the -dev package names on Ubuntu 26.04, and node/corepack in the base.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential pkg-config git curl ca-certificates \
        libpq-dev libmariadb-dev libsqlite3-dev libyaml-dev libffi-dev libssl-dev && \
    rm -rf /var/lib/apt/lists/*

RUN corepack prepare yarn@1.22.22 --activate

RUN mkdir -p /app/passwordpusher && \
    curl -fsSL "https://github.com/pglombardo/PasswordPusher/archive/refs/tags/v${VERSION}.tar.gz" \
      | tar xz -C /app/passwordpusher --strip-components=1

WORKDIR /app/passwordpusher

# Bundler settings go in env only, so nothing is written under the app dir. Gems go to vendor/bundle.
ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=true \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_PATH=vendor/bundle \
    HOME=/tmp \
    TMPDIR=/tmp

RUN bundle install && \
    yarn install --frozen-lockfile && \
    SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile && \
    rm -rf tmp/cache tmp/pids tmp/sockets log/* node_modules .github test containers && \
    rm -rf vendor/bundle/ruby/*/cache && \
    rm -rf storage tmp log && \
    ln -s /config/storage storage && \
    ln -s /tmp/pwpush/tmp tmp && \
    ln -s /tmp/pwpush/log log

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG RUBY_VERSION

USER root

COPY --from=ruby /usr/local /usr/local

# UNVERIFIED: runtime library package names on Ubuntu 26.04 (libmariadb3, libssl3t64, libgdbm6t64).
# jemalloc is not used.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        libpq5 libmariadb3 libsqlite3-0 libyaml-0-2 libffi8 libssl3t64 libgdbm6t64 libgmp10 && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /app/passwordpusher /app/passwordpusher

RUN mkdir -p /usr/share/licenses/passwordpusher && \
    cp /app/passwordpusher/LICENSE /usr/share/licenses/passwordpusher/LICENSE

ENV RAILS_ENV=production \
    RACK_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    HTTP_PORT=8080 \
    TARGET_PORT=5100 \
    SOLID_QUEUE_SUPERVISOR_MODE=async \
    HOME=/tmp \
    TMPDIR=/tmp \
    BUNDLE_APP_CONFIG=/tmp/bundle \
    BUNDLE_DEPLOYMENT=true \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_PATH=vendor/bundle

WORKDIR /app/passwordpusher

USER apps
COPY --chmod=0755 . /

EXPOSE 8080 5100

VOLUME /config

CMD ["/start.sh"]
