FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION

USER root

# noVNC is static web files. websockify (pure Python, PyPI) serves them with --web.
# UNVERIFIED: no checksum is published upstream for the tag tarball. Pin a sha256 after the first fetch.
RUN echo "*** Installing noVNC ${VERSION} ***" && \
  mkdir -p /app/novnc /usr/share/licenses/novnc && \
  curl -fL -o /tmp/novnc.tar.gz \
    "https://api.github.com/repos/novnc/noVNC/tarball/v${VERSION}" && \
  tar xzf /tmp/novnc.tar.gz -C /app/novnc --strip-components=1 && \
  install -m 0644 /app/novnc/LICENSE.txt /usr/share/licenses/novnc/LICENSE.txt && \
  /app/venv/bin/python -m pip install --no-cache-dir "websockify==0.13.0" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  echo "*** Cleaning Up ***" && \
  rm -f /tmp/novnc.tar.gz

ENV \
  HOME=/config \
  REMOTE_HOST=localhost \
  REMOTE_PORT=5900

USER apps
COPY --chmod=0755 . /

EXPOSE 6080

VOLUME /config
