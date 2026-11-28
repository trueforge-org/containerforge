
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

# set version label
ARG VERSION
# UNVERIFIED: SHA256 of cs2d_dedicated_linux.zip. Fill in after one manual download and a cross-check
# against the vendor hash on https://www.cs2d.com/download.php. The build fails while this is empty.
ARG CS2D_SHA256=""
ARG TARGETARCH
USER root

RUN \
  echo "**** download cs2d dedicated server ****" && \
  if [ "${TARGETARCH}" != "amd64" ]; then echo "Only linux/amd64 is supported"; exit 1; fi && \
  apt-get update && apt-get install -y --no-install-recommends \
    unzip && \
  mkdir -p \
    /tmp/cs2d/server && \
  curl -fL -o \
    /tmp/cs2d/cs2d_dedicated_linux.zip \
    "https://www.unrealsoftware.de/files_pub/cs2d_dedicated_linux.zip" && \
  echo "${CS2D_SHA256}  /tmp/cs2d/cs2d_dedicated_linux.zip" | sha256sum -c - && \
  unzip -q \
    /tmp/cs2d/cs2d_dedicated_linux.zip \
    -d /tmp/cs2d/server && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/cs2d/cs2d_dedicated_linux.zip \
    /var/lib/apt/lists/*

# runtime stage
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
USER root

# environment variables.
ENV HOME=/tmp

# UNVERIFIED: the draft installs libgtk2.0-0:i386 (32-bit GTK 2). Run `ldd cs2d_dedicated` in the build
# stage and add only the libraries it really needs, and do not add packages the base already has.

COPY --from=build /tmp/cs2d/server/ /app/counterstrike2d/

RUN \
  echo "**** set permissions ****" && \
  chown -R root:root \
    /app/counterstrike2d && \
  chmod -R a+rX \
    /app/counterstrike2d && \
  chmod 0755 \
    /app/counterstrike2d/cs2d_dedicated && \
  echo "**** license ****" && \
  mkdir -p \
    /usr/share/licenses/counterstrike2d && \
  printf '%s\n' \
    "CS2D dedicated server (version ${VERSION})" \
    "Source: https://www.cs2d.com/" \
    "UNVERIFIED: the vendor freeware terms were not read. Add the upstream license file from the zip here if it has one." \
    > /usr/share/licenses/counterstrike2d/NOTICE

# copy files
USER apps
COPY --chmod=0755 . /


# ports and volumes
VOLUME /config
WORKDIR /config
ENTRYPOINT ["/start.sh"]
