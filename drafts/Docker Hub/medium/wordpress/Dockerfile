FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# Apache runs as apps on 8080. Its runtime, lock and log dirs go to /tmp, because /run and /var/log are not writable at runtime.
ENV APACHE_RUN_USER=apps \
    APACHE_RUN_GROUP=apps \
    APACHE_RUN_DIR=/tmp/apache2 \
    APACHE_PID_FILE=/tmp/apache2/apache2.pid \
    APACHE_LOCK_DIR=/tmp/apache2 \
    APACHE_LOG_DIR=/tmp/apache2/log \
    TMPDIR=/tmp

# UNVERIFIED: PHP and Apache package names on ubuntu 26.04 beyond the php8.5-* pattern used by apps/bookstack (plan section 4). Drop any that do not exist.
RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    apache2 \
    libapache2-mod-php8.5 \
    php8.5-curl \
    php8.5-gd \
    php8.5-imagick \
    php8.5-intl \
    php8.5-mbstring \
    php8.5-mysql \
    php8.5-opcache \
    php8.5-xml \
    php8.5-zip \
    unzip && \
  echo "**** keep php sessions in /tmp ****" && \
  echo "session.save_path = /tmp" > /etc/php/8.5/apache2/conf.d/99-containerforge.ini && \
  rm -rf /var/lib/apt/lists/*

RUN \
  echo "**** fetch and verify wordpress ****" && \
  mkdir -p /tmp/src /app/www && \
  curl -fL -o /tmp/wordpress.zip \
    "https://downloads.wordpress.org/release/wordpress-${VERSION}.zip" && \
  curl -fL -o /tmp/wordpress.zip.sha1 \
    "https://downloads.wordpress.org/release/wordpress-${VERSION}.zip.sha1" && \
  (cd /tmp && echo "$(cut -d' ' -f1 wordpress.zip.sha1)  wordpress.zip" | sha1sum -c -) && \
  unzip -q /tmp/wordpress.zip -d /tmp/src && \
  cp -a /tmp/src/wordpress/. /app/www/ && \
  echo "**** map writable paths to /config ****" && \
  # The core wp-content is kept as the seed for /config/wp-content (start.sh copies it when that dir is empty).
  mv /app/www/wp-content /app/wordpress-default-content && \
  ln -s /config/wp-content /app/www/wp-content && \
  ln -s /config/wp-config.php /app/www/wp-config.php && \
  echo "**** license ****" && \
  mkdir -p /usr/share/licenses/wordpress && \
  cp /app/www/license.txt /usr/share/licenses/wordpress/LICENSE && \
  chmod -R a+rX /app/www /app/wordpress-default-content && \
  echo "**** cleanup ****" && \
  rm -rf /tmp/* && \
  apt-get clean

RUN <<EOF
set -eux
cat > /etc/apache2/sites-available/wordpress.conf <<'CONF'
<VirtualHost *:8080>
    ServerName localhost
    DocumentRoot /app/www

    <Directory /app/www>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog /dev/stderr
    CustomLog /dev/stdout combined
</VirtualHost>
CONF
a2dissite 000-default
a2ensite wordpress
a2enmod rewrite
sed -i 's/^Listen 80$/Listen 8080/' /etc/apache2/ports.conf
EOF

# copy local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8080
VOLUME /config

WORKDIR /config
