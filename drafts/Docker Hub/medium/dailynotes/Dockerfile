
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION

ENV PYTHONUNBUFFERED=1 \
    HOME=/config

USER root

# Source tarball of the tag (no release asset). UNVERIFIED: tag 2026.10.29-00 maps to commit 9d1a3a7e.
RUN echo "*** Installing DailyNotes ${VERSION} ***" && \
  mkdir -p /app && \
  curl -fsSL -o /tmp/dailynotes.tar.gz \
    "https://github.com/djedi/DailyNotes/archive/refs/tags/${VERSION}.tar.gz" && \
  tar xzf /tmp/dailynotes.tar.gz -C /app --strip-components=1 && \
  rm -f /tmp/dailynotes.tar.gz

# Python dependencies go into the bundled venv (read-only at runtime).
# UNVERIFIED: run.sh needs flask and gunicorn, which are not in requirements.txt; pin them at the build round.
RUN /app/venv/bin/pip install -U --no-cache-dir -r /app/requirements.txt && \
  /app/venv/bin/pip install -U --no-cache-dir flask gunicorn

# Client build; npm cache goes to /tmp, never /config
RUN (cd /app/client && \
    npm_config_cache=/tmp/npm npm install --prefer-offline --no-audit --legacy-peer-deps && \
    npm run build) && \
  rm -rf /app/client/node_modules /tmp/npm

# Upstream keeps its database and .env under /app/config; map it to the /config volume
RUN ln -s /config /app/config && \
  mkdir -p /usr/share/licenses/dailynotes && \
  cp /app/LICENSE /usr/share/licenses/dailynotes/LICENSE && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

WORKDIR /app

EXPOSE 8000

VOLUME /config
