FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
ARG TARGETARCH
ARG SUPERCRONIC_VERSION
# UNVERIFIED: supercronic sha256 digests are not confirmed in the plan. Fill them from the
# release checksums before building. With an empty value the build fails closed.
ARG SUPERCRONIC_SHA256_AMD64=""
ARG SUPERCRONIC_SHA256_ARM64=""
USER root

ENV \
  PYTHONUNBUFFERED=1 \
  PIP_NO_CACHE_DIR=1 \
  PYTHONPATH=/config

# supercronic runs cron jobs without root and logs to stdout.
RUN echo "**** install supercronic ****" && \
  case "${TARGETARCH}" in \
    amd64) sha="${SUPERCRONIC_SHA256_AMD64}" ;; \
    arm64) sha="${SUPERCRONIC_SHA256_ARM64}" ;; \
    *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  curl -fsSL -o /usr/local/bin/supercronic \
    "https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-${TARGETARCH}" && \
  echo "${sha}  /usr/local/bin/supercronic" | sha256sum -c - && \
  chmod 0755 /usr/local/bin/supercronic && \
  mkdir -p /usr/share/licenses/supercronic && \
  curl -fsSL -o /usr/share/licenses/supercronic/LICENSE.md \
    "https://raw.githubusercontent.com/aptible/supercronic/${SUPERCRONIC_VERSION}/LICENSE.md" && \
  rm -rf /tmp/*

# Upstream publishes no license and no tags. Pinned by commit. The layout is
# import_ics/ at the archive root (UNVERIFIED for this exact commit, from the upstream dockerfile).
RUN echo "**** install import_ics ****" && \
  mkdir -p /tmp/ics /app/import_ics /usr/share/licenses/import-ics && \
  curl -fsSL -o /tmp/import_ics.tar.gz \
    "https://github.com/Vilhjalmr26/import_ics/archive/${VERSION}.tar.gz" && \
  tar xzf /tmp/import_ics.tar.gz -C /tmp/ics --strip-components=1 && \
  mv /tmp/ics/import_ics/* /app/import_ics/ && \
  rm -f /app/import_ics/calendar_download_map.py && \
  /app/venv/bin/pip install --no-cache-dir \
    caldav==3.7.0 \
    requests==2.34.2 && \
  printf 'Source: https://github.com/Vilhjalmr26/import_ics\nCommit: %s\nLicense: none published upstream\n' "${VERSION}" \
    > /usr/share/licenses/import-ics/NOTICE && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

WORKDIR /config

VOLUME /config
