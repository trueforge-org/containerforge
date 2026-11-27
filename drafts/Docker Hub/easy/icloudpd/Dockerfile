FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  XDG_CONFIG_HOME=/config \
  TMPDIR=/tmp

# The release has no checksum file. The sha256 digest comes from the GitHub release API at build time and is compared with the downloaded file.
# Do not use the musl assets (glibc ubuntu base).
RUN set -eux; \
  V="${VERSION#v}"; \
  asset="icloudpd-${V}-linux-${TARGETARCH}"; \
  curl -fsSL -o /app/icloudpd "https://github.com/icloud-photos-downloader/icloud_photos_downloader/releases/download/v${V}/${asset}"; \
  want="$(curl -fsSL "https://api.github.com/repos/icloud-photos-downloader/icloud_photos_downloader/releases/tags/v${V}" | jq -r --arg n "${asset}" '.assets[] | select(.name == $n) | .digest' | sed 's/^sha256://')"; \
  test -n "${want}"; \
  echo "${want}  /app/icloudpd" | sha256sum -c -; \
  chmod 0755 /app/icloudpd; \
  chown -R apps:apps /app; \
  mkdir -p /usr/share/licenses/icloudpd; \
  curl -fsSL -o /usr/share/licenses/icloudpd/LICENSE.md "https://raw.githubusercontent.com/icloud-photos-downloader/icloud_photos_downloader/v${V}/LICENSE.md"; \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
VOLUME /data

WORKDIR /config
