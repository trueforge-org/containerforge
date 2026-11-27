# BLOCKED (see plan.md section 10): the Python 3.7 / torch 1.6 stack and the model weights exist only inside the 2022 upstream image.
# This is the plan's option (a): rebase on the published CPU image. amd64 only. Needs a maintainer decision before merge.
FROM docker.io/deepquestai/deepstack:cpu-2022.01.1@sha256:4320be73987468b3040b2ca63daf2d3935c4d469b53aa40efb6176858488b500

ARG VERSION=2022.01.1

USER root

# Runtime user 568, as in the other apps. Skipped if the base already has it.
RUN \
  echo "**** create apps user and directories ****" && \
  (id -u apps >/dev/null 2>&1 || (groupadd -g 568 apps && useradd -u 568 -g 568 -d /config -s /bin/bash apps)) && \
  mkdir -p /config /tmp/deeptemp /modelstore/detection && \
  chown -R apps:apps /config && \
  chmod -R a+rX /app && \
  echo "**** install license ****" && \
  mkdir -p /usr/share/licenses/deepstack && \
  curl -fsSL -o /usr/share/licenses/deepstack/LICENSE \
    "https://raw.githubusercontent.com/johnolafenwa/DeepStack/73b6f7ab0f9a8acc8f7a49c6f13594fe470de042/LICENSE" && \
  rm -rf /tmp/*

# Writable paths are remapped: data to /config, temp and caches to /tmp.
# UNVERIFIED: SEND_LOGS=False is chosen to avoid telemetry; check what upstream sends.
ENV HOME=/config \
  APPDIR=/app \
  DATA_DIR=/config/datastore \
  TEMP_PATH=/tmp/deeptemp/ \
  PROFILE=desktop_cpu \
  CUDA_MODE=False \
  SEND_LOGS=False \
  TIMEOUT=60 \
  SLEEP_TIME=0.01 \
  PORT=5000 \
  XDG_CACHE_HOME=/tmp/cache \
  MPLCONFIGDIR=/tmp/mpl \
  TORCH_HOME=/tmp/torch \
  PYTHONDONTWRITEBYTECODE=1

USER apps
COPY --chmod=0755 . /

EXPOSE 5000

VOLUME /config

WORKDIR /config

# The upstream base runs /app/server/server as CMD and has no ContainerForge entrypoint, so start.sh is the CMD.
CMD ["/start.sh"]
