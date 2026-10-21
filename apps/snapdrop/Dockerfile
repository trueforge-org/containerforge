FROM ghcr.io/trueforge-org/node:24.22.1@sha256:7b7273ef83088a8ce734cd4933fe3ab1c1faf478173d2d04cb3a22ea1e7a3bf7

# set version label
ARG VERSION
ARG TARGETARCH
USER root
ARG SNAPDROP_RELEASE

# environment settings
ENV HOME="/app"
ENV NODE_ENV="production"

RUN \
  echo "**** install snapdrop ****" && \
  mkdir -p /app/www && \
  if [ -z ${SNAPDROP_RELEASE} ]; then \
    SNAPDROP_RELEASE=$(curl -sX GET "https://api.github.com/repos/snapdrop/snapdrop/commits/master" \
    | awk '/sha/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /tmp/snapdrop.tar.gz -L \
    "https://github.com/snapdrop/snapdrop/archive/${SNAPDROP_RELEASE}.tar.gz" && \
  tar xf \
    /tmp/snapdrop.tar.gz -C \
    /app/www/ --strip-components=1 && \
  cd /app/www/server && \
  npm i && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  echo "**** cleanup ****" && \
  rm -rf \
    /etc/logrotate.d/php-fpm \
    /etc/s6-overlay/s6-rc.d/svc-php-fpm \
    /etc/s6-overlay/s6-rc.d/user/contents.d/svc-php-fpm \
    /tmp/* \
    $HOME/.cache

# copy local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 80 443

VOLUME /config
