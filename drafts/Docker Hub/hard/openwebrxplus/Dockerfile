# BLOCKER (plan.md section 10): the OpenWebRX+ PPA has no Ubuntu 26.04 suite, and python3-csdr /
# python3-digiham (noble) require python3 (<< 3.13), while this base ships Python 3.14.
# This is the route A draft. The apt install below is expected to fail on that constraint until the
# Python 3.12 spike (plan.md section 4, steps 2 to 4) is written and proven. Do not open a PR before then.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV TMPDIR=/tmp \
    XDG_CACHE_HOME=/tmp/.cache \
    HOME=/tmp \
    PYTHONDONTWRITEBYTECODE=1

# OpenWebRX+ PPA (noble suite), signed repository; the key URL is from plan.md.
# UNVERIFIED: whether the noble suite installs on Ubuntu 26.04 at all (see the blocker above).
RUN \
  echo "**** add openwebrx+ repository ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends ca-certificates curl gnupg && \
  mkdir -p /etc/apt/keyrings && \
  curl -fsSL https://luarvique.github.io/ppa/openwebrx-plus.gpg \
    | gpg --dearmor -o /etc/apt/keyrings/openwebrx-plus.gpg && \
  echo "deb [signed-by=/etc/apt/keyrings/openwebrx-plus.gpg] https://luarvique.github.io/ppa/noble ./" \
    > /etc/apt/sources.list.d/openwebrx-plus.list && \
  apt-get update

# Pinned install: the build fails if the repository candidate is not the VERSION in docker-bake.hcl.
# Runtime packages only (minimal set from plan.md section 4); decoders are added one at a time later.
# hadolint ignore=DL3008,DL3015
RUN \
  echo "**** install openwebrx+ ****" && \
  test "$(apt-cache policy openwebrx | awk '/Candidate/{print $2}')" = "${VERSION}" && \
  apt-get install -y --no-install-recommends \
    "openwebrx=${VERSION}" \
    owrx-connector \
    python3-csdr \
    rtl-sdr \
    libusb-1.0-0 \
    sox && \
  echo "**** pristine config for first-run seeding ****" && \
  cp -a /etc/openwebrx /etc/openwebrx.dist && \
  rm -rf /etc/openwebrx && \
  mkdir -p /config && \
  ln -s /config/etc /etc/openwebrx && \
  echo "**** plugins live on /config ****" && \
  mkdir -p /usr/lib/python3/dist-packages/htdocs && \
  rm -rf /usr/lib/python3/dist-packages/htdocs/plugins && \
  ln -s /config/plugins /usr/lib/python3/dist-packages/htdocs/plugins && \
  echo "**** licence ****" && \
  mkdir -p /usr/share/licenses/openwebrx && \
  cp /usr/share/doc/openwebrx/copyright /usr/share/licenses/openwebrx/ && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf /tmp/* /var/lib/apt/lists/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8073
VOLUME /config

WORKDIR /config
