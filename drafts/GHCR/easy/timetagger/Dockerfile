
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
USER root

ENV TIMETAGGER_BIND=0.0.0.0:8080 \
  TIMETAGGER_DATADIR=/config/timetagger

# UNVERIFIED: Python 3.15 compatibility of timetagger 26.1.3 (upstream image uses 3.13). Record the result of the first build.
# UNVERIFIED: uvicorn, uvloop and httptools are unpinned upstream; pin them after checking versions in the first build.
RUN echo "*** Installing TimeTagger ***" && \
  if [ ! -x /app/venv/bin/python ]; then python3 -m venv /app/venv; fi && \
  /app/venv/bin/python -m pip install -U --no-cache-dir pip && \
  /app/venv/bin/python -m pip install --no-cache-dir --no-compile \
    "timetagger==${VERSION}" \
    uvicorn \
    uvloop \
    httptools && \
  mkdir -p /usr/share/licenses/timetagger && \
  LICENSE_FILE="$(find /app/venv -path '*timetagger*' -iname 'LICENSE*' -print -quit)" && \
  if [ -n "${LICENSE_FILE}" ]; then \
    cp "${LICENSE_FILE}" /usr/share/licenses/timetagger/LICENSE; \
  else \
    curl -fsSL -o /usr/share/licenses/timetagger/LICENSE \
      "https://raw.githubusercontent.com/almarklein/timetagger/v${VERSION}/LICENSE"; \
  fi && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  echo "*** Cleaning Up ***" && \
  rm -rf /root/.cache /tmp/* /var/lib/apt/lists/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
