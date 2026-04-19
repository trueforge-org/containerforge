FROM ghcr.io/trueforge-org/ubuntu:24.4@c5a3b56e4d22600d2b618d602d487732516cc067cb21969798210c3b12304842
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
COPY --chmod=0755 . /
COPY ./ /

EXPOSE 8096 8920
VOLUME /config
