# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:24efb13c405c262ba2d501640e0a70e0454439ed722125055b11814ff49323db

ARG TARGETPLATFORM
ARG VERSION

USER root

WORKDIR /app

# hadolint ignore=DL3008,DL3015,SC2086,SC2155,DL4001
RUN apt-get -qq update \
  && \
  apt-get -qq install -y gnupg curl ca-certificates wget \
  && \
  install -d -m 0755 /etc/apt/keyrings \
  && \
  wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | gpg --dearmor -o /etc/apt/keyrings/mongodb-server-6.0.gpg \
  && \
  chmod 0644 /etc/apt/keyrings/mongodb-server-6.0.gpg \
  && \
  echo "deb [ arch=amd64,arm64 signed-by=/etc/apt/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list \
  && \
  apt-get -qq update \
  && \
  apt-get -qq install -y \
    mongodb-mongosh \
  && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
  && apt-get autoremove -y \
  && apt-get clean \
  && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/

USER apps
COPY --chmod=0755 . /
