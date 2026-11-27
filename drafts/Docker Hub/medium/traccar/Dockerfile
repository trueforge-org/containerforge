# UNVERIFIED: the sibling apps/hytale pins java25 at a different digest (3db5983d...); confirm before build
FROM ghcr.io/trueforge-org/java25:25.0.1@sha256:22a0f8a73c79e2f733c7513aefceef24ab8a213fd35af0ab1946996efc21636d

# set version label
ARG VERSION
USER root

RUN \
  echo "**** install tools ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    curl \
    unzip && \
  echo "**** fetch traccar ****" && \
  mkdir -p \
    /app/traccar && \
  curl -fL -o \
    /tmp/traccar.zip \
    "https://github.com/traccar/traccar/releases/download/v${VERSION}/traccar-other-${VERSION}.zip" && \
  # UNVERIFIED: zip layout (tracker-server.jar at top level, no bundled runtime); record its SHA-256 once downloaded
  unzip -q \
    /tmp/traccar.zip -d \
    /app/traccar && \
  chmod -R 0755 /app/traccar && \
  echo "**** fetch license ****" && \
  mkdir -p \
    /usr/share/licenses/traccar && \
  curl -fL -o \
    /usr/share/licenses/traccar/LICENSE \
    "https://raw.githubusercontent.com/traccar/traccar/v${VERSION}/LICENSE" && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache && \
  rm -rf /var/lib/apt/lists/*

# copy local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8082
VOLUME /config

WORKDIR /config

CMD ["/start.sh"]
