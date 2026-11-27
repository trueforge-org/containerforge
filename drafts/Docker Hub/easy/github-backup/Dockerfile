
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION

# UNVERIFIED: this is the PyPI github-backup (josegonzalez/python-github-backup), not the archived lnxd image
# that the chart uses. Python 3.15 is not in the package classifiers (it declares 3.11 to 3.14).
ENV \
  HOME=/config \
  GIT_TERMINAL_PROMPT=0

USER root
WORKDIR /app

RUN set -eux; \
  /app/venv/bin/pip install --no-cache-dir "github-backup==${VERSION}"; \
  mkdir -p /usr/share/licenses/github-backup; \
  curl -fsSL -o /usr/share/licenses/github-backup/LICENSE.txt \
    "https://raw.githubusercontent.com/josegonzalez/python-github-backup/${VERSION}/LICENSE.txt"; \
  chown -R root:root /app; \
  chmod -R 755 /app; \
  rm -rf /root/.cache /tmp/*

USER apps
COPY --chmod=0755 . /

# No EXPOSE: the tool is a one-shot CLI with no listeners.
VOLUME /config
WORKDIR /config
