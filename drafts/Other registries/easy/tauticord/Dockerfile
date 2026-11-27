
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

# set version label
ARG VERSION
ARG TARGETARCH
USER root

WORKDIR /app

# UNVERIFIED: archive URL form not fetched; Codeberg publishes no checksum, so the tag is the pin.
RUN \
  echo "**** fetch tauticord ${VERSION} ****" && \
  curl -fL -o /tmp/tauticord.tar.gz \
    "https://codeberg.org/nwithan8/tauticord/archive/${VERSION}.tar.gz" && \
  tar xzf /tmp/tauticord.tar.gz -C /app --strip-components=1 && \
  echo "**** install requirements into the base venv (build time only) ****" && \
  /app/venv/bin/pip install --no-cache-dir setuptools_rust && \
  /app/venv/bin/pip install --no-cache-dir -r /app/requirements.txt --prefer-binary && \
  install -Dm0644 /app/LICENSE /usr/share/licenses/tauticord/LICENSE && \
  rm -rf \
    /tmp/* \
    $HOME/.cache \
    /var/lib/apt/lists/*

# add local files
USER apps
COPY --chmod=0755 . /

# UNVERIFIED: upstream also declares VOLUME /logs and the app's log path is not confirmed, so it is not added yet.
# UNVERIFIED: no EXPOSE. Upstream EXPOSEs 8283 and the chart probes it, but the listener is not confirmed from source.
VOLUME /config
