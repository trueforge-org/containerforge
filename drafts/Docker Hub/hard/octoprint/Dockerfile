FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
ARG TARGETARCH
# SHA256 of octoprint-${VERSION}-py3-none-any.whl from PyPI (update together with VERSION)
ARG OCTOPRINT_WHEEL_SHA256=29cfe7e02a88dab1e5b0212d7120355eca5a10c5aa9ca7d15f1608c6ced3870d
USER root

# Build-time only. PIP_USER is set at runtime below, because pip refuses --user installs into a venv.
ENV PYTHONUNBUFFERED=1 \
  PIP_CACHE_DIR=/tmp/pip \
  XDG_CACHE_HOME=/tmp/.cache

RUN \
  echo "**** install build and runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    libffi-dev \
    libjpeg-dev \
    zlib1g-dev \
    libyaml-dev \
    avrdude \
    ffmpeg \
    imagemagick \
    libjpeg-turbo8 \
    openssh-client && \
  echo "**** install octoprint ${VERSION} ****" && \
  mkdir -p /tmp/ds && \
  /app/venv/bin/pip download -d /tmp/ds \
    --no-deps --only-binary=:all: --no-cache-dir \
    "OctoPrint==${VERSION}" && \
  echo "${OCTOPRINT_WHEEL_SHA256}  /tmp/ds/octoprint-${VERSION}-py3-none-any.whl" | sha256sum -c - && \
  /app/venv/bin/pip install --no-cache-dir \
    "/tmp/ds/octoprint-${VERSION}-py3-none-any.whl" && \
  echo "**** install licence ****" && \
  mkdir -p /usr/share/licenses/octoprint && \
  (cp /app/venv/lib/python3*/site-packages/octoprint-${VERSION}.dist-info/licenses/* \
    /usr/share/licenses/octoprint/ 2>/dev/null || \
   curl -fsSL -o /usr/share/licenses/octoprint/LICENSE.txt \
    "https://raw.githubusercontent.com/OctoPrint/OctoPrint/${VERSION}/LICENSE.txt") && \
  echo "**** cleanup ****" && \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    build-essential libffi-dev libjpeg-dev zlib1g-dev libyaml-dev && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /root/.cache \
    /var/lib/apt/lists/*

# Plugin installs from the OctoPrint UI go to persistent /config/plugins, because /app/venv is read-only.
ENV HOME=/config \
  PIP_USER=true \
  PYTHONUSERBASE=/config/plugins \
  PATH=/config/plugins/bin:$PATH

USER apps
COPY --chmod=0755 . /

EXPOSE 5000

VOLUME /config

WORKDIR /config
