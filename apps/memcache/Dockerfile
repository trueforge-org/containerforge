FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:1888fc219883c47800b75c40a586266ebb7362f9a13f697dbe894fb777a299bf

ARG VERSION

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends "memcached=${VERSION}" && \
    apt-get purge -y --auto-remove && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 11211

CMD ["memcached"]
