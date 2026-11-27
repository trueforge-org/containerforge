
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
ARG COMMIT
ARG SHA256

USER root
WORKDIR /app

# Upstream publishes no checksum, so the archive sha256 is pinned in docker-bake.hcl (set on first build).
RUN [ -n "${SHA256}" ] || { echo "ERROR: SHA256 build arg is required" >&2; exit 1; }

RUN echo "*** Installing py-kms ***" && \
  curl -fsSL -o /tmp/py-kms.tar.gz \
    "https://github.com/Py-KMS-Organization/py-kms/archive/${COMMIT}.tar.gz" && \
  echo "${SHA256}  /tmp/py-kms.tar.gz" | sha256sum -c - && \
  mkdir -p /app/py-kms /usr/share/licenses/kms && \
  tar -xzf /tmp/py-kms.tar.gz --strip-components=1 -C /app/py-kms && \
  cp /app/py-kms/LICENSE /usr/share/licenses/kms/LICENSE && \
  rm -f /tmp/py-kms.tar.gz

# Build time only: runtime never writes /app/venv. Minimal requirements (no Flask or gunicorn).
RUN echo "*** Installing py-kms requirements ***" && \
  PIP_CACHE_DIR=/tmp/pip /app/venv/bin/pip install --no-cache-dir \
    -r /app/py-kms/docker/docker-py3-kms-minimal/requirements.txt && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 1688

VOLUME /config
