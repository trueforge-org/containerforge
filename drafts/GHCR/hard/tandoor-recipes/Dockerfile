
# Build stage: install the Python dependencies and the app source into /app.
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d AS build

ARG VERSION
USER root

# UNVERIFIED: build headers for the pinned Python wheels. Check each one against requirements.txt. Upstream installs these in its apk build set.
RUN echo "*** Installing build dependencies ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    libffi-dev \
    libjpeg-dev \
    libldap2-dev \
    libpq-dev \
    libsasl2-dev \
    libssl-dev \
    libwebp-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libxslt1-dev \
    zlib1g-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Source: no release assets, so build from the tag tarball.
# UNVERIFIED: no upstream checksum is published. Pin the tag commit before merge (the 2.7.8 SHA is not verified).
RUN echo "*** Fetching Tandoor Recipes ${VERSION} source ***" && \
  mkdir -p /src /app && \
  curl -fsSL -o /tmp/recipes.tar.gz \
    "https://github.com/TandoorRecipes/recipes/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xzf /tmp/recipes.tar.gz -C /src --strip-components=1 && \
  rm /tmp/recipes.tar.gz

# The venv is built in place at /app/venv, because copied venvs break their shebangs.
# Pip cache goes to /tmp. The dev requirements are stripped, as upstream does.
ENV PIP_CACHE_DIR=/tmp/pip
RUN echo "*** Installing Python dependencies ***" && \
  cd /src && \
  sed -i '/# Development/,$d' requirements.txt && \
  python -m venv /app/venv && \
  /app/venv/bin/pip install --no-cache-dir wheel==0.48.0 setuptools_rust==1.13.0 && \
  /app/venv/bin/pip install --no-cache-dir -r requirements.txt && \
  cp -a /src/. /app/ && \
  install -Dm644 /src/LICENSE /usr/share/licenses/tandoor-recipes/LICENSE

# Runtime stage. The python base already runs as apps.
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

USER root

# tini is the upstream PID 1 handoff. nginx is not installed yet (see start.sh).
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    libpq5 \
    tini && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

COPY --from=build /app /app
COPY --from=build /usr/share/licenses/tandoor-recipes /usr/share/licenses/tandoor-recipes

ENV \
  PYTHONUNBUFFERED=1 \
  DOCKER=true

WORKDIR /app

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config

ENTRYPOINT ["/usr/bin/tini", "--", "/start.sh"]
