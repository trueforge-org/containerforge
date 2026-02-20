FROM ghcr.io/trueforge-org/node:22.22.0@sha256:d02dc64dae5f37614c8f149fbddfe574f9f3d32e4538a274c98d36c7a2e98107

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
COPY --chmod=0755 container-test.yaml /container-test.yaml
COPY --chmod=0755 . /
COPY ./root /

# ports and volumes
EXPOSE 80 443

VOLUME /config
