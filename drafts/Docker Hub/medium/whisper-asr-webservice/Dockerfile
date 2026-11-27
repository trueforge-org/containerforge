
# Draft from plan.md section 4. Not built.
# BLOCKER (plan section 3): upstream requires Python >=3.10,<3.14 (pyproject at v1.10.0).
# The python base below is 3.15.2, which is outside that range. The FROM line is a placeholder until a
# compatible base or interpreter is chosen.

FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# Model cache is in /config so large downloads survive restarts. Upstream reads ASR_MODEL_PATH (app/config.py).
ENV HOME=/config \
    ASR_ENGINE=openai_whisper \
    ASR_MODEL=base \
    ASR_MODEL_PATH=/config/cache/whisper

# UNVERIFIED: upstream copies ffmpeg from onerahmet/ffmpeg:n7.1; this draft uses the apt package instead.
RUN \
  echo "**** install ffmpeg ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ffmpeg && \
  echo "**** fetch source ****" && \
  mkdir -p /app && \
  curl -fL -o /tmp/src.tar.gz \
    "https://github.com/ahmetoner/whisper-asr-webservice/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xzf /tmp/src.tar.gz -C /app --strip-components=1 && \
  echo "**** install python deps into the base venv ****" && \
  python3 -m venv /tmp/poetry && \
  /tmp/poetry/bin/pip install "poetry==2.1.3" && \
  cd /app && \
  VIRTUAL_ENV=/app/venv PATH="/app/venv/bin:${PATH}" \
    POETRY_VIRTUALENVS_CREATE=false /tmp/poetry/bin/poetry install --extras cpu && \
  echo "**** install license ****" && \
  install -D /app/LICENSE /usr/share/licenses/whisper-asr-webservice/LICENSE && \
  echo "**** cleanup ****" && \
  chown -R root:root /app && \
  chmod -R 755 /app && \
  apt-get clean && \
  rm -rf /tmp/* /root/.cache /var/lib/apt/lists/*

# UNVERIFIED: swagger-ui assets. Upstream copies swagger-ui.css and swagger-ui-bundle.js from
# swaggerapi/swagger-ui:v5.9.1. This draft fetches the same files from the swagger-ui-dist npm package at 5.9.1.
RUN \
  echo "**** install swagger-ui assets ****" && \
  mkdir -p /app/swagger-ui-assets && \
  curl -fL -o /app/swagger-ui-assets/swagger-ui.css \
    "https://unpkg.com/swagger-ui-dist@5.9.1/swagger-ui.css" && \
  curl -fL -o /app/swagger-ui-assets/swagger-ui-bundle.js \
    "https://unpkg.com/swagger-ui-dist@5.9.1/swagger-ui-bundle.js" && \
  rm -rf /tmp/*

# add local files (start.sh)
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 9000
VOLUME /config

WORKDIR /app
