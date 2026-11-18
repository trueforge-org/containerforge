
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:1e4ce94f2d255834fe7557fd2de50f2c021834c8eff14e43b84b70a768cd8348

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    openssh-client \
    rsnapshot \
    rsync && \
  rm -rf /etc/rsnapshot.conf && \
  ln -s /config/rsnapshot.conf /etc/rsnapshot.conf && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

# copy local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
VOLUME /config

WORKDIR /config
