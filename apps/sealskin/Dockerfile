
FROM ghcr.io/trueforge-org/python:3.14.5@sha256:c1237b4ee242c9d67a1bae2611ab92f45e8c39da8835a974e4dd49d43077c353

# set version label
ARG VERSION
ARG TARGETARCH
USER root
ENV HOME=/config

# install software
RUN \
  echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    zip && \
  echo "**** install packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    caddy \
    openssl && \
  echo "**** install sealskin ****" && \
  mkdir /opt/sealskin && \
  curl -o \
    /tmp/sealskin.tar.gz -L \
    "https://github.com/selkies-project/sealskin/archive/${VERSION}.tar.gz" && \
  tar xf \
    /tmp/sealskin.tar.gz -C \
    /opt/sealskin --strip-components=1 && \
  pip3 install -r /opt/sealskin/server/requirements.txt --break-system-packages && \
  cd /opt/sealskin/browser_extension && \
  zip -r /sealskin.zip * && \
  chown apps:apps /sealskin.zip && \
  mkdir -p /storage && \
  chown apps:apps /storage && \
  echo "**** cleanup ****" && \
  apt-get autoremove -y && \
  rm -rf \
    $HOME/.cache \
    /tmp/*

# add local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 8000 8443
VOLUME /config
VOLUME /storage

WORKDIR /config
