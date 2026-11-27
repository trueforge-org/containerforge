
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
# renovate: datasource=pypi depName=requests
ARG REQUESTS_VERSION=2.34.2
USER root

ENV HOME=/config \
    PYTHONUNBUFFERED=1

# Upstream publishes no releases or checksums. The full commit SHA in VERSION is the integrity anchor.
RUN echo "*** Installing namecheap-ddns ***" && \
  mkdir -p /app/namecheap-ddns /usr/share/licenses/namecheap-ddns /tmp/src && \
  curl -fsSL -o /tmp/namecheap-ddns.tar.gz \
    "https://github.com/EdwardChamberlain/namecheap_ddns/archive/${VERSION}.tar.gz" && \
  tar xzf /tmp/namecheap-ddns.tar.gz -C /tmp/src --strip-components=1 && \
  cp /tmp/src/src/main.py /tmp/src/src/config.py /app/namecheap-ddns/ && \
  cp /tmp/src/LICENSE /usr/share/licenses/namecheap-ddns/LICENSE && \
  echo "*** Installing Python dependencies ***" && \
  /app/venv/bin/pip install --no-cache-dir "requests==${REQUESTS_VERSION}" && \
  chown -R apps:apps /app/namecheap-ddns && chmod -R 755 /app/namecheap-ddns && \
  rm -rf /tmp/src /tmp/namecheap-ddns.tar.gz /root/.cache /tmp/*

USER apps
COPY --chmod=0755 . /

WORKDIR /config

VOLUME /config
