# Upstream: mealie-recipes/mealie docker/Dockerfile @ v3.31.0 (node frontend, uv wheel, venv at /opt/mealie).
# Adapted: ContainerForge python bases (3.14, required by requires-python), /config data via symlink, USER apps.

# Source fetched once by tag and shared by the later stages.
FROM ghcr.io/trueforge-org/python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232 AS source

ARG VERSION
USER root

RUN mkdir -p /src && \
  curl -fsSL -o /tmp/mealie.tar.gz \
    "https://github.com/mealie-recipes/mealie/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xf /tmp/mealie.tar.gz -C /src --strip-components=1 && \
  rm /tmp/mealie.tar.gz

# Frontend build. UNVERIFIED: upstream uses node 26; the node major in this base is not confirmed.
FROM ghcr.io/trueforge-org/python-node:3.14.8@sha256:feb6e44439ea272f47b46a1511960f58af5df8056811c83973e2edec9b18afca AS frontend

USER root
ENV npm_config_cache=/tmp/npm

COPY --from=source /src /src

RUN npm install -g pnpm@12.18.0 && \
  cd /src/frontend && \
  pnpm clean-install && \
  pnpm generate && \
  mkdir -p /out && \
  cp -a dist /out/dist && \
  rm -rf /tmp/*

FROM ghcr.io/trueforge-org/python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232 AS build

ARG VERSION
USER root

ENV PIP_CACHE_DIR=/tmp/pip \
  UV_CACHE_DIR=/tmp/uv \
  UV_FROZEN=1 \
  NLTK_DATA=/nltk_data/

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    libwebp-dev \
    libsasl2-dev \
    libldap2-dev \
    libssl-dev && \
  rm -rf /var/lib/apt/lists/*

COPY --from=source /src /src
COPY --from=frontend /out/dist /src/mealie/frontend

# Wheel and hashed dependency list are built from uv.lock; the venv lives outside /app.
RUN pip install uv==0.13.7 && \
  cd /src && \
  uv build --out-dir /tmp/dist && \
  uv export --no-dev --extra pgsql --no-emit-project --no-editable \
    --format requirements-txt --output-file /tmp/dist/dependencies.txt && \
  python3 -m venv --upgrade-deps /opt/mealie && \
  /opt/mealie/bin/pip install --require-hashes -r /tmp/dist/dependencies.txt && \
  /opt/mealie/bin/pip install --no-deps "/tmp/dist/mealie-${VERSION}-py3-none-any.whl" && \
  rm -rf /tmp/*

# UNVERIFIED: setup_nltk_data.sh was not read. It is run from the source tree and needs the
# network at build time only, so nothing is downloaded at runtime.
RUN mkdir -p /nltk_data && \
  PATH="/opt/mealie/bin:${PATH}" bash /src/docker/setup_nltk_data.sh && \
  chmod -R a+rX /nltk_data && \
  rm -rf /tmp/*

FROM ghcr.io/trueforge-org/python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232

ARG VERSION
USER root

ENV PRODUCTION=true \
  TESTING=false \
  APP_PORT=9000 \
  HOST=0.0.0.0 \
  MEALIE_HOME=/app \
  VENV_PATH=/opt/mealie \
  NLTK_DATA=/nltk_data/ \
  PYTHONUNBUFFERED=1 \
  PYTHONDONTWRITEBYTECODE=1 \
  PATH="/opt/mealie/bin:${PATH}"

# Check the base first: curl and libpq5 may already be present.
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    ffmpeg \
    libldap-common \
    libldap2 && \
  rm -rf /var/lib/apt/lists/*

COPY --from=build /opt/mealie /opt/mealie
COPY --from=build /nltk_data /nltk_data
COPY --from=build /src/LICENSE /usr/share/licenses/mealie/LICENSE

# Mealie writes .secret, .session_secret and the SQLite database under /app/data.
# /app is read-only at runtime, so the symlink points at the writable /config volume.
RUN ln -s /config/data /app/data

USER apps
COPY --chmod=0755 . /

EXPOSE 9000

VOLUME /config

WORKDIR /app
