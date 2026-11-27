FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
USER root

ENV \
  HOME=/config \
  AWS_SHARED_CREDENTIALS_FILE=/tmp/aws-credentials \
  AWS_CONFIG_FILE=/tmp/aws-config

# AWS CLI v1 from PyPI (v2 is not on PyPI). Pure Python, installed into the bundled venv at build time.
# UNVERIFIED: awscli 1.46.3 on Python 3.15 (upstream classifiers stop at 3.14). If pip resolution fails, use the nearest python base tag.
# UNVERIFIED: the LICENSE file is copied from the installed dist-info. Confirm it exists in the wheel.
RUN set -eux; \
  /app/venv/bin/pip install --no-cache-dir "awscli==${VERSION}"; \
  /app/venv/bin/aws --version; \
  mkdir -p /usr/share/licenses/s3sync; \
  cp /app/venv/lib/python3*/site-packages/awscli-*.dist-info/LICENSE* /usr/share/licenses/s3sync/

USER apps
COPY --chmod=0755 . /

WORKDIR /config

VOLUME /config
