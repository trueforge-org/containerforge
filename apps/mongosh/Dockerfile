# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:e566b6c11ab30372ddb0ee460a2f65699fd50ad2eb148ddac0d7800074159f19

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
