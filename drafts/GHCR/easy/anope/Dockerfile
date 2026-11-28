FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG VENDOR
# Ubuntu resolute (26.04) package. Upstream 2.0.21 is newer; the apt route cannot give it.
ARG APT_VERSION=2.0.17-1.1
USER root

RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    "anope=${APT_VERSION}" && \
  echo "**** check version ****" && \
  dpkg-query -W -f='${Version}' anope | grep -qx "${APT_VERSION}" && \
  case "${APT_VERSION}" in "${VERSION}"-*) ;; *) echo "APT_VERSION does not match VERSION" >&2; exit 1 ;; esac && \
  echo "**** licence ****" && \
  mkdir -p /usr/share/licenses/anope && \
  cp /usr/share/doc/anope/copyright /usr/share/licenses/anope/copyright && \
  echo "**** config dir ****" && \
  install -d -o apps -g apps /config && \
  echo "**** cleanup ****" && \
  rm -rf \
    /var/lib/apt/lists/* \
    /tmp/*

ENV HOME=/config

# copy local files
USER apps
COPY --chmod=0755 . /

# no inbound ports: services connect out to the IRC server
VOLUME /config

WORKDIR /config
