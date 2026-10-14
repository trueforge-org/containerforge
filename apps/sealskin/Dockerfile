
FROM ghcr.io/trueforge-org/python:3.15.0@sha256:cc77b726944ed790a1b47a8dfc52868391e2558d09193e1524f5ca74e0ccad5d

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
