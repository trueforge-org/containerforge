
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

# VERSION is the upstream commit sha (the repo has no releases or tags).
ARG VERSION
ARG TARGETARCH
USER root
WORKDIR /app

ENV \
  HOME=/config \
  PIP_CACHE_DIR=/tmp/pip \
  PYTHONDONTWRITEBYTECODE=1 \
  PORT=5000 \
  APP_LOG_LEVEL=INFO

# UNVERIFIED: pin the ipmitool apt version on the first build and record it here.
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    ipmitool \
    unzip && \
  rm -rf /var/lib/apt/lists/*

# Fetch the app at the pinned commit. The repo has no licence; see the LICENSE note in docker-bake.hcl.
RUN echo "*** Downloading IPMI-Fan-Controller ${VERSION} ***" && \
  curl -fsSL -o \
    /tmp/ipmi-fan-controller.zip \
    "https://github.com/EdwardChamberlain/IPMI-Fan-Controller/archive/${VERSION}.zip" && \
  unzip -q /tmp/ipmi-fan-controller.zip -d /tmp/src && \
  mkdir -p /app/bin && \
  cp -r /tmp/src/IPMI-Fan-Controller-${VERSION}/app/. /app/bin/ && \
  test -f /app/bin/main.py && \
  rm -rf /tmp/src /tmp/ipmi-fan-controller.zip

# UNVERIFIED: the Flask stack from 2023 may not install on Python 3.15. Pin versions after a first resolve.
# gunicorn is the WSGI server; upstream's base image used it too.
RUN python -m venv /app/venv && \
  /app/venv/bin/pip install --no-cache-dir \
    flask \
    flask-wtf \
    wtforms \
    flask-bootstrap4 \
    gunicorn

# No licence was found upstream, so ship only a notice. Revisit once the upstream author answers.
RUN mkdir -p /usr/share/licenses/ipmi-tools && \
  printf '%s\n' "Upstream repository EdwardChamberlain/IPMI-Fan-Controller at ${VERSION} has no licence file." \
    "No licence was granted in the source. Do not redistribute until one is provided." \
    > /usr/share/licenses/ipmi-tools/NOTICE

RUN chown -R root:root /app && chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

WORKDIR /config
EXPOSE 5000

VOLUME /config
