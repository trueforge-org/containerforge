FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:0628c88c702e66783b5565dadf138d0f878ee3c5e8ef8fc7c52b28224ae4d174
ARG VERSION
ARG TARGETARCH
USER root

# environment variables
ENV FORCE_CONTAINER_REMOVAL=1 \
FORCE_IMAGE_REMOVAL=1


RUN echo "**** install runtime packages ****" && \
 apt-get update && \
 apt-get install -y --no-install-recommends \
    docker.io && \
 echo "**** fetch latest ver of docker-gc script ****" && \
 git clone https://github.com/spotify/docker-gc /tmp/docker-gc && \
 cp /tmp/docker-gc/docker-gc /docker-gc && \
 chmod +x \
    /docker-gc && \
 echo "**** cleanup ****" && \
 apt-get autoremove -y && \
 apt-get clean && \
 rm -rf \
    /var/lib/apt/lists/* /tmp/*

# volumes
VOLUME /var/lib/docker-gc
