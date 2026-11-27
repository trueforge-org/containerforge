# Upstream: galexrt/container-jts3servermod @ 4ecf611 (openjdk:8-jre-buster, tini, entrypoint.sh).
# Adapted: java8 sibling base, tini dropped (start.sh execs java), vendor zip pinned by SHA-256, USER apps.

FROM ghcr.io/trueforge-org/java8:8@sha256:c3b5d515a5f2658b61680bbaff4cbb4a91b386f6e6f7ccab2eaafa5b7620d3ab

# VERSION is the wrapper image tag (label only). The vendor zip is unversioned.
ARG VERSION
# UNVERIFIED: SHA-256 of the vendor zip. Not published upstream. Record it after one
# download. The build stops while this is empty.
ARG ZIP_SHA256=""
USER root

ENV JTS3_JAVA_ARGS=-Xmx256M \
  JTS3_LOG=/config/logs/JTS3ServerMod_InstanceManager.cfg

RUN echo "*** Installing JTS3ServerMod ***" && \
  { test -n "${ZIP_SHA256}" || { echo "ZIP_SHA256 must be set"; exit 1; }; } && \
  apt-get update && \
  apt-get install -y --no-install-recommends curl unzip && \
  mkdir -p /app /defaults && \
  curl -fsSL -o /tmp/jts3servermod.zip \
    "https://www.stefan1200.de/dlrequest.php?file=jts3servermod&type=.zip" && \
  echo "${ZIP_SHA256}  /tmp/jts3servermod.zip" | sha256sum -c - && \
  unzip -q /tmp/jts3servermod.zip -d /tmp/jts3servermod-src && \
  mv /tmp/jts3servermod-src/JTS3ServerMod /app/jts3servermod && \
  rm -rf \
    /app/jts3servermod/tools \
    /app/jts3servermod/documents \
    /app/jts3servermod/changelog.txt && \
  find /app/jts3servermod -maxdepth 1 -iname 'readme*' -exec rm -rf {} + && \
  mv /app/jts3servermod/config /defaults/jts3servermod-config && \
  ln -s /config/config /app/jts3servermod/config && \
  chmod -R a+rX /app/jts3servermod /defaults && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/* /var/lib/apt/lists/*

USER apps
COPY --chmod=0755 . /

WORKDIR /config
VOLUME ["/config"]
