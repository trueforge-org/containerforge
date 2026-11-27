
# Draft from plan.md section 4. Not built. UNVERIFIED items are marked inline.

FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# Upstream pins CPython 3.12 (.python-version, uv.lock). uv installs it, so the base 3.15 interpreter is not used.
# HOME points at a read-only path that holds the NudeNet model. Nothing may be written there at runtime.
ENV UV_PROJECT_ENVIRONMENT=/app/imgpush-venv \
    UV_PYTHON_INSTALL_DIR=/usr/local/share/uv/python \
    U2NET_HOME=/app/models \
    HOME=/app/home \
    NUMBA_CACHE_DIR=/tmp \
    MPLCONFIGDIR=/tmp \
    XDG_CACHE_HOME=/tmp \
    PATH=/app/imgpush-venv/bin:$PATH

# UNVERIFIED: libmagickwand-dev on ubuntu 26.04 is ImageMagick 7; the upstream policy path (ImageMagick-6) may not fit.
# UNVERIFIED: uv is installed unpinned with pip; pin it when the version is chosen.
# UNVERIFIED: uv downloads its managed CPython 3.12 without a checksum.
RUN \
  echo "**** install packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    libmagickwand-dev \
    nginx && \
  echo "**** install uv ****" && \
  pip install uv && \
  echo "**** fetch source ****" && \
  mkdir -p /tmp/src && \
  curl -fL -o /tmp/imgpush.tar.gz \
    "https://github.com/hauxir/imgpush/archive/${VERSION}.tar.gz" && \
  tar xzf /tmp/imgpush.tar.gz -C /tmp/src --strip-components=1 && \
  echo "**** install python deps ****" && \
  cd /tmp/src && \
  uv sync --frozen --no-cache --no-dev --extra rembg --python 3.12 && \
  echo "**** install app, model and policy ****" && \
  mkdir -p /app/imgpush /app/home/.NudeNet /app/models && \
  cp -r /tmp/src/app/. /app/imgpush/ && \
  cp /tmp/src/classifier_model.onnx /app/home/.NudeNet/ && \
  cp /tmp/src/ImageMagick-6/policy.xml "$(ls -d /etc/ImageMagick-*)/policy.xml" && \
  /app/imgpush-venv/bin/python -c "from rembg import new_session; new_session('u2net')" && \
  install -D /tmp/src/LICENSE /usr/share/licenses/imgpush/LICENSE && \
  echo "**** cleanup ****" && \
  pip uninstall --yes uv && \
  chown -R root:root /app && \
  chmod -R 755 /app && \
  apt-get clean && \
  rm -rf /tmp/* /var/lib/apt/lists/*

# add local files (start.sh, etc/nginx/imgpush.conf)
USER apps
COPY --chmod=0755 . /

# defaults for the app's settings, matching start.sh and settings.yaml
ENV IMAGES_DIR=/config/images/ \
    CACHE_DIR=/config/cache/ \
    LOCAL_CACHE_DIR=/tmp/local_cache/

# ports and volumes
EXPOSE 5000
VOLUME /config

WORKDIR /app/imgpush
