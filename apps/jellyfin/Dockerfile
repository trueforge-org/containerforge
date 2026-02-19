FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:3209530ed3169bb7c62c9010745abf292a4bcbe5b8757787aebcce488c09d520
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
    && echo "deb [signed-by=/usr/share/keyrings/jellyfin-archive-keyring.gpg] https://repo.jellyfin.org/ubuntu noble main" \
         > /etc/apt/sources.list.d/jellyfin.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
      jellyfin=${VERSION}* \
    && chown -R apps:apps /app && chmod -R 755 /app \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER apps
COPY container-test.yaml /container-test.yaml
COPY ./root/ /
COPY ./ /

EXPOSE 8096 8920
VOLUME /config
