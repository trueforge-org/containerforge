FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:3209530ed3169bb7c62c9010745abf292a4bcbe5b8757787aebcce488c09d520

ARG VERSION

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends "memcached=${VERSION}" && \
    apt-get purge -y --auto-remove && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER apps
COPY container-test.yaml /container-test.yaml

EXPOSE 11211

CMD ["memcached"]
