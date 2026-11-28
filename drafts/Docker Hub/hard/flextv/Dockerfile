FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# UNVERIFIED: VERSION must be a commit SHA on the default branch. No release or tag exists upstream (see docker-bake.hcl).
ARG VERSION

USER root

# UNVERIFIED: PHP 8.5 and this extension list are guesses. Trim them after the spike (check the source for extension use).
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nginx \
        php8.5-fpm \
        php8.5-cli \
        php8.5-curl \
        php8.5-xml \
        php8.5-mbstring \
        php8.5-zip \
        php8.5-gd && \
    sed -i \
        -e 's|^;\?pid =.*|pid = /tmp/php-fpm.pid|' \
        -e 's|^;\?error_log =.*|error_log = /proc/self/fd/2|' \
        /etc/php/8.5/fpm/php-fpm.conf && \
    sed -i \
        -e 's|^listen = .*|listen = /tmp/php-fpm.sock|' \
        -e '/^listen\.\(owner\|group\|mode\)/d' \
        -e 's|^user = .*|;user = apps|' \
        -e 's|^group = .*|;group = apps|' \
        -e 's|^;\?clear_env =.*|clear_env = no|' \
        /etc/php/8.5/fpm/pool.d/www.conf && \
    printf '%s\n' 'php_admin_value[session.save_path] = /tmp' 'php_admin_value[upload_tmp_dir] = /tmp' >> /etc/php/8.5/fpm/pool.d/www.conf

# Source only: the upstream repository ships no release artifacts. Pinned by commit SHA.
RUN mkdir -p /app/www && \
    curl -fsSL "https://github.com/d8ahazard/FlexTV/archive/${VERSION}.tar.gz" | tar xz -C /app/www --strip-components=1 && \
    rm -rf /app/www/rw /app/www/log /app/www/logs && \
    ln -s /config/rw /app/www/rw && \
    ln -s /config/log /app/www/log && \
    ln -s /config/logs /app/www/logs && \
    mkdir -p /usr/share/licenses/flextv && \
    cp /app/www/license.txt /app/www/gpl.txt /usr/share/licenses/flextv/ && \
    chown -R root:root /app && chmod -R a+rX /app && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

ENV HOME=/config \
    TMPDIR=/tmp

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
WORKDIR /config
CMD ["/start.sh"]
