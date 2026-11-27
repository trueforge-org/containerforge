FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
USER root
WORKDIR /app

# Upstream backend builds on python:3.14-slim. This base is 3.15.2. Compatibility is UNVERIFIED (plan section 3).
# Upstream builder also installs gcc, cargo, libre2-dev and others. Exact package names are UNVERIFIED,
# so add them to this step only when the build fails, and purge them after `uv sync`.

# Source tarball, pinned to the tag. No checksum is published upstream: record the SHA-256 in the PR.
RUN set -eux; \
  mkdir -p /app/kitchenowl; \
  curl -fsSL "https://github.com/TomBursch/kitchenowl/archive/refs/tags/v${VERSION}.tar.gz" \
    | tar xz -C /app/kitchenowl --strip-components=1

# Python dependencies go into the bundled venv (/app/venv). uv is removed afterwards, as in apps/bazarr.
RUN set -eux; \
  export UV_CACHE_DIR=/tmp/uv-cache PIP_CACHE_DIR=/tmp/pip-cache; \
  pip install uv; \
  cd /app/kitchenowl/backend; \
  UV_PROJECT_ENVIRONMENT=/app/venv uv sync --no-dev; \
  pip uninstall --yes uv

# UNVERIFIED: upstream downloads the nltk data averaged_perceptron_tagger_eng at build time.
# The destination path was not read. Add a build-time download under /app once the upstream backend Dockerfile is read.

RUN set -eux; \
  mkdir -p /usr/share/licenses/kitchenowl; \
  cp /app/kitchenowl/LICENSE /usr/share/licenses/kitchenowl/LICENSE; \
  chown -R root:root /app; \
  chmod -R 755 /app; \
  rm -rf /tmp/* /root/.cache

ENV STORAGE_PATH=/config/data \
    DEBUG=False

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
WORKDIR /app/kitchenowl/backend
