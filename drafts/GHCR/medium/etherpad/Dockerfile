
# Build stage: download the upstream Debian package for the target arch, verify it and unpack it. The package is not installed.
# UNVERIFIED: the package layout (src/ entry file, var/ writes) must be confirmed in the first build.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5 AS build

ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** fetch etherpad ${VERSION} ****" && \
  case "${TARGETARCH}" in \
    amd64) DEB_ARCH=amd64; DEB_SHA256=6cd390d346e8ca255f700f2ec99657b148002eff287262c6a553762d175718fd ;; \
    arm64) DEB_ARCH=arm64; DEB_SHA256=5e5e976e6c7dc630d4a45fc25f4a03a99e6e56f6eda02215e7fed1ee7dc02575 ;; \
    *) echo "unsupported arch ${TARGETARCH}" && exit 1 ;; \
  esac && \
  curl -fL -o \
    /tmp/etherpad.deb \
    "https://github.com/ether/etherpad/releases/download/v${VERSION}/etherpad_${VERSION}-1_${DEB_ARCH}.deb" && \
  echo "${DEB_SHA256}  /tmp/etherpad.deb" | sha256sum -c - && \
  echo "**** unpack (no install, no postinst) ****" && \
  dpkg-deb -x /tmp/etherpad.deb /tmp/root && \
  mkdir -p /app && \
  mv /tmp/root/opt/etherpad /app/etherpad && \
  install -D -m 0644 \
    /tmp/root/usr/share/etherpad/settings.json.dist \
    /app/etherpad/settings.json.dist && \
  install -D -m 0644 \
    /tmp/root/usr/share/doc/etherpad/copyright \
    /usr/share/licenses/etherpad/LICENSE && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

############## runtime stage ##############
# UNVERIFIED: python-node is used because it provides Node 24, which the .deb requires (nodejs >= 24). Plain ubuntu has no Node.
FROM ghcr.io/trueforge-org/python-node:3.15.2@sha256:0e0409c29043146f3ea597ad09325a96200ea22239da1b8180349fc7a53c3ef5

ARG VERSION
ARG TARGETARCH
USER root

# /app stays read-only at runtime. State goes to /config. HOME is writable scratch.
ENV NODE_ENV=production \
    ETHERPAD_PRODUCTION=true \
    DB_TYPE=sqlite \
    DB_FILENAME=/config/etherpad.sq3 \
    HOME=/tmp

COPY --from=build /app/etherpad/ /app/etherpad/
COPY --from=build /usr/share/licenses/etherpad/ /usr/share/licenses/etherpad/

# add local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 9001
VOLUME /config

WORKDIR /app/etherpad
