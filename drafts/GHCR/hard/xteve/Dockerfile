FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config

# UNVERIFIED: no checksum is published and the master-branch URL is unpinned. Record a SHA-256 on the first build.
RUN echo "*** Installing xTeVe ***" && \
  curl -fsSL -o \
    /tmp/xteve.zip \
    "https://github.com/xteve-project/xTeVe-Downloads/raw/master/xteve_linux_${TARGETARCH}.zip" && \
  unzip -o /tmp/xteve.zip -d /app && \
  chmod 0755 /app/xteve && \
  mkdir -p /usr/share/licenses/xteve && \
  curl -fsSL -o /usr/share/licenses/xteve/LICENSE \
    "https://raw.githubusercontent.com/xteve-project/xTeVe/master/LICENSE" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  echo "*** Cleaning Up ***" && \
  rm /tmp/xteve.zip

USER apps
COPY --chmod=0755 . /

EXPOSE 34400

VOLUME /config
