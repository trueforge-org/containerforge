
# UNVERIFIED digest pin: taken from the draft plan for kasmvnc 1.5.2
FROM ghcr.io/trueforge-org/kasmvnc:1.5.2@sha256:870414f75035f215e19dbb5583e163b5d8e603e41ca8fa0e4669323c45fbdc27

ARG VERSION
ARG OBS_VERSION
ARG OBS_PACKAGE_VERSION
ARG DISTROAV_SHA256
ARG TARGETARCH
USER root

# DistroAV publishes an x86_64 deb only
RUN [ "${TARGETARCH}" = "amd64" ] || (echo "obs-ndi is amd64 only" && exit 1)

# Install OBS from apt (pinned, must match OBS_VERSION) and DistroAV from the release deb (sha256 checked)
RUN echo "*** Installing OBS Studio and DistroAV ***" && \
  test "${OBS_PACKAGE_VERSION%%-*}" = "${OBS_VERSION}" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    "obs-studio=${OBS_PACKAGE_VERSION}" \
    ca-certificates \
    curl && \
  curl -fsSL -o /tmp/distroav.deb \
    "https://github.com/DistroAV/DistroAV/releases/download/${VERSION}/distroav-${VERSION}-x86_64-linux-gnu.deb" && \
  echo "${DISTROAV_SHA256}  /tmp/distroav.deb" | sha256sum -c - && \
  apt-get install -y --no-install-recommends /tmp/distroav.deb && \
  echo "*** Installing license ***" && \
  mkdir -p /usr/share/licenses/obs-ndi && \
  curl -fsSL -o /usr/share/licenses/obs-ndi/LICENSE \
    "https://raw.githubusercontent.com/DistroAV/DistroAV/${VERSION}/LICENSE" && \
  cp /usr/share/doc/obs-studio/copyright /usr/share/licenses/obs-ndi/OBS-COPYRIGHT && \
  echo "*** Cleaning Up ***" && \
  apt-get clean && \
  rm -rf /tmp/* /var/lib/apt/lists/*

# The base image's start script is replaced by this app's start.sh, which hands off to it
RUN mv /start.sh /kasmvnc-start.sh

ENV \
  HOME=/config \
  QT_QPA_PLATFORM=xcb \
  XDG_CACHE_HOME=/tmp/.cache \
  LIBGL_ALWAYS_SOFTWARE=1

USER apps
COPY --chmod=0755 . /

EXPOSE 3000 3001

VOLUME /config

WORKDIR /config
