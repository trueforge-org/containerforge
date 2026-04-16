# hadolint ignore=DL3007
FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:c5a3b56e4d22600d2b618d602d487732516cc067cb21969798210c3b12304842

ARG TARGETPLATFORM
ARG VERSION

USER root

WORKDIR /app

# hadolint ignore=DL3008,DL3015,SC2086,SC2155,DL4001
RUN apt-get -qq update \
  && \
  apt-get -qq install -y gnupg; \
  curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  && \
  wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add - \
  && \
  echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list \
  && \
  apt-get -qq update \
  && \
  apt-get -qq install -y \
    mongodb-mongosh \
  && apt-get remove -y \
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
