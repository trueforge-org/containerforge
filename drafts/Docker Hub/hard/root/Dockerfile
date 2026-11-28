# UNVERIFIED: ROOT tarball layout (top folder root/), LICENSE path and runtime library list come from the plan and must be confirmed on the first build (ldd /app/root/bin/root.exe).
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG ROOT_SHA256
ARG TARGETARCH
# renovate: datasource=pypi depName=notebook
# UNVERIFIED: 7.2.2 is a placeholder pin; confirm it exists and supports the ROOT python bindings.
ARG JUPYTER_VERSION=7.2.2
USER root

ENV \
  HOME=/config \
  ROOTSYS=/app/root \
  JUPYTER_CONFIG_DIR=/config/jupyter \
  JUPYTER_DATA_DIR=/config/jupyter/data \
  JUPYTER_RUNTIME_DIR=/tmp/jupyter \
  IPYTHONDIR=/config/ipython \
  PIP_CACHE_DIR=/tmp/pip \
  XDG_CACHE_HOME=/tmp \
  MPLCONFIGDIR=/tmp/mpl \
  TMPDIR=/tmp

RUN echo "*** Checking architecture ***" && \
  test "${TARGETARCH}" = "amd64" || { echo "root: upstream publishes no linux/arm64 binary; build amd64 only" >&2; exit 1; }

RUN echo "*** Installing ROOT runtime dependencies ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    libfftw3-double3 \
    libgl1 \
    libglu1-mesa \
    libgsl28 \
    libjpeg-turbo8 \
    libpng16-16t64 \
    libssl3t64 \
    libtbb12 \
    libx11-6 \
    libxext6 \
    libxft2 \
    libxpm4 \
    python3 \
    python3-numpy \
    python3-venv && \
  rm -rf /var/lib/apt/lists/*

RUN echo "*** Installing ROOT ${VERSION} ***" && \
  V="${VERSION#v}" && DOT="${V//-/.}" && \
  curl -fsSL -o \
    /tmp/root.tar.gz \
    "https://github.com/root-project/root/releases/download/${VERSION}/root_v${DOT}.Linux-ubuntu26.04-x86_64-gcc15.2.tar.gz" && \
  echo "${ROOT_SHA256}  /tmp/root.tar.gz" | sha256sum -c - && \
  mkdir -p /app && \
  tar xzf /tmp/root.tar.gz -C /app && \
  mkdir -p /usr/share/licenses/root && \
  cp /app/root/LICENSE /usr/share/licenses/root/ && \
  rm /tmp/root.tar.gz

# Jupyter lives in its own venv under /app so it is read-only at runtime.
# --system-site-packages keeps the system python3-numpy visible to PyROOT (UNVERIFIED).
RUN echo "*** Installing Jupyter ***" && \
  python3 -m venv --system-site-packages /app/venv && \
  /app/venv/bin/pip install --no-cache-dir "notebook==${JUPYTER_VERSION}" && \
  chown -R apps:apps /app && chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

EXPOSE 8888

VOLUME /config
WORKDIR /config
