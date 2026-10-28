FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:cab29d37a3d5e2d93201d98363c0169152d9d7147518121900f5587da719df62

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
