FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:6064d5af956ed39456b8c643d6434d9d5331f4d77c08230a413f6a1b253a1408

ARG VERSION

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends "memcached=${VERSION}" && \
    apt-get purge -y --auto-remove && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER apps

EXPOSE 11211

CMD ["memcached"]
