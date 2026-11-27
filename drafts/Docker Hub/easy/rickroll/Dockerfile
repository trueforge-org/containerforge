# Stage 1: fetch the video from the upstream release and verify its sha256
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS video

# The sha256 below only matches video.mp4. Any other VIDEO_NAME needs its own VIDEO_SHA256.
ARG VIDEO_NAME=video.mp4
ARG VIDEO_SHA256=7fe57b3d2f695e13ff7431e094a74960ea4f6b847a0c4472ce5b414d7ca7937e

USER root
# UNVERIFIED: curl and sha256sum are present in the ubuntu base
RUN set -eux; \
    curl -fsSLo /video.mp4 "https://github.com/modem7/docker-rickroll/releases/download/video-assets-v1/${VIDEO_NAME}"; \
    echo "${VIDEO_SHA256}  /video.mp4" | sha256sum -c -

# Stage 2: static page on the ContainerForge nginx base
FROM ghcr.io/trueforge-org/nginx:1.28.3@sha256:3a862278083a33d9ff969e987ee3a6ab24d2b928c35df07b2e69fa6f5d4e6cc1

# Pinned commit of modem7/docker-rickroll (no product version exists)
ARG VERSION

USER root

COPY --from=video --chown=568:568 /video.mp4 /usr/share/nginx/html/video.mp4

# UNVERIFIED: the upstream licence file name (LICENCE.txt) was not checked against the pinned commit
RUN set -eux; \
    mkdir -p /usr/share/licenses/rickroll; \
    curl -fsSLo /usr/share/licenses/rickroll/LICENSE "https://raw.githubusercontent.com/modem7/docker-rickroll/${VERSION}/LICENCE.txt"; \
    chown -R 568:568 /usr/share/nginx/html

USER apps
COPY --chmod=0755 . /

WORKDIR /usr/share/nginx/html
EXPOSE 8080
VOLUME /config
