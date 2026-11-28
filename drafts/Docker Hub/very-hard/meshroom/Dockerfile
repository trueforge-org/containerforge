# syntax=docker/dockerfile:1@sha256:572cebbc2b15e6f84c077742952674889cb63cd5e9b80abdffcbe587b6f19183

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION
ARG TARGETARCH
USER root

# Prebuilt tarball is amd64 only (no arm64 build upstream)
RUN test "${TARGETARCH}" = "amd64" || { echo "meshroom: amd64 only"; exit 1; }

# Zenodo record 16887472 is the Meshroom 2025.1.0 release. The MD5 below is for that file only.
# UNVERIFIED: the record id and MD5 must be bumped by hand with VERSION.
RUN \
  echo "**** download meshroom ${VERSION} ****" && \
  curl -fL -o /tmp/meshroom.tar.gz \
    "https://zenodo.org/records/16887472/files/Meshroom-${VERSION}-Linux.tar.gz" && \
  echo "eb8124515bfdd5368faf6929b28c85ba  /tmp/meshroom.tar.gz" | md5sum -c - && \
  mkdir -p /app/meshroom && \
  tar xzf /tmp/meshroom.tar.gz -C /app/meshroom --strip-components=1 && \
  rm -f /tmp/meshroom.tar.gz

# UNVERIFIED: the MPL-2.0 LICENSE is not in the tarball listing; the build fails here if it is missing
RUN \
  echo "**** install license ****" && \
  mkdir -p /usr/share/licenses/meshroom && \
  cp /app/meshroom/LICENSE /usr/share/licenses/meshroom/LICENSE

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

# UNVERIFIED: the package list is a starting point; add only what ldd reports missing for the bundle
RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    libgl1 \
    libglu1-mesa \
    libice6 \
    libsm6 \
    libxi6 \
    libxkbcommon0 \
    libxrender1 \
    openssh-server \
    xauth && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

COPY --from=build /app/meshroom /app/meshroom
COPY --from=build /usr/share/licenses/meshroom /usr/share/licenses/meshroom

ENV HOME=/config \
    XDG_CACHE_HOME=/tmp/cache \
    XDG_CONFIG_HOME=/config/.config

WORKDIR /app/meshroom

EXPOSE 2222
VOLUME /config

COPY --chmod=0755 . /

USER apps
