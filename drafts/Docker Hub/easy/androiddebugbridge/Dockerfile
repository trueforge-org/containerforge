
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
# sha256 of files/androidtv-connect.sh at v${VERSION}, computed locally (upstream publishes none).
# Changing VERSION without updating this makes the build fail on purpose.
ARG SCRIPT_SHA256=2f0752401a605a452cfddc146d86c9c265ff94f18a4e519627798f53b6f60e81
USER root

ENV HOME=/config \
    ADB_BIN=/usr/bin/adb \
    YQ_BIN=/usr/local/bin/yq \
    ANDROID_USER_HOME=/config/.android

# adb is not pinned: VERSION is the wrapper script's tag, not the adb version. Say so in the PR.
# yq is already in the ubuntu base at /usr/local/bin/yq, so it is not downloaded again.
RUN echo "*** Installing adb ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends adb && \
  rm -rf /var/lib/apt/lists/*

# UNVERIFIED: LICENSE at the v1.1.0 tag was not fetched. MIT is taken from the script header and the Docker Hub page.
RUN echo "*** Installing androidtv-connect ***" && \
  mkdir -p /app /usr/share/licenses/androiddebugbridge && \
  curl -fsSL -o /app/androidtv-connect.sh \
    "https://raw.githubusercontent.com/BLBurgess/adb-hass-androidtv/v${VERSION#v}/files/androidtv-connect.sh" && \
  echo "${SCRIPT_SHA256}  /app/androidtv-connect.sh" | sha256sum -c - && \
  chmod 0755 /app/androidtv-connect.sh && \
  curl -fsSL -o /usr/share/licenses/androiddebugbridge/LICENSE \
    "https://raw.githubusercontent.com/BLBurgess/adb-hass-androidtv/v${VERSION#v}/LICENSE" && \
  ln -s /config /opt/androidtv-connect && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 5037

WORKDIR /config

VOLUME /config
