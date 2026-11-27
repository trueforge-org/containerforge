# Initial draft from plan.md. UNVERIFIED items are marked inline.
# Redmine needs a PostgreSQL database to serve pages (plan section 10 decision is still open).

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS build
ARG VERSION
# sha256 of redmine-6.1.6.tar.gz (docker-library REDMINE_DOWNLOAD_SHA256). Bump together with VERSION.
ARG REDMINE_SHA256=a09f0541e3ef5579de8be1c21fc9cabbd7625d77ec4dd2ddddc39ad9c2c5a483
USER root

# Ruby comes from apt (no ContainerForge Ruby base). Package names, including ruby-dev, are UNVERIFIED on 26.04.
RUN apt-get update && apt-get install -y --no-install-recommends \
        bundler \
        build-essential \
        ca-certificates \
        curl \
        libpq-dev \
        libxml2-dev \
        libxslt1-dev \
        libyaml-dev \
        pkgconf \
        ruby \
        ruby-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /tmp/redmine.tar.gz "https://www.redmine.org/releases/redmine-${VERSION}.tar.gz" \
 && echo "${REDMINE_SHA256}  /tmp/redmine.tar.gz" | sha256sum -c - \
 && mkdir -p /app/redmine \
 && tar xzf /tmp/redmine.tar.gz -C /app/redmine --strip-components=1 \
 && rm -f /tmp/redmine.tar.gz

WORKDIR /app/redmine
# Gems are installed inside the app tree so the runtime stage can copy them.
ENV BUNDLE_WITHOUT=development:test \
    BUNDLE_PATH=/app/redmine/vendor/bundle

# Precompiling assets is not done (docker-library does not do it either). Whether 6.1 needs it is UNVERIFIED.
RUN bundle install --jobs "$(nproc)" --retry 3

# Writable paths point at /config (files) or /tmp (logs, pids, generated config). start.sh creates the targets.
# config/database.yml points at a file start.sh writes on every start.
RUN rm -rf files log tmp \
 && ln -s /config/files files \
 && ln -s /tmp/log log \
 && ln -s /tmp/tmp tmp \
 && ln -s /tmp/redmine/database.yml config/database.yml

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454
USER root

# Runtime libraries only. Package names libxml2-16 and libxslt1.1 follow the bazarr sibling; libyaml-0-2 is UNVERIFIED.
RUN apt-get update && apt-get install -y --no-install-recommends \
        bundler \
        ca-certificates \
        libpq5 \
        libxml2-16 \
        libxslt1.1 \
        libyaml-0-2 \
        ruby \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/redmine /app/redmine
COPY --from=build /app/redmine/LICENSE.txt /usr/share/licenses/redmine/LICENSE.txt

ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    HOME=/tmp \
    BUNDLE_APP_CONFIG=/tmp/bundle \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_PATH=/app/redmine/vendor/bundle

COPY --chmod=0755 . /

WORKDIR /app/redmine
EXPOSE 3000
VOLUME /config
USER apps
