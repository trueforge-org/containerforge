# UNVERIFIED: Lemur 1.9.3 declares Python 3.10 to 3.13; this 3.15.2 base is untested.
# If pip resolution or runtime fails, request a python 3.13 base instead of changing this tag.
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
ARG CFSSL_VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  LEMUR_CONF=/config/lemur.conf.py \
  PIP_CACHE_DIR=/tmp/pip-cache

# UNVERIFIED: the exact package set is derived from pip install errors; build deps are purged below.
RUN echo "*** Installing Lemur build and runtime dependencies ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    libpq5 \
    libldap2 \
    libsasl2-2 \
    build-essential \
    libffi-dev \
    libldap2-dev \
    libpq-dev \
    libsasl2-dev \
    libssl-dev && \
  echo "*** Installing Lemur ${VERSION} ***" && \
  /app/venv/bin/pip install --no-cache-dir "lemur==${VERSION}" && \
  echo "*** Installing CFSSL ${CFSSL_VERSION} ***" && \
  mkdir -p /tmp/cfssl && \
  for asset in "cfssl_${CFSSL_VERSION}_linux_${TARGETARCH}" "cfssljson_${CFSSL_VERSION}_linux_${TARGETARCH}"; do \
    curl -fsSL -o "/tmp/cfssl/${asset}" \
      "https://github.com/cloudflare/cfssl/releases/download/v${CFSSL_VERSION}/${asset}" ; \
  done && \
  curl -fsSL -o "/tmp/cfssl/cfssl_${CFSSL_VERSION}_checksums.txt" \
    "https://github.com/cloudflare/cfssl/releases/download/v${CFSSL_VERSION}/cfssl_${CFSSL_VERSION}_checksums.txt" && \
  grep -E "  (cfssl|cfssljson)_${CFSSL_VERSION}_linux_${TARGETARCH}\$" /tmp/cfssl/cfssl_${CFSSL_VERSION}_checksums.txt \
    > /tmp/cfssl/selected.sha256 && \
  (cd /tmp/cfssl && sha256sum -c selected.sha256) && \
  install -m 0755 "/tmp/cfssl/cfssl_${CFSSL_VERSION}_linux_${TARGETARCH}" /usr/local/bin/cfssl && \
  install -m 0755 "/tmp/cfssl/cfssljson_${CFSSL_VERSION}_linux_${TARGETARCH}" /usr/local/bin/cfssljson && \
  echo "*** Installing licenses ***" && \
  mkdir -p /usr/share/licenses/lemur-cfssl && \
  find /app/venv/lib -path '*lemur-*.dist-info/*' \( -iname 'LICENSE*' -o -iname 'COPYING*' \) \
    -exec cp {} /usr/share/licenses/lemur-cfssl/ \; && \
  curl -fsSL -o /usr/share/licenses/lemur-cfssl/cfssl-LICENSE \
    "https://raw.githubusercontent.com/cloudflare/cfssl/v${CFSSL_VERSION}/LICENSE" && \
  echo "*** Cleaning Up ***" && \
  apt-get purge -y --auto-remove \
    build-essential \
    libffi-dev \
    libldap2-dev \
    libpq-dev \
    libsasl2-dev \
    libssl-dev && \
  rm -rf /var/lib/apt/lists/* /tmp/cfssl /tmp/pip-cache && \
  chown -R root:root /app && chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

EXPOSE 8000 8888

VOLUME /config

CMD ["/start.sh"]
