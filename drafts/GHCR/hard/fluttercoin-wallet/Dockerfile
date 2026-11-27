# UNVERIFIED (initial draft): the daemon is a 2018 glibc build from the upstream zip and has not
# been run on ubuntu 26.04. Headless only, the GUI wallet needs Qt4 and is not reproduced.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
# SHA-256 of the amd64 release zip. Self-computed, not published upstream. Re-verify on a fresh download before the PR.
ARG FLT_SHA256=4d53d27e33c7467d89dd57a793aba99eec8fa94d3e24ff11b26dfecd37b33938
USER root

RUN case "${TARGETARCH}" in amd64) ;; *) echo "fluttercoin-wallet: no upstream build for ${TARGETARCH}" >&2; exit 1 ;; esac

# UNVERIFIED: whether unzip is already in the base image
RUN \
  echo "*** Installing unzip ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends unzip && \
  rm -rf /var/lib/apt/lists/*

RUN \
  echo "*** Installing Fluttercoin daemon ***" && \
  FLT_VERSION="${VERSION%-flt}" && \
  FLT_VERSION="${FLT_VERSION#v}" && \
  curl -fsSL -o /tmp/fluttercoin.zip \
    "https://github.com/ofeefee/fluttercoin/releases/download/${VERSION}/fluttercoin-64-linux-v${FLT_VERSION}.zip" && \
  echo "${FLT_SHA256}  /tmp/fluttercoin.zip" | sha256sum -c - && \
  mkdir -p /app/fluttercoin/bin && \
  unzip -j /tmp/fluttercoin.zip fluttercoind -d /app/fluttercoin/bin && \
  chmod 0755 /app/fluttercoin/bin/fluttercoind && \
  rm -f /tmp/fluttercoin.zip

# UNVERIFIED: the zip has no LICENSE file and the raw master LICENSE returned 404.
# Ship the upstream MIT licence text under /usr/share/licenses/fluttercoin-wallet/ once it is located.

ENV HOME=/config

RUN mkdir -p /config && chown apps:apps /config

USER apps
COPY --chmod=0755 . /

EXPOSE 7408 7474
VOLUME /config
