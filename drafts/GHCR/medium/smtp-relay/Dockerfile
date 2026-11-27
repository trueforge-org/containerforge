
# Replaces the archived ix-ai/smtp image with Debian Exim packaged by Ubuntu.
# UNVERIFIED: the Exim daemon must run as a non-root user with the -C config below (PoC required, plan section 9).
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment variables
# 2525 is a deliberate change from the upstream port 25, which a rootless user cannot bind.
ENV PORT=2525 \
    BIND_IP=0.0.0.0 \
    BIND_IP6=::0 \
    HOME=/config

RUN \
  echo "**** install exim ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    exim4-daemon-light=${VERSION}-1ubuntu1.5 \
    ca-certificates && \
  echo "**** install license ****" && \
  install -D -m 0644 \
    /usr/share/doc/exim4-base/copyright \
    /usr/share/licenses/smtp-relay/LICENSE && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/*

# add local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 2525
VOLUME /config

WORKDIR /config
