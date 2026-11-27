FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

# build variables
ARG VERSION
ARG VENDOR
# sha256 of archivebox-${VERSION}-py3-none-any.whl from the release SHA256SUMS (0.9.77)
ARG WHEEL_SHA256=239267554814b9a6c9c0ba9c3880988238c146b34da7805fcf6461e98de15449

ENV \
    DATA_DIR=/config/data \
    HOME=/tmp \
    XDG_CONFIG_HOME=/config/xdg/config \
    XDG_CACHE_HOME=/tmp/cache \
    TMP_DIR=/tmp/archivebox \
    CONFIG_DIR=/tmp/archivebox/lib \
    ABXPKG_LIB_DIR=/tmp/archivebox/lib \
    PIP_CACHE_DIR=/tmp/pip \
    UV_CACHE_DIR=/tmp/uv \
    PYTHONDONTWRITEBYTECODE=1 \
    TZ=UTC

USER root
WORKDIR /app

# Install the core ArchiveBox package from the release wheel.
# Browser and extractor binaries (Chromium, Node, sonic) are not included yet; see the PR notes.
RUN \
  echo "**** fetch and verify archivebox ${VERSION} ****" && \
  curl -fL -o /tmp/archivebox.whl \
    "https://github.com/ArchiveBox/ArchiveBox/releases/download/v${VERSION}/archivebox-${VERSION}-py3-none-any.whl" && \
  echo "${WHEEL_SHA256}  /tmp/archivebox.whl" | sha256sum -c - && \
  echo "**** install archivebox ${VERSION} ****" && \
  pip install --no-cache-dir /tmp/archivebox.whl && \
  rm -rf /tmp/* /root/.cache

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 5797
VOLUME /config
