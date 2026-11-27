FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

# set version label (IOPaint, the maintained successor of lama-cleaner)
ARG VERSION
USER root

# model caches persist in /config on purpose (the chart persists them too); a decision, see the plan
ENV HOME="/config" \
  TORCH_HOME="/config/cache/torch" \
  HF_HOME="/config/cache/huggingface"

# UNVERIFIED: PyTorch CPU wheels and IOPaint pins on this Python version; checked only at pip install time.
# UNVERIFIED: libgl1 and libglib2.0-0 are not installed; add them only if the import fails.
RUN \
  echo "**** install CPU PyTorch ****" && \
  /app/venv/bin/pip install --no-cache-dir \
    torch torchvision \
    --index-url https://download.pytorch.org/whl/cpu && \
  echo "**** install IOPaint ${VERSION} ****" && \
  /app/venv/bin/pip install --no-cache-dir "IOPaint==${VERSION}" && \
  echo "**** license ****" && \
  # UNVERIFIED: the wheel ships LICENSE in its dist-info; if not, fetch it from the upstream tag
  install -d /usr/share/licenses/lama-cleaner && \
  cp /app/venv/lib/python3*/site-packages/IOPaint-*.dist-info/LICENSE* /usr/share/licenses/lama-cleaner/ && \
  echo "**** cleanup ****" && \
  chown -R root:root /app && \
  chmod -R 755 /app && \
  rm -rf /tmp/*

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8080
VOLUME /config
WORKDIR /config
