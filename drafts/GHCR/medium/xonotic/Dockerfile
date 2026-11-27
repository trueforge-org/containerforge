FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS buildstage

# build variables
ARG VERSION
USER root

RUN \
  echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    unzip && \
  rm -rf /var/lib/apt/lists/*

RUN \
  echo "**** fetch and verify xonotic ${VERSION} ****" && \
  curl -fL -o /tmp/xonotic.zip \
    "https://dl.xonotic.org/xonotic-${VERSION}.zip" && \
  curl -fL -o /tmp/xonotic.sha512 \
    "https://dl.xonotic.org/xonotic-${VERSION}.sha512" && \
  grep " xonotic-${VERSION}.zip\$" /tmp/xonotic.sha512 \
    | awk '{print $1"  /tmp/xonotic.zip"}' > /tmp/xonotic.sha512.one && \
  sha512sum -c /tmp/xonotic.sha512.one && \
  echo "**** extract game files ****" && \
  mkdir -p /app /defaults && \
  unzip -q /tmp/xonotic.zip -d /tmp/xonotic-extract && \
  mv /tmp/xonotic-extract/Xonotic /app/xonotic && \
  chmod +x /app/xonotic/xonotic-linux64-dedicated && \
  echo "**** seed default config ****" && \
  cp /app/xonotic/data/server.cfg /defaults/server.cfg && \
  echo "**** license files ****" && \
  mkdir -p /usr/share/licenses/xonotic && \
  find /app/xonotic -maxdepth 1 -type f \( -iname 'COPYING*' -o -iname 'LICEN*' -o -iname 'NOTICE*' \) \
    -exec cp {} /usr/share/licenses/xonotic/ \; && \
  echo "**** cleanup ****" && \
  rm -rf /tmp/xonotic.zip /tmp/xonotic.sha512 /tmp/xonotic.sha512.one /tmp/xonotic-extract

############## runtime stage ##############
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

# set version label
ARG VERSION
USER root

# add xonotic game files, seed config and licenses
COPY --from=buildstage /app/xonotic/ /app/xonotic/
COPY --from=buildstage /defaults/ /defaults/
COPY --from=buildstage /usr/share/licenses/xonotic/ /usr/share/licenses/xonotic/

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 26000/udp

ENV HOME=/config \
    TMPDIR=/tmp

WORKDIR /config
VOLUME /config
