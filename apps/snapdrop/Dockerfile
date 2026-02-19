## TODO pin version tag
FROM ghcr.io/trueforge-org/node:rolling@sha256:e03554fe5a09fa1914bbd02478cc590f1520bd0de4972529b226f430f6d0b84c

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
COPY container-test.yaml /container-test.yaml
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 80 443

VOLUME /config
