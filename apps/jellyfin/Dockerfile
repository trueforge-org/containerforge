FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454
USER root

ARG TARGETARCH
ARG VERSION

ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"
# https://github.com/dlemstra/Magick.NET/issues/707#issuecomment-785351620

ENV MALLOC_TRIM_THRESHOLD_=131072

RUN apt-get update && apt-get install -y --no-install-recommends \
      apt-transport-https \
      at \
      libjemalloc2 \
      mesa-va-drivers \
      xmlstarlet \
      libfontconfig1 \
      libfreetype6 \
    && echo "**** add Jellyfin repo *****" \
    && curl -fsSL https://repo.jellyfin.org/jellyfin_team.gpg.key | gpg --dearmor -o /usr/share/keyrings/jellyfin-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/jellyfin-archive-keyring.gpg] https://repo.jellyfin.org/ubuntu resolute main" \
         > /etc/apt/sources.list.d/jellyfin.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      jellyfin=${VERSION}* \
    && chown -R apps:apps /app && chmod -R 755 /app \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER apps
COPY --chmod=0755 . /
COPY ./ /

EXPOSE 8096 8920
VOLUME /config
