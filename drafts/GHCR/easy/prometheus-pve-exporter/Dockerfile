FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
USER root

# Install at build time only. /app/venv is read-only at runtime.
RUN echo "*** Installing prometheus-pve-exporter ***" && \
  /app/venv/bin/python -m pip install --no-cache-dir "prometheus-pve-exporter==${VERSION}" && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 9221

VOLUME /config

CMD ["/start.sh"]
