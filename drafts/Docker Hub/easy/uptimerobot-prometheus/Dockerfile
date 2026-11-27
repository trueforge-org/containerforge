FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
ARG UPTIMEROBOT_COMMIT

ENV \
  PYTHONUNBUFFERED=1 \
  PYTHONDONTWRITEBYTECODE=1 \
  HOME=/tmp

USER root

# Upstream publishes no releases or tags, so the exporter is pinned to a commit.
# UNVERIFIED: the requests pin is taken from the plan (2.34.2); check it is still the latest release at build time.
RUN echo "*** Installing uptimerobot-prometheus ***" && \
  mkdir -p /app/exporter /usr/share/licenses/uptimerobot-prometheus && \
  curl -fsSL -o /app/exporter/exporter.py \
    "https://raw.githubusercontent.com/lekpamartin/uptimerobot_exporter/${UPTIMEROBOT_COMMIT}/files/exporter.py" && \
  curl -fsSL -o /usr/share/licenses/uptimerobot-prometheus/LICENSE \
    "https://raw.githubusercontent.com/lekpamartin/uptimerobot_exporter/${UPTIMEROBOT_COMMIT}/LICENSE" && \
  /app/venv/bin/pip install --no-cache-dir "requests==2.34.2" && \
  chown -R root:root /app/exporter && chmod -R a+rX /app/exporter && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 9705
VOLUME /config
WORKDIR /config
