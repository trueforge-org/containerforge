
FROM ghcr.io/trueforge-org/python-node:3.13.12

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV THELOUNGE_HOME="/config"

RUN \
  echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git && \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    yarnpkg && \
  echo "**** download thelounge ****" && \
  mkdir -p \
    /app/thelounge && \
  (curl -fL -o \
    /tmp/thelounge.tar.gz \
    "https://github.com/thelounge/thelounge/archive/refs/tags/v${VERSION}.tar.gz" || curl -fL -o \
    /tmp/thelounge.tar.gz \
    "https://github.com/thelounge/thelounge/archive/refs/tags/${VERSION}.tar.gz") && \
  tar xf \
    /tmp/thelounge.tar.gz -C \
    /app/thelounge --strip-components=1 && \
  cd /app/thelounge && \
  echo "**** modify thelounge source ****" && \
  sed -i "s/public: false,/public: true,/g" defaults/config.js && \
  echo "**** install thelounge ****" && \
  yarnpkg install && \
  NODE_ENV=production yarnpkg build && \
  yarnpkg link && \
  yarnpkg --non-interactive cache clean && \
  echo "**** cleanup ****" && \
  apt-get autoremove -y && \
  rm -rf \
    /root \
    /tmp/* && \
  mkdir -p / \
    /root

# copy local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 9000
VOLUME /config

WORKDIR /config
