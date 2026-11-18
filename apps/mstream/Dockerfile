FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:1e4ce94f2d255834fe7557fd2de50f2c021834c8eff14e43b84b70a768cd8348

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV HOME="/config"

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    openssl && \
  echo "**** install app ****" && \
  mkdir -p \
    /app/mstream && \
  (curl -fL -o \
    /tmp/mstream.tar.gz \
    "https://github.com/IrosTheBeggar/mStream/archive/refs/tags/v${VERSION}.tar.gz" || curl -fL -o \
    /tmp/mstream.tar.gz \
    "https://github.com/IrosTheBeggar/mStream/archive/refs/tags/${VERSION}.tar.gz") && \
  tar xzf \
    /tmp/mstream.tar.gz -C \
    /app/mstream/ --strip-components=1 && \
  cd /app/mstream && \
  npm install --omit=dev && \
  chown -R apps:apps ./ && \
  npm link && \
  echo "**** cleanup ****" && \
  rm -rf /app/mstream/save/sync && \
  ln -s /config/sync /app/mstream/save/sync && \
  apt-get autoremove -y && \
  rm -rf \
    $HOME/.cache \
    $HOME/.npm \
    /tmp/* \
    /tmp/.npm

# add local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 3000
VOLUME /config

WORKDIR /config
