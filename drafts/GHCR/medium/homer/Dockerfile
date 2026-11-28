FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

# set version label
ARG VERSION
USER root

RUN \
  echo "**** fetch homer ****" && \
  curl -fL -o \
    /tmp/homer.zip \
    "https://github.com/homer-dashboard/homer/releases/download/${VERSION}/homer.zip" && \
  # TODO: upstream publishes no checksum; pin the sha256 of this zip here after the first download.
  mkdir -p \
    /tmp/homer && \
  unzip -q \
    /tmp/homer.zip -d \
    /tmp/homer

FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1

# set version label
ARG VERSION
USER root

# static site, read-only at runtime
COPY --from=build /tmp/homer/ /app/www/

RUN \
  echo "**** link user assets into /config ****" && \
  mv /app/www/assets /app/www/default-assets && \
  rm -rf /app/www/assets && \
  ln -s /config/assets /app/www/assets && \
  # TODO: the release zip may ship a LICENSE (Apache-2.0 per the repo); copy it to /usr/share/licenses/homer/ once confirmed.
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* && \
  rm -rf /var/lib/apt/lists/*

# copy local files (defaults/default.conf replaces the base server block on 8080)
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8080
VOLUME /config

WORKDIR /config
