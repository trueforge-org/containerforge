
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV \
  HOME=/config \
  NETDATA_LISTENER_PORT=19999

# Per-arch values come from the release sha256sums.txt for v2.13.0 (see plan).
# Root is needed for the installer; plugins that need root will lose metrics under USER apps (blocker, see plan section 10).
RUN \
  echo "**** install netdata ****" && \
  case "$TARGETARCH" in \
    amd64) NETDATA_ARCH=x86_64; NETDATA_SHA256=bb0be18228b49c9c816b87193a070ed93defdd8e366368899e39cb7d005ca6f7;; \
    arm64) NETDATA_ARCH=aarch64; NETDATA_SHA256=956e7c4d4447b98cb7aee126c36ec64a6e0b131af3651ec44425f009933e0d6d;; \
    *) echo "unsupported architecture: $TARGETARCH" && exit 1;; \
  esac && \
  curl -fsSL -o /tmp/netdata.gz.run \
    "https://github.com/netdata/netdata/releases/download/${VERSION}/netdata-${NETDATA_ARCH}-latest.gz.run" && \
  echo "${NETDATA_SHA256}  /tmp/netdata.gz.run" | sha256sum -c - && \
  chmod +x /tmp/netdata.gz.run && \
  # UNVERIFIED: installer flags and install prefix for v2.13.0. Check `--help` in the first build round and set the target to /app/netdata.
  /tmp/netdata.gz.run --accept --target /app/netdata && \
  chown -R apps:apps /app/netdata && chmod -R 755 /app/netdata && \
  echo "**** cleanup ****" && \
  rm -f /tmp/netdata.gz.run
# UNVERIFIED: GPL-3.0 licence file from the installed tree; copy it to /usr/share/licenses/netdata/ once the path is confirmed.

USER apps
COPY --chmod=0755 . /


EXPOSE 19999

VOLUME /config

WORKDIR /config
