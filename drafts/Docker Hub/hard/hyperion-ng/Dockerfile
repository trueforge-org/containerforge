FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  XDG_CACHE_HOME=/tmp/.cache

# UNVERIFIED: runtime libraries (Qt, libusb, libssl, libcec, libv4l, libx11/xcb, libdrm, glib, pulse)
# must be mapped from the `Depends:` field of the .deb (`dpkg-deb -I`) and added with
# apt-get install --no-install-recommends. Not added yet; check with `ldd /app/hyperion/bin/hyperiond`.

RUN echo "*** Installing Hyperion ${VERSION} ***" && \
  case "${TARGETARCH}" in \
    amd64) SHA256=75ba1ed3f6d177d17d78d81d34776cdd36b1b564192c5e79475c6207999caf70 ;; \
    arm64) SHA256=39e7e8211e576e2dea89825ce016f02649eb2e3dff2fb1fc2a8b5da09879b229 ;; \
    *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  curl -fsSL -o /tmp/hyperion.tar.gz \
    "https://github.com/hyperion-project/hyperion.ng/releases/download/${VERSION}/Hyperion-${VERSION}-Linux-${TARGETARCH}.tar.gz" && \
  echo "${SHA256}  /tmp/hyperion.tar.gz" | sha256sum -c - && \
  mkdir -p /app/hyperion && \
  # UNVERIFIED: archive layout; inspect with `tar tzf` and add --strip-components if needed
  tar xzf /tmp/hyperion.tar.gz -C /app/hyperion && \
  ln -sf /app/hyperion/bin/hyperiond /usr/local/bin/hyperiond && \
  # UNVERIFIED: LICENSE location inside the tarball
  install -d /usr/share/licenses/hyperion-ng && \
  cp /app/hyperion/LICENSE* /usr/share/licenses/hyperion-ng/ && \
  echo "*** Cleaning Up ***" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -f /tmp/hyperion.tar.gz

USER apps
COPY --chmod=0755 . /

WORKDIR /config

EXPOSE 8090 19444 19400

VOLUME /config
