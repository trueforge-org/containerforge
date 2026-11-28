# Unresolved: Steam EULA licence string; game files and vendor keys are not part of the image.
FROM ghcr.io/trueforge-org/steamcmd:20180105.0.0@sha256:cc4726c133e71f2936e8d31000cb55d810e76d3c3ab47e0044e8ac12c1cbb1ff

ARG VERSION
ARG VENDOR

USER root

# Keep the base image's SteamCMD wrapper, because our /start.sh replaces it.
RUN cp /start.sh /usr/local/bin/steamcmd-init && \
    chmod 0755 /usr/local/bin/steamcmd-init

COPY --chmod=0755 start.sh /start.sh
USER apps
COPY --chmod=0755 . /
