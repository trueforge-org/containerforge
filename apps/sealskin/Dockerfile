
FROM ghcr.io/trueforge-org/python:3.14.6@sha256:05f202826a9a6c79df728a9e9e7ad325a0abd9c0430fb22d30583ef55e459329

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
