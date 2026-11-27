
# UNVERIFIED: the nginx base digest comes from plan.md section 3; confirm it on ghcr.io before the first build.
FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:1e4f20bfcf614853820179bb28127b1375061c09f565bb7010495845d4742c9f

ARG VERSION
USER root

# UNVERIFIED: the PHP extension list (curl, SQLite, MySQL, xml, mbstring); confirm with grep over the sources.
RUN echo "*** Installing PHP and gettext ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    gettext \
    php8.5-cli \
    php8.5-curl \
    php8.5-fpm \
    php8.5-mbstring \
    php8.5-mysql \
    php8.5-sqlite3 \
    php8.5-xml && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN echo "*** Fetching TasmoBackup ${VERSION} ***" && \
  curl -fL -o /tmp/tasmobackup.tar.gz \
    "https://github.com/danmed/TasmoBackupV1/archive/refs/tags/${VERSION}.tar.gz" && \
  mkdir -p /app/www && \
  tar -xzf /tmp/tasmobackup.tar.gz -C /app/www --strip-components=1 && \
  rm -rf /app/www/HA_addon /app/www/install.sh /app/www/docker-compose.yml /app/www/tests /app/www/.git* && \
  echo "*** Compiling translations and compressing static assets ***" && \
  for po in /app/www/locale/*/LC_MESSAGES/*.po; do msgfmt -o "${po%.po}.mo" "$po"; done && \
  find /app/www/resources -maxdepth 1 \( -name '*.js' -o -name '*.css' \) -exec gzip -k -9 {} \; && \
  echo "*** Redirect the data dir to /config ***" && \
  rm -rf /app/www/data && \
  ln -s /config/data /app/www/data && \
  install -D /app/www/LICENSE /usr/share/licenses/tasmobackup/LICENSE && \
  chmod -R a+rX /app && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config

CMD ["/start.sh"]
