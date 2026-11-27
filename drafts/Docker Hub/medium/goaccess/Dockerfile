FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# UNVERIFIED: pin the apt goaccess version after checking `apt-cache policy goaccess` against VERSION (v1.12)
RUN \
  echo "**** install goaccess ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    goaccess && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/*

# UNVERIFIED: the Debian/Ubuntu copyright file is expected to carry the MIT text
RUN \
  install -d /usr/share/licenses/goaccess && \
  cp /usr/share/doc/goaccess/copyright /usr/share/licenses/goaccess/LICENSE && \
  install -d -o apps -g apps /config

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 7889
VOLUME /config

WORKDIR /config

CMD ["/start.sh"]
