# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
# UNVERIFIED: sha256 of the v1.2.58 source tarball is not in the plan. Fill it in from one download, then the build verifies it.
ARG ARCHIVE_SHA256

USER root

# UNVERIFIED: php8.5-* package names and the PHP version in the 26.04 archive. Check with apt-cache policy first.
# php8.5-mysql is added because upstream ships pdo_mysql, which the plan did not list.
# hadolint ignore=DL3008,DL3015
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        nginx \
        php8.5-fpm \
        php8.5-cli \
        php8.5-bcmath \
        php8.5-curl \
        php8.5-gd \
        php8.5-intl \
        php8.5-ldap \
        php8.5-mbstring \
        php8.5-mysql \
        php8.5-pgsql \
        php8.5-sqlite3 \
        php8.5-xml \
        php8.5-zip \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app/www /defaults && \
    curl -fsSL -o /tmp/kanboard.tar.gz "https://github.com/kanboard/kanboard/archive/refs/tags/${VERSION}.tar.gz" && \
    echo "${ARCHIVE_SHA256}  /tmp/kanboard.tar.gz" | sha256sum -c - && \
    tar xzf /tmp/kanboard.tar.gz -C /app/www --strip-components=1 && \
    rm -f /tmp/kanboard.tar.gz

# Upstream writes data/ and plugins/ inside the app, and the tarball ships both folders. Remove them and link them into /config.
# The targets are created by start.sh, so these links are dangling until the first start. Nothing is written to /app at runtime.
# UNVERIFIED: the config.php link. It assumes Kanboard reads config.php from its own directory at this version.
RUN rm -rf /app/www/docker /app/www/tests /app/www/data /app/www/plugins && \
    ln -s /config/data /app/www/data && \
    ln -s /config/plugins /app/www/plugins && \
    ln -sfn /config/config.php /app/www/config.php && \
    cp /app/www/config.default.php /defaults/config.php && \
    echo "${VERSION}" > /app/www/app/version.txt && \
    install -D /app/www/LICENSE /usr/share/licenses/kanboard/LICENSE && \
    chown -R root:root /app && \
    chmod -R 755 /app && \
    rm -rf /tmp/* /var/tmp/*

USER apps
COPY --chmod=0755 . /

# Port 80 needs root, so the app listens on 8080. The nginx and php-fpm configs live under etc/ and use /tmp for runtime files.
EXPOSE 8080

VOLUME ["/config"]
WORKDIR /config

CMD ["/start.sh"]
