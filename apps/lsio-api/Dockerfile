FROM ghcr.io/trueforge-org/ubuntu:24.4

ARG VERSION

COPY root/app/requirements.txt /tmp/requirements.txt

RUN \
  echo "**** install packages ****" && \
  apk add  -U --update --no-cache \
    python3 && \
  cd /app && \
  python3 -m venv /lsiopy && \
  pip install -U --no-cache-dir \
    pip && \
  pip install -U --no-cache-dir -r /tmp/requirements.txt && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

COPY root/ /

EXPVERSIONE 8000
VOLUME /config
