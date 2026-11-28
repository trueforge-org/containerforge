# Nginx frontend only. The PHP-FPM half (upstream humhub-phponly, port 9000) is a separate container.
# See plan section 10: this folder is the nginx sidecar, option (a).

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION=1.19.4

ENV COMPOSER_HOME=/tmp/composer \
    npm_config_cache=/tmp/npm

USER root

# UNVERIFIED: PHP extension list. Add the php8.5 modules that HumHub's composer.json requires.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates \
      curl \
      php8.5-cli \
      composer \
      nodejs \
      npm \
 && rm -rf /var/lib/apt/lists/*

# Source archive of the release tag. Upstream publishes no checksum for it.
# UNVERIFIED: sha256 check not added. Record the hash from the tag before shipping and add sha256sum -c here.
RUN mkdir -p /tmp/humhub \
 && curl -fsSL -o /tmp/humhub.tar.gz \
      "https://github.com/humhub/humhub/archive/v${VERSION}.tar.gz" \
 && tar xzf /tmp/humhub.tar.gz -C /tmp/humhub --strip-components=1 \
 && rm -f /tmp/humhub.tar.gz

WORKDIR /tmp/humhub

# UNVERIFIED: npm ci needs a lockfile in the archive; fall back to npm install if there is none.
RUN composer install --no-dev --optimize-autoloader --no-interaction \
 && npm ci \
 && npx grunt build-assets \
 && rm -rf node_modules


FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1

ARG VERSION=1.19.4

USER root

RUN mkdir -p /app/humhub /usr/share/licenses/humhub

# Copy the built tree. nginx needs the PHP files present so try_files can check them.
COPY --from=build /tmp/humhub /app/humhub

# UNVERIFIED: the upstream LICENSE file name and path at the tag.
COPY --from=build /tmp/humhub/LICENSE /usr/share/licenses/humhub/LICENSE

# Writable data lives on /config. Symlink the upstream VOLUME paths to it at build time.
RUN cd /app/humhub/protected \
 && rm -rf uploads config modules \
 && ln -s /config/uploads uploads \
 && ln -s /config/config config \
 && ln -s /config/modules modules \
 && chown -R root:root /app/humhub /usr/share/licenses/humhub \
 && chmod -R 755 /app/humhub /usr/share/licenses/humhub

WORKDIR /app/humhub
VOLUME ["/config"]
EXPOSE 8080

COPY --chmod=0755 . /

USER apps
