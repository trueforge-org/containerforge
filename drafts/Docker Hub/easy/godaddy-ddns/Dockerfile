
FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
# sha256 of godaddy-publicip-updater.py at ${VERSION}, computed locally (upstream publishes none).
# Changing VERSION without updating this makes the build fail on purpose.
ARG SCRIPT_SHA256=225cd4d453817b631242d356efe36dfa3930cb6af98f5c8e1db551a3d1e5402f
# renovate: datasource=pypi depName=godaddypy
ARG GODADDYPY_VERSION=2.5.1
# renovate: datasource=pypi depName=pif
ARG PIF_VERSION=0.8.2
USER root

ENV HOME=/tmp \
    PYTHONUNBUFFERED=1

# UNVERIFIED: the upstream repo has no LICENSE file (404 at the pinned commit), see docker-bake.hcl.
RUN echo "*** Installing godaddy-publicip-updater ***" && \
  mkdir -p /app/bin /usr/share/licenses/godaddy-ddns && \
  curl -fsSL -o /app/bin/godaddy-publicip-updater.py \
    "https://raw.githubusercontent.com/jwater7/docker-godaddy-publicip-updater/${VERSION}/godaddy-publicip-updater.py" && \
  echo "${SCRIPT_SHA256}  /app/bin/godaddy-publicip-updater.py" | sha256sum -c - && \
  echo "*** Installing Python dependencies ***" && \
  /app/venv/bin/pip install --no-cache-dir requests "godaddypy==${GODADDYPY_VERSION}" "pif==${PIF_VERSION}" && \
  echo "*** Collecting third-party license files ***" && \
  for p in godaddypy pif requests; do \
    mkdir -p "/usr/share/licenses/godaddy-ddns/${p}"; \
    for f in /app/venv/lib/python3*/site-packages/${p}-*.dist-info/LICENSE* /app/venv/lib/python3*/site-packages/${p}-*.dist-info/METADATA; do \
      if [ -e "$f" ]; then cp "$f" "/usr/share/licenses/godaddy-ddns/${p}/"; fi; \
    done; \
  done && \
  printf '%s\n' \
    "godaddy-publicip-updater.py: https://github.com/jwater7/docker-godaddy-publicip-updater at commit ${VERSION}" \
    "The upstream repository ships no license file. See the PR for the license decision." \
    > /usr/share/licenses/godaddy-ddns/README && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf /root/.cache /tmp/*

USER apps
COPY --chmod=0755 . /

WORKDIR /config

VOLUME /config
