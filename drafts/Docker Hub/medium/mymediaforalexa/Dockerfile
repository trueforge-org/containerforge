# Digest taken from the sibling apps/adguardhome-sync (ubuntu:26.04). The plan's 19cb2ce... digest is not in the repo.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config

# UNVERIFIED: the .deb URL pattern comes from the draft and is not confirmed for 1.3.156.0. Check it before the first build.
# UNVERIFIED: no upstream checksum exists. Record the SHA-256 of each .deb in the PR.
RUN case "${TARGETARCH}" in amd64|arm64) ;; *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; esac && \
  curl -fL -o /tmp/mymedia.deb \
    "https://bizmodeller.s3.amazonaws.com/MyMediaForAlexa/${VERSION}/linux/mymedia_${VERSION}-1_${TARGETARCH}.deb" && \
  dpkg -x /tmp/mymedia.deb /tmp/mymedia-root && \
  mkdir -p /app/mymediaforalexa /usr/share/licenses/mymediaforalexa && \
  # UNVERIFIED: the install path inside the .deb is not known yet (read `dpkg -c`); this copies the whole tree as a placeholder
  cp -a /tmp/mymedia-root/. /app/mymediaforalexa/ && \
  chown -R apps:apps /app && \
  chmod -R 755 /app && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

# Alexa discovery advertises IP:port, so host ports must match these container ports (vendor docs)
EXPOSE 52051
EXPOSE 52050
VOLUME /config
