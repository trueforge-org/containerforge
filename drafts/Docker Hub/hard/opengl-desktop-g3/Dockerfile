# syntax=docker/dockerfile:1@sha256:572cebbc2b15e6f84c077742952674889cb63cd5e9b80abdffcbe587b6f19183

# Base: the repo's KasmVNC web desktop (rootless, /config home). Mesa and VirtualGL are added on top.
FROM ghcr.io/trueforge-org/kasmvnc:1.5.2@sha256:870414f75035f215e19dbb5583e163b5d8e603e41ca8fa0e4669323c45fbdc27

ARG VERSION
ARG TARGETARCH
# UNVERIFIED: compute with sha256sum on the upstream .deb files at implementation time and set here.
ARG VIRTUALGL_SHA256_AMD64=""
ARG VIRTUALGL_SHA256_ARM64=""
USER root

# UNVERIFIED: package names on ubuntu 26.04 and whether the kasmvnc base already has the Mesa GL libs.
RUN echo "*** Installing Mesa and GL test tools ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    mesa-utils \
    mesa-utils-extra \
    libgl1-mesa-dri \
    libegl1 \
    libglx-mesa0 \
    glmark2-x11 \
    xterm && \
  rm -rf /var/lib/apt/lists/*

# VirtualGL is pinned to the release tag and checked against the sha256 above.
# It is used through vglrun. vglserver_config is not run (it needs root and changes /etc).
RUN echo "*** Installing VirtualGL ${VERSION} ***" && \
  case "${TARGETARCH}" in \
    amd64) sha="${VIRTUALGL_SHA256_AMD64}" ;; \
    arm64) sha="${VIRTUALGL_SHA256_ARM64}" ;; \
    *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  [ -n "${sha}" ] || { echo "VirtualGL checksum for ${TARGETARCH} is not set" >&2; exit 1; } && \
  curl -fsSL -o /tmp/virtualgl.deb \
    "https://github.com/VirtualGL/virtualgl/releases/download/${VERSION}/virtualgl_${VERSION}_${TARGETARCH}.deb" && \
  echo "${sha}  /tmp/virtualgl.deb" | sha256sum -c - && \
  apt-get update && \
  apt-get install -y --no-install-recommends /tmp/virtualgl.deb && \
  dpkg-query -W -f='${Version}' virtualgl | grep -q "^${VERSION}" && \
  rm -f /tmp/virtualgl.deb && \
  rm -rf /var/lib/apt/lists/*

# UNVERIFIED: copyright file path inside the VirtualGL package.
RUN mkdir -p /usr/share/licenses/opengl-desktop-g3 && \
  cp /usr/share/doc/virtualgl/copyright /usr/share/licenses/opengl-desktop-g3/virtualgl-copyright

# Hand over the base start script. COPY below replaces /start.sh with ours, which chains to the base.
# UNVERIFIED: the base start script works from a different file name.
RUN mv /start.sh /kasmvnc-start.sh

ENV \
  HOME=/config \
  XDG_CACHE_HOME=/tmp/.cache

USER apps
COPY --chmod=0755 . /

EXPOSE 3000 3001

VOLUME /config
WORKDIR /config
