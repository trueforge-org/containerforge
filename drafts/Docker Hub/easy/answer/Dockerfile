FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV INSTALL_PORT=8080 \
    SITE_ADDR=0.0.0.0:8080 \
    LANGUAGE=en_US

# Verified against the checksums.txt published with the upstream release.
RUN \
  echo "**** install answer ****" && \
  V="${VERSION#v}" && \
  F="apache-answer-${V}-bin-linux-${TARGETARCH}.tar.gz" && \
  D="apache-answer-${V}-bin-linux-${TARGETARCH}" && \
  mkdir -p /app /usr/share/licenses/answer && \
  curl -fsSL -o "/tmp/${F}" "https://github.com/apache/answer/releases/download/v${V}/${F}" && \
  curl -fsSL -o /tmp/checksums.txt "https://github.com/apache/answer/releases/download/v${V}/checksums.txt" && \
  (cd /tmp && grep " ${F}\$" checksums.txt | sha256sum -c -) && \
  tar xzf "/tmp/${F}" -C /tmp && \
  install -m 0755 "/tmp/${D}/answer" /app/answer && \
  cp -r "/tmp/${D}/LICENSE" "/tmp/${D}/NOTICE" "/tmp/${D}/licenses" /usr/share/licenses/answer/ && \
  chown -R root:root /app && \
  rm -rf /tmp/*

COPY --chmod=0755 . /

EXPOSE 8080
WORKDIR /config
VOLUME /config

USER apps
